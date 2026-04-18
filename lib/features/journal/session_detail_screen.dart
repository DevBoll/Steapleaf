import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../domain/models/session.dart';
import '../../domain/models/tea.dart';
import '../../features/collection/tea_detail_screen.dart';
import '../../features/collection/tea_provider.dart';
import '../../shared/widgets/confirm_dialog.dart';
import '../../shared/widgets/star_rating.dart';
import '../../shared/widgets/tea_thumb.dart';
import '../../shared/widgets/tea_type_chip.dart';
import '../../theme/steapleaf_theme.dart';
import 'session_provider.dart';


class SessionDetailScreen extends StatelessWidget {
  final Session session;
  const SessionDetailScreen({super.key, required this.session});

  static final _dfDate = DateFormat('dd. MMMM yyyy', 'de');
  static final _dfTime = DateFormat('HH:mm', 'de');

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;
    final tea = session.teaId != null
        ? context.watch<TeaProvider>().getById(session.teaId!)
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_dfDate.format(session.dateTime), style: textTheme.titleMedium),
            Text(
              '${session.teaType.kanji} · ${session.teaType.label}',
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.delete_outline, color: colorScheme.error),
            tooltip: 'Session löschen',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          SteapLeafSpacing.md, SteapLeafSpacing.md,
          SteapLeafSpacing.md, SteapLeafSpacing.xxl,
        ),
        children: [

          // ── Tea-Header ──────────────────────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (tea != null)
                TeaThumb(tea: tea, size: 56)
              else
                CircleAvatar(
                  radius: 28,
                  backgroundColor: session.teaType.colors.container,
                  child: Text(
                    session.teaType.kanji,
                    style: textTheme.titleLarge?.copyWith(
                      fontSize: 22,
                      color: session.teaType.colors.onContainer,
                      fontWeight: FontWeight.w400,
                      height: 1.0,
                    ),
                  ),
                ),
              const SizedBox(width: SteapLeafSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(session.teaName, style: textTheme.titleLarge),
                    const SizedBox(height: SteapLeafSpacing.micro),
                    Row(
                      children: [
                        TeaTypeChip(type: session.teaType),
                        const SizedBox(width: SteapLeafSpacing.xs),
                        Text(
                          _dfTime.format(session.dateTime),
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        if (session.isManual) ...[
                          const SizedBox(width: SteapLeafSpacing.xs),
                          Text(
                            '· manuell',
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (session.rating > 0) ...[
                const SizedBox(width: SteapLeafSpacing.xs),
                StarRating(rating: session.rating, size: 16),
              ],
            ],
          ),

          // ── Tee-Info ────────────────────────────────────────────────────
          if (tea != null) ...[
            _divider(),
            _TeaInfoCard(tea: tea),
          ],

          // ── Brühparameter ───────────────────────────────────────────────
          if (session.brewVariant != null ||
              session.additions.isNotEmpty) ...[
            _divider(),
            _SectionLabel('Brühparameter'),
            const SizedBox(height: SteapLeafSpacing.xs),
            WashiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (session.brewVariant != null) ...[
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            session.brewVariant!.label,
                            style: textTheme.titleSmall,
                          ),
                        ),
                        Text(
                          session.brewVariant!.style.label,
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    if (session.brewVariant!.dosageGrams != null ||
                        session.brewVariant!.waterMl != null) ...[
                      const SizedBox(height: SteapLeafSpacing.tiny),
                      Text(
                        [
                          if (session.brewVariant!.dosageGrams != null)
                            '${session.brewVariant!.dosageGrams!.toStringAsFixed(1)} g',
                          if (session.brewVariant!.waterMl != null)
                            '${session.brewVariant!.waterMl} ml',
                        ].join(' · '),
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    if (session.brewVariant!.customNotes != null &&
                        session.brewVariant!.customNotes!.isNotEmpty) ...[
                      const SizedBox(height: SteapLeafSpacing.xs),
                      Text(
                        session.brewVariant!.customNotes!,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                  if (session.additions.isNotEmpty) ...[
                    if (session.brewVariant != null)
                      const SizedBox(height: SteapLeafSpacing.sm),
                    _SectionLabel('Zusätze'),
                    const SizedBox(height: SteapLeafSpacing.tiny),
                    Text(
                      session.additions.join(', '),
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // ── Aufgüsse ────────────────────────────────────────────────────
          if (session.infusionLogs.isNotEmpty) ...[
            _divider(),
            _SectionLabel('Aufgüsse (${session.infusionLogs.length})'),
            const SizedBox(height: SteapLeafSpacing.xs),
            WashiCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: session.infusionLogs.asMap().entries.map((e) {
                  final i = e.key;
                  final log = e.value;
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: i < session.infusionLogs.length - 1
                          ? SteapLeafSpacing.xs
                          : 0,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 28,
                          child: Text(
                            '${log.infusionNumber}.',
                            style: SteapLeafTextTheme.brewParameter.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        Text(
                          '${log.tempActual} °C',
                          style: SteapLeafTextTheme.brewParameter.copyWith(
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: SteapLeafSpacing.sm),
                        _TimeCell(label: 'Geplant', time: log.plannedTime),
                        const SizedBox(width: SteapLeafSpacing.xs),
                        _TimeCell(
                          label: 'Tatsächlich',
                          time: log.actualTime,
                          highlight: log.actualTime > log.plannedTime,
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ],

          // ── Notiz ───────────────────────────────────────────────────────
          if (session.notes != null && session.notes!.isNotEmpty) ...[
            _divider(),
            _SectionLabel('Notiz'),
            const SizedBox(height: SteapLeafSpacing.xs),
            WashiCard(
              child: Text(
                session.notes!,
                style: textTheme.bodyMedium?.copyWith(height: 1.6),
              ),
            ),
          ],
        ],
      ),
    );
  }

  static Widget _divider() => const Padding(
        padding: EdgeInsets.symmetric(vertical: SteapLeafSpacing.lg),
        child: DashedDivider(),
      );

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await ConfirmDialog.show(
      context,
      title: 'Session löschen?',
      message: 'Diese Session wird dauerhaft entfernt.',
    );
    if (!confirmed || !context.mounted) return;
    context.read<SessionProvider>().deleteSession(session.id);
    Navigator.pop(context);
  }
}

// ---------------------------------------------------------------------------

class _TeaInfoCard extends StatelessWidget {
  final Tea tea;
  const _TeaInfoCard({required this.tea});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('Verwendeter Tee'),
        const SizedBox(height: SteapLeafSpacing.xs),
        WashiCard(
          accentCorners: true,
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TeaDetailScreen(teaId: tea.id, tea: tea),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (tea.origin != null || tea.vendor != null)
                          Text(
                            [tea.origin, tea.vendor]
                                .whereType<String>()
                                .join(' · '),
                            style: textTheme.labelSmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (tea.rating > 0)
                    StarRating(rating: tea.rating, size: 13),
                ],
              ),
              if (tea.tags.isNotEmpty) ...[
                const SizedBox(height: SteapLeafSpacing.xs),
                Wrap(
                  spacing: SteapLeafSpacing.tiny,
                  runSpacing: SteapLeafSpacing.tiny,
                  children: tea.tags.map((tag) => RawChip(
                    label: Text(tag),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                    backgroundColor: Colors.transparent,
                    side: BorderSide(
                        color: colorScheme.outlineVariant, width: 0.5,),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    padding: EdgeInsets.zero,
                    labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  )).toList(),
                ),
              ],
              const SizedBox(height: SteapLeafSpacing.xs),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(Icons.arrow_forward,
                      size: 14, color: colorScheme.primary,),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) => Text(
        text.toUpperCase(),
        style: SteapLeafTextTheme.sectionLabel.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
      );
}

class _TimeCell extends StatelessWidget {
  final String label;
  final Duration time;
  final bool highlight;
  const _TimeCell({
    required this.label,
    required this.time,
    this.highlight = false,
  });

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: SteapLeafTextTheme.sectionLabel.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
        Text(
          _fmt(time),
          style: SteapLeafTextTheme.brewParameter.copyWith(
            color: highlight ? colorScheme.error : colorScheme.onSurfaceVariant,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}
