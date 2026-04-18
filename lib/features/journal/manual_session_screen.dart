import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../domain/enums/enums.dart';
import '../../domain/models/brew_variant.dart';
import '../../domain/models/infusion_log.dart';
import '../../domain/models/session.dart';
import '../../domain/models/tea.dart';
import '../../features/collection/tea_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/star_rating.dart';
import '../../shared/widgets/tea_thumb.dart';
import '../../shared/widgets/tea_type_chip.dart';
import '../../shared/widgets/tea_type_selector.dart';
import '../../theme/steapleaf_theme.dart';
import 'session_provider.dart';
import 'models/infusion_entry.dart';
import 'widgets/infusion_row.dart';


enum _TeaMode { collection, external }

class ManualSessionScreen extends StatefulWidget {
  const ManualSessionScreen({super.key});

  @override
  State<ManualSessionScreen> createState() => _ManualSessionScreenState();
}

class _ManualSessionScreenState extends State<ManualSessionScreen> {
  _TeaMode _mode = _TeaMode.collection;

  // Collection mode
  Tea? _selectedTea;
  BrewVariant? _selectedVariant;
  final _teaSearchCtrl = TextEditingController();
  String _teaSearch = '';

  // External mode
  final _teaNameCtrl = TextEditingController();
  TeaType _type = TeaType.green;
  final _gramsCtrl = TextEditingController();
  final _mlCtrl = TextEditingController();
  final List<InfusionEntry> _infusions = [];

  // Shared
  final _notesCtrl = TextEditingController();
  final _additionCtrl = TextEditingController();
  int _rating = 0;
  DateTime _dateTime = DateTime.now();
  final List<String> _additions = [];
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _infusions.add(InfusionEntry());
    _teaNameCtrl.addListener(_markDirty);
    _notesCtrl.addListener(_markDirty);
  }

  @override
  void dispose() {
    _teaSearchCtrl.dispose();
    _teaNameCtrl.removeListener(_markDirty);
    _teaNameCtrl.dispose();
    _notesCtrl.removeListener(_markDirty);
    _notesCtrl.dispose();
    _additionCtrl.dispose();
    _gramsCtrl.dispose();
    _mlCtrl.dispose();
    for (final e in _infusions) { e.dispose(); }
    super.dispose();
  }

  void _markDirty() {
    if (!_isDirty) setState(() => _isDirty = true);
  }

  Future<bool> _confirmDiscard(BuildContext context) => ConfirmDialog.show(
        context,
        title: 'Änderungen verwerfen?',
        message: 'Die eingegebenen Daten gehen verloren.',
      );

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final teas = context.watch<TeaProvider>().teas;
    final filteredTeas = _teaSearch.isEmpty
        ? teas
        : teas
            .where((t) => t.name.toLowerCase().contains(_teaSearch.toLowerCase()))
            .toList();

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop) {
          final leave = await _confirmDiscard(context);
          if (leave && context.mounted) Navigator.pop(context);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('記 · Session erfassen', style: textTheme.titleLarge),
        ),
        bottomNavigationBar: ActionBar(
          children: [
            ActionBarButton.primary(
              label: 'Speichern',
              onPressed: _save,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(
            SteapLeafSpacing.md, SteapLeafSpacing.sm,
            SteapLeafSpacing.md, SteapLeafSpacing.xxl,
          ),
          children: [

            // ── Modus-Toggle ─────────────────────────────────────────────
            SegmentedButton<_TeaMode>(
              segments: const [
                ButtonSegment(
                  value: _TeaMode.collection,
                  label: Text('Aus Sammlung'),
                  icon: Icon(Icons.collections_bookmark_outlined),
                ),
                ButtonSegment(
                  value: _TeaMode.external,
                  label: Text('Externer Tee'),
                  icon: Icon(Icons.add_circle_outline),
                ),
              ],
              selected: {_mode},
              onSelectionChanged: (s) => setState(() {
                _mode = s.first;
                _isDirty = true;
              }),
              showSelectedIcon: false,
            ),
            const SizedBox(height: SteapLeafSpacing.lg),

            // ── Modus: Aus Sammlung ───────────────────────────────────────
            if (_mode == _TeaMode.collection) ...[
              _sectionLabel(context, 'Tee'),
              const SizedBox(height: SteapLeafSpacing.xs),
              if (_selectedTea == null) ...[
                TextField(
                  controller: _teaSearchCtrl,
                  decoration: const InputDecoration(
                    hintText: 'Tee suchen …',
                    prefixIcon: Icon(Icons.search, size: 20),
                  ),
                  onChanged: (v) => setState(() => _teaSearch = v.trim()),
                ),
                const SizedBox(height: SteapLeafSpacing.xs),
                if (teas.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: SteapLeafSpacing.md),
                    child: Text(
                      'Sammlung ist noch leer',
                      style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant),
                    ),
                  )
                else
                  ...filteredTeas.take(8).map((tea) => _TeaPickRow(
                        tea: tea,
                        onTap: () => setState(() {
                          _selectedTea = tea;
                          _selectedVariant = tea.defaultVariantId != null
                              ? tea.brewVariants.firstWhere(
                                  (v) => v.id == tea.defaultVariantId,
                                  orElse: () => tea.brewVariants.first,
                                )
                              : tea.brewVariants.isNotEmpty
                                  ? tea.brewVariants.first
                                  : null;
                          _teaSearch = '';
                          _teaSearchCtrl.clear();
                          _isDirty = true;
                        }),
                      )),
              ] else ...[
                _SelectedTeaCard(
                  tea: _selectedTea!,
                  onClear: () => setState(() {
                    _selectedTea = null;
                    _selectedVariant = null;
                    _isDirty = true;
                  }),
                ),
                if (_selectedTea!.brewVariants.isNotEmpty) ...[
                  const SizedBox(height: SteapLeafSpacing.lg),
                  _sectionLabel(context, 'Variante'),
                  const SizedBox(height: SteapLeafSpacing.xs),
                  ..._selectedTea!.brewVariants.map((v) {
                    final isSelected = _selectedVariant?.id == v.id;
                    return Padding(
                      padding:
                          const EdgeInsets.only(bottom: SteapLeafSpacing.xs),
                      child: WashiCard(
                        accentCorners: isSelected,
                        onTap: () => setState(() {
                          _selectedVariant = isSelected ? null : v;
                          _isDirty = true;
                        }),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(v.label,
                                      style: textTheme.titleSmall),
                                  const SizedBox(
                                      height: SteapLeafSpacing.tiny),
                                  Text(
                                    [
                                      v.style.label,
                                      if (v.dosageGrams != null)
                                        '${v.dosageGrams!.toStringAsFixed(1)} g',
                                      if (v.waterMl != null)
                                        '${v.waterMl} ml',
                                      if (v.infusions.isNotEmpty)
                                        '${v.infusions.length} Aufgüsse',
                                    ].join(' · '),
                                    style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check,
                                  size: 16, color: colorScheme.primary),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ]

            // ── Modus: Externer Tee ───────────────────────────────────────
            else ...[
              TextFormField(
                controller: _teaNameCtrl,
                decoration:
                    const InputDecoration(labelText: 'Tee-Name *'),
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: SteapLeafSpacing.lg),
              _sectionLabel(context, 'Teesorte'),
              const SizedBox(height: SteapLeafSpacing.xs),
              TeaTypeSelector(
                selected: _type,
                onChanged: (t) => setState(() {
                  _type = t;
                  _isDirty = true;
                  for (final e in _infusions) {
                    if (int.tryParse(e.tempCtrl.text) == null) {
                      e.tempCtrl.text = t.defaultTemp.toString();
                    }
                  }
                }),
              ),
              const SizedBox(height: SteapLeafSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _gramsCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Gramm'),
                      keyboardType: const TextInputType.numberWithOptions(
                          decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[0-9.]')),
                      ],
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                  const SizedBox(width: SteapLeafSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _mlCtrl,
                      decoration:
                          const InputDecoration(labelText: 'Wasser (ml)'),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      onChanged: (_) => _markDirty(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SteapLeafSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionLabel(context, 'Aufgüsse'),
                  InkWell(
                    onTap: () {
                      _addInfusion();
                      _markDirty();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10,
                          horizontal: SteapLeafSpacing.tiny),
                      child: Text(
                        '+ Aufguss',
                        style: textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: SteapLeafSpacing.xs),
              ..._infusions.asMap().entries.map(
                (e) => InfusionRow(
                  index: e.key,
                  entry: e.value,
                  canDelete: _infusions.length > 1,
                  onChanged: _markDirty,
                  onDelete: () => setState(() {
                    _infusions[e.key].dispose();
                    _infusions.removeAt(e.key);
                    _isDirty = true;
                  }),
                ),
              ),
            ],

            // ── Datum & Uhrzeit ───────────────────────────────────────────
            const SizedBox(height: SteapLeafSpacing.lg),
            _sectionLabel(context, 'Datum & Uhrzeit'),
            const SizedBox(height: SteapLeafSpacing.xs),
            _DateTimePicker(dateTime: _dateTime, onTap: _pickDateTime),
            const SizedBox(height: SteapLeafSpacing.lg),

            // ── Bewertung ─────────────────────────────────────────────────
            _sectionLabel(context, 'Bewertung'),
            const SizedBox(height: SteapLeafSpacing.xs),
            StarRating(
              rating: _rating,
              size: 28,
              onChanged: (v) => setState(() {
                _rating = v;
                _isDirty = true;
              }),
            ),
            const SizedBox(height: SteapLeafSpacing.lg),

            // ── Zusätze ───────────────────────────────────────────────────
            _sectionLabel(context, 'Zusätze'),
            const SizedBox(height: SteapLeafSpacing.xs),
            Wrap(
              spacing: SteapLeafSpacing.xs,
              runSpacing: 6,
              children: kStandardAdditions.map((a) {
                final active = _additions.contains(a);
                return InkWell(
                  onTap: () => setState(() {
                    active ? _additions.remove(a) : _additions.add(a);
                    _isDirty = true;
                  }),
                  splashColor: colorScheme.primary.withValues(alpha: 0.08),
                  highlightColor:
                      colorScheme.primary.withValues(alpha: 0.08),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    constraints: const BoxConstraints(minHeight: 34),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: active
                          ? colorScheme.onSurface
                          : Colors.transparent,
                      border: Border.all(
                        color: active
                            ? colorScheme.onSurface
                            : colorScheme.outlineVariant,
                        width: active ? 1.0 : 0.5,
                      ),
                    ),
                    child: Text(
                      a,
                      style: textTheme.bodySmall?.copyWith(
                        color: active
                            ? colorScheme.surface
                            : colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: SteapLeafSpacing.xs),
            Builder(builder: (context) {
              final custom = _additions
                  .where((a) => !kStandardAdditions.contains(a))
                  .toList();
              if (custom.isEmpty) return const SizedBox.shrink();
              return Padding(
                padding:
                    const EdgeInsets.only(bottom: SteapLeafSpacing.xs),
                child: Wrap(
                  spacing: SteapLeafSpacing.xs,
                  runSpacing: 6,
                  children: custom
                      .map((a) => AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            constraints:
                                const BoxConstraints(minHeight: 34),
                            padding: const EdgeInsets.only(
                                left: 10, right: 4, top: 7, bottom: 7),
                            decoration: BoxDecoration(
                              color: colorScheme.onSurface,
                              border: Border.all(
                                  color: colorScheme.onSurface),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  a,
                                  style: textTheme.bodySmall?.copyWith(
                                      color: colorScheme.surface),
                                ),
                                const SizedBox(
                                    width: SteapLeafSpacing.tiny),
                                InkWell(
                                  onTap: () => setState(() {
                                    _additions.remove(a);
                                    _isDirty = true;
                                  }),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4, vertical: 2),
                                    child: Icon(Icons.close,
                                        size: 14,
                                        color: colorScheme.surface),
                                  ),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                ),
              );
            }),
            TextField(
              controller: _additionCtrl,
              decoration: const InputDecoration(
                  hintText: 'Weiteres hinzufügen …'),
              onSubmitted: (v) {
                final val = v.trim();
                if (val.isNotEmpty && !_additions.contains(val)) {
                  setState(() {
                    _additions.add(val);
                    _isDirty = true;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('"$val" hinzugefügt'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                }
                _additionCtrl.clear();
              },
            ),
            const SizedBox(height: SteapLeafSpacing.lg),

            // ── Notiz ─────────────────────────────────────────────────────
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(labelText: 'Notiz'),
              maxLines: 4,
              minLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) => Text(
        text.toUpperCase(),
        style: SteapLeafTextTheme.sectionLabel.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );

  void _addInfusion() {
    final entry = InfusionEntry();
    entry.tempCtrl.text = _infusions.isNotEmpty
        ? _infusions.last.tempCtrl.text
        : _type.defaultTemp.toString();
    setState(() => _infusions.add(entry));
  }

  Future<void> _pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date == null || !mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_dateTime),
    );
    if (!mounted) return;
    setState(() {
      _dateTime = DateTime(
        date.year, date.month, date.day,
        time?.hour ?? _dateTime.hour,
        time?.minute ?? _dateTime.minute,
      );
    });
  }

  Future<void> _save() async {
    if (_mode == _TeaMode.collection && _selectedTea == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Bitte einen Tee aus der Sammlung wählen')),
      );
      return;
    }
    if (_mode == _TeaMode.external &&
        _teaNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bitte Tee-Name eingeben')),
      );
      return;
    }

    final String? teaId;
    final String teaName;
    final TeaType teaType;
    final BrewVariant? brewVariant;
    final List<InfusionLog> logs;

    if (_mode == _TeaMode.collection) {
      teaId = _selectedTea!.id;
      teaName = _selectedTea!.name;
      teaType = _selectedTea!.type;
      brewVariant = _selectedVariant;
      logs = _selectedVariant?.infusions
              .asMap()
              .entries
              .map((e) => InfusionLog(
                    infusionNumber: e.key + 1,
                    tempActual: e.value.tempMin,
                    plannedTime: e.value.steepTime,
                    actualTime: e.value.steepTime,
                  ))
              .toList() ??
          [];
    } else {
      teaId = null;
      teaName = _teaNameCtrl.text.trim();
      teaType = _type;
      final grams = double.tryParse(_gramsCtrl.text.trim());
      final ml = int.tryParse(_mlCtrl.text.trim());
      brewVariant = (grams != null || ml != null)
          ? BrewVariant(
              id: const Uuid().v4(),
              label: teaName,
              style: BrewStyle.western,
              dosageGrams: grams,
              waterMl: ml,
              infusions: const [],
            )
          : null;
      logs = _infusions
          .asMap()
          .entries
          .map((e) => e.value.toLog(e.key))
          .toList();
    }

    final session = Session(
      id: const Uuid().v4(),
      dateTime: _dateTime,
      teaId: teaId,
      teaName: teaName,
      teaType: teaType,
      brewVariant: brewVariant,
      infusionLogs: logs,
      additions: _additions,
      notes: _notesCtrl.text.trim().isEmpty
          ? null
          : _notesCtrl.text.trim(),
      rating: _rating,
      isManual: true,
    );

    final provider = context.read<SessionProvider>();
    final nav = Navigator.of(context);
    await provider.addSession(session);
    if (!mounted) return;
    nav.pop();
  }
}

// ---------------------------------------------------------------------------

class _TeaPickRow extends StatelessWidget {
  final Tea tea;
  final VoidCallback onTap;
  const _TeaPickRow({required this.tea, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SteapLeafSpacing.xs),
        child: Row(
          children: [
            TeaThumb(tea: tea, size: 40),
            const SizedBox(width: SteapLeafSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tea.name, style: textTheme.bodyMedium),
                  const SizedBox(height: SteapLeafSpacing.micro),
                  TeaTypeChip(type: tea.type),
                ],
              ),
            ),
            Icon(Icons.chevron_right,
                size: 18, color: colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

class _SelectedTeaCard extends StatelessWidget {
  final Tea tea;
  final VoidCallback onClear;
  const _SelectedTeaCard({required this.tea, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return WashiCard(
      child: Row(
        children: [
          TeaThumb(tea: tea, size: 48),
          const SizedBox(width: SteapLeafSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tea.name, style: textTheme.titleSmall),
                const SizedBox(height: SteapLeafSpacing.tiny),
                TeaTypeChip(type: tea.type),
              ],
            ),
          ),
          TextButton(
            onPressed: onClear,
            style: TextButton.styleFrom(
              foregroundColor: colorScheme.primary,
              textStyle: textTheme.labelSmall,
            ),
            child: const Text('Ändern'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DateTimePicker extends StatelessWidget {
  final DateTime dateTime;
  final VoidCallback onTap;
  const _DateTimePicker({required this.dateTime, required this.onTap});

  String get _formatted =>
      '${dateTime.day.toString().padLeft(2, '0')}.'
      '${dateTime.month.toString().padLeft(2, '0')}.'
      '${dateTime.year}  '
      '${dateTime.hour.toString().padLeft(2, '0')}:'
      '${dateTime.minute.toString().padLeft(2, '0')} Uhr';

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 13),
        decoration: BoxDecoration(
          border: Border.all(
              color: colorScheme.outlineVariant, width: 0.5),
        ),
        child: Row(
          children: [
            Icon(Icons.event_outlined,
                size: 18, color: colorScheme.onSurfaceVariant),
            const SizedBox(width: SteapLeafSpacing.xs),
            Text(
              _formatted,
              style: SteapLeafTextTheme.brewParameter.copyWith(
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
