import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/infusion_entry.dart';
import '../../../theme/steapleaf_theme.dart';

// Layout-Maße dieser Komponente
const double _badgeSize     = 22;
const double _tempFieldWidth = 54;
const double _timeFieldWidth = 44;

/// Card-Zeile für einen manuell erfassten Aufguss.
///
/// Zeigt: Aufguss-Nummer (Kreis) · Temp · Min : Sek · Löschen-Button.
/// [onChanged] wird bei jeder Eingabe aufgerufen — für dirty-tracking.
class InfusionRow extends StatelessWidget {
  final int index;
  final InfusionEntry entry;
  final bool canDelete;
  final VoidCallback onDelete;

  /// Optional: wird bei jeder Feldänderung aufgerufen (z.B. `_markDirty`).
  final VoidCallback? onChanged;

  const InfusionRow({
    super.key,
    required this.index,
    required this.entry,
    required this.canDelete,
    required this.onDelete,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: SteapLeafSpacing.xs),
      child: Material(
        color: colorScheme.surfaceContainerLow,
        shape: Border.fromBorderSide(
          BorderSide(color: colorScheme.outlineVariant, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 8, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Nummer ──────────────────────────────────────────────────
              Container(
                width: _badgeSize,
                height: _badgeSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${index + 1}',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary,
                  ),
                ),
              ),
              const SizedBox(width: SteapLeafSpacing.sm),

              // ── Temperatur ───────────────────────────────────────────────
              _InfusionNumField(
                controller: entry.tempCtrl,
                label: '°C',
                width: _tempFieldWidth,
                min: 30,
                max: 100,
                onChanged: onChanged,
              ),
              const SizedBox(width: SteapLeafSpacing.sm),

              // ── Minuten ──────────────────────────────────────────────────
              _InfusionNumField(
                controller: entry.minCtrl,
                label: 'min',
                width: _timeFieldWidth,
                min: 0,
                max: 99,
                onChanged: onChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: SteapLeafSpacing.tiny,),
                child: Text(
                  ':',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ),

              // ── Sekunden ─────────────────────────────────────────────────
              _InfusionNumField(
                controller: entry.secCtrl,
                label: 'sek',
                width: _timeFieldWidth,
                min: 0,
                max: 59,
                onChanged: onChanged,
              ),

              const Spacer(),

              // ── Löschen ──────────────────────────────────────────────────
              if (canDelete)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.remove_circle_outline),
                  iconSize: 20,
                  color: colorScheme.onSurfaceVariant,
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfusionNumField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final double width;
  final int min;
  final int max;
  final VoidCallback? onChanged;

  const _InfusionNumField({
    required this.controller,
    required this.label,
    required this.width,
    required this.min,
    required this.max,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          _RangeFormatter(min: min, max: max),
        ],
        onChanged: onChanged != null ? (_) => onChanged!() : null,
        style: SteapLeafTextTheme.brewParameter,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}

class _RangeFormatter extends TextInputFormatter {
  final int min;
  final int max;
  const _RangeFormatter({required this.min, required this.max});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue,) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value == null) return oldValue;
    if (value < min) return newValue.copyWith(text: min.toString());
    if (value > max) return newValue.copyWith(text: max.toString());
    return newValue;
  }
}
