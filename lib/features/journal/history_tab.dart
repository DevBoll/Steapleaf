import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../domain/enums/enums.dart';
import '../../theme/steapleaf_theme.dart';
import 'manual_session_screen.dart';
import 'session_provider.dart';
import 'widgets/session_tile.dart';


class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});

  @override
  State<HistoryTab> createState() => _HistoryTabState();
}

class _HistoryTabState extends State<HistoryTab> {
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  TeaType? _filterType;
  int? _filterRating;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(builder: (context, provider, _) {
      var sessions = provider.sessions;

      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        sessions = sessions
            .where((s) => s.teaName.toLowerCase().contains(q))
            .toList();
      }
      if (_filterType != null) {
        sessions = sessions.where((s) => s.teaType == _filterType).toList();
      }
      if (_filterRating != null) {
        sessions = sessions.where((s) => s.rating == _filterRating).toList();
      }

      final hasFilters =
          _searchQuery.isNotEmpty || _filterType != null || _filterRating != null;

      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              SteapLeafSpacing.md, SteapLeafSpacing.sm,
              SteapLeafSpacing.md, SteapLeafSpacing.xs,
            ),
            child: Semantics(
              label: 'Session suchen',
              child: TextField(
                controller: _searchCtrl,
                decoration: const InputDecoration(
                  hintText: 'Tee-Name suchen …',
                  prefixIcon: Icon(Icons.search, size: 20),
                ),
                onChanged: (v) => setState(() => _searchQuery = v.trim()),
              ),
            ),
          ),
          _FilterRow(
            filterType: _filterType,
            filterRating: _filterRating,
            onTypeChanged: (t) => setState(() => _filterType = t),
            onRatingChanged: (r) => setState(() => _filterRating = r),
          ),
          Expanded(
            child: sessions.isEmpty
                ? _EmptyState(
                    hasActiveFilters: hasFilters,
                    onAdd: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ManualSessionScreen()),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      SteapLeafSpacing.md, SteapLeafSpacing.tiny,
                      SteapLeafSpacing.md,
                      SteapLeafSpacing.xxl + SteapLeafSpacing.fabSize,
                    ),
                    itemCount: sessions.length,
                    separatorBuilder: (_, _) => const DashedDivider(),
                    itemBuilder: (_, i) => SessionTile(sessions[i]),
                  ),
          ),
        ],
      );
    });
  }
}

class _FilterRow extends StatelessWidget {
  final TeaType? filterType;
  final int? filterRating;
  final ValueChanged<TeaType?> onTypeChanged;
  final ValueChanged<int?> onRatingChanged;

  const _FilterRow({
    required this.filterType,
    required this.filterRating,
    required this.onTypeChanged,
    required this.onRatingChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SteapLeafSpacing.md, 0,
        SteapLeafSpacing.md, SteapLeafSpacing.xs,
      ),
      child: Row(
        children: [
          _TypeDropdown(
            selected: filterType,
            onChanged: onTypeChanged,
          ),
          const SizedBox(width: SteapLeafSpacing.xs),
          _RatingDropdown(
            selected: filterRating,
            onChanged: onRatingChanged,
          ),
        ],
      ),
    );
  }
}

class _TypeDropdown extends StatelessWidget {
  final TeaType? selected;
  final ValueChanged<TeaType?> onChanged;
  const _TypeDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isActive = selected != null;

    return PopupMenuButton<TeaType?>(
      initialValue: selected,
      onSelected: (type) => onChanged(selected == type ? null : type),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: null,
          onTap: () => onChanged(null),
          child: Text(
            'Alle Sorten',
            style: textTheme.bodySmall?.copyWith(
              color: selected == null
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
          ),
        ),
        ...TeaType.values.map((t) => PopupMenuItem(
              value: t,
              child: Text(
                t.label,
                style: textTheme.bodySmall?.copyWith(
                  color: selected == t ? t.color : colorScheme.onSurface,
                ),
              ),
            )),
      ],
      child: _DropdownChip(
        label: isActive ? selected!.label : 'Sorte',
        isActive: isActive,
        activeColor: isActive ? selected!.color : null,
      ),
    );
  }
}

class _RatingDropdown extends StatelessWidget {
  final int? selected;
  final ValueChanged<int?> onChanged;
  const _RatingDropdown({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final isActive = selected != null;

    return PopupMenuButton<int?>(
      initialValue: selected,
      onSelected: (r) => onChanged(selected == r ? null : r),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: null,
          onTap: () => onChanged(null),
          child: Text(
            'Alle Bewertungen',
            style: textTheme.bodySmall?.copyWith(
              color: selected == null
                  ? colorScheme.primary
                  : colorScheme.onSurface,
            ),
          ),
        ),
        ...[1, 2, 3, 4, 5].map((r) => PopupMenuItem(
              value: r,
              child: Text(
                '★ $r',
                style: textTheme.bodySmall?.copyWith(
                  color: selected == r
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
            )),
      ],
      child: _DropdownChip(
        label: isActive ? '★ $selected' : 'Bewertung',
        isActive: isActive,
        activeColor: isActive ? colorScheme.primary : null,
      ),
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final Color? activeColor;

  const _DropdownChip({
    required this.label,
    required this.isActive,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final color = activeColor ?? (isActive ? colorScheme.primary : null);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive
            ? (activeColor?.withValues(alpha: 0.15) ??
                colorScheme.primaryContainer)
            : colorScheme.surfaceContainerHigh,
        border: Border.all(
          color: isActive
              ? (activeColor ?? colorScheme.primary)
              : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: textTheme.labelMedium?.copyWith(
              color: color ?? colorScheme.onSurface,
            ),
          ),
          const SizedBox(width: 2),
          Icon(
            Icons.arrow_drop_down,
            size: 16,
            color: color ?? colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  final bool hasActiveFilters;
  final VoidCallback onAdd;

  const _EmptyState({required this.hasActiveFilters, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme   = Theme.of(context).textTheme;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.local_cafe_outlined,
              size: 48, color: colorScheme.outlineVariant),
          const SizedBox(height: SteapLeafSpacing.md),
          Text(
            hasActiveFilters ? 'Keine Treffer' : 'Noch keine Sessions',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          if (!hasActiveFilters) ...[
            const SizedBox(height: SteapLeafSpacing.lg),
            OutlinedButton(
              onPressed: onAdd,
              child: const Text('Erste Session erfassen'),
            ),
          ],
        ],
      ),
    );
  }
}
