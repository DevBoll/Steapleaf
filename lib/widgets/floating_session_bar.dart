import 'package:flutter/material.dart';
import 'package:steapleaf/theme/steapleaf_theme.dart';

/// Schwebende Leiste, die eine laufende Brüh-Session anzeigt.
///
/// Erscheint am unteren Rand des Body, oberhalb der [NavigationBar],
/// wenn eine Session aktiv ist. Der Nutzer kann die Session von hier
/// aus antippen, um sie zu öffnen.
class FloatingSessionBar extends StatelessWidget {
  final String teaName;
  final String remainingTime;
  final VoidCallback onTap;

  const FloatingSessionBar({
    super.key,
    required this.teaName,
    required this.remainingTime,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SteapLeafSpacing.md,
        vertical: SteapLeafSpacing.sm,
      ),
      child: Material(
        color: colorScheme.outline,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SteapLeafSpacing.md,
              vertical: SteapLeafSpacing.sm,
            ),
            child: Row(
              children: [
                Text(
                  SteapLeafKanji.tea.character,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(width: SteapLeafSpacing.sm),
                Expanded(
                  child: Text(
                    teaName,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  remainingTime,
                  style: textTheme.titleMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
