import 'package:flutter/material.dart';
import 'steapleaf_theme.dart';

// ─── BuildContext Extension ───────────────────────────────────────────────────
//
// Convenience-Extension für schnellen Zugriff auf Theme-Tokens.
//
// Verwendung:
//   context.steapLeaf.brandLine
//   context.colorScheme.primary
//   context.textTheme.headlineLarge
//
extension SteapLeafContext on BuildContext {
  /// Zugriff auf die SteapLeaf-spezifische ThemeExtension.
  SteapLeafThemeExtension get steapLeaf =>
      Theme.of(this).extension<SteapLeafThemeExtension>()!;

  /// Kurzform für Theme.of(context).colorScheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Kurzform für Theme.of(context).textTheme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// True wenn aktuell Dark Mode aktiv ist.
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}

// ─── USAGE EXAMPLES ──────────────────────────────────────────────────────────
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ 1. MaterialApp einrichten                                               │
// └─────────────────────────────────────────────────────────────────────────┘
//
// MaterialApp(
//   title: 'SteapLeaf',
//   theme:      SteapLeafTheme.light,
//   darkTheme:  SteapLeafTheme.dark,
//   themeMode:  ThemeMode.system,
//   home: const HomeScreen(),
// );
//
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ 2. System-Tokens via ColorScheme (empfohlen für Standard-Elemente)      │
// └─────────────────────────────────────────────────────────────────────────┘
//
// Container(
//   color: context.colorScheme.surface,
//   child: Text(
//     'Toller Tee',
//     style: context.textTheme.headlineLarge?.copyWith(
//       color: context.colorScheme.onSurface,
//     ),
//   ),
// );
//
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ 3. Custom Brand-Tokens via Extension                                    │
// └─────────────────────────────────────────────────────────────────────────┘
//
// // Handwriting-Underline unter Screen-Titel:
// Container(
//   height: SteapLeafSpacing.brandLineHeight,
//   color: context.steapLeaf.brandLine,
// );
//
// // Dekoratives Kanji im Header:
// Text(
//   '茶',
//   style: SteapLeafTextTheme.kanjiDecorative().copyWith(
//     color: context.steapLeaf.kanjiDecorative,
//   ),
// );
//
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ 4. Teetyp-Farben                                                        │
// └─────────────────────────────────────────────────────────────────────────┘
//
// final colors = context.steapLeaf.colorsForType(tea.type);
//
// // Avatar-Hintergrund:
// CircleAvatar(
//   backgroundColor: colors.container,
//   child: Text(
//     tea.type.kanji,
//     style: SteapLeafTextTheme.kanjiAvatar().copyWith(
//       color: colors.onContainer,
//     ),
//   ),
// );
//
// // Teetyp-Badge:
// Container(
//   decoration: BoxDecoration(
//     color: colors.container,
//     borderRadius: SteapLeafShapes.radiusExtraSmall,
//   ),
//   padding: const EdgeInsets.symmetric(
//     horizontal: SteapLeafSpacing.xs,
//     vertical: SteapLeafSpacing.tiny,
//   ),
//   child: Text(
//     tea.type.label,
//     style: context.textTheme.labelSmall?.copyWith(color: colors.badge),
//   ),
// );
//
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ 5. Animationen mit Motion-Tokens                                        │
// └─────────────────────────────────────────────────────────────────────────┘
//
// AnimatedContainer(
//   duration: SteapLeafMotion.tabSwitch,
//   curve: SteapLeafMotion.standard,
//   color: isSelected
//     ? context.colorScheme.primaryContainer
//     : context.colorScheme.surface,
// );
//
// // Screen-Transition:
// Navigator.of(context).push(
//   PageRouteBuilder(
//     transitionDuration: SteapLeafMotion.screenTransition,
//     pageBuilder: (_, __, ___) => const TeaDetailScreen(),
//     transitionsBuilder: (_, animation, __, child) =>
//       FadeTransition(
//         opacity: CurvedAnimation(
//           parent: animation,
//           curve: SteapLeafMotion.enter,
//         ),
//         child: child,
//       ),
//   ),
// );
//
//
// ┌─────────────────────────────────────────────────────────────────────────┐
// │ 6. Spacing                                                              │
// └─────────────────────────────────────────────────────────────────────────┘
//
// Padding(
//   padding: const EdgeInsets.symmetric(
//     horizontal: SteapLeafSpacing.screenPaddingHorizontal,
//   ),
//   child: Column(
//     children: [
//       const SizedBox(height: SteapLeafSpacing.xl),
//       TeaCard(),
//       const SizedBox(height: SteapLeafSpacing.sm),
//       TeaCard(),
//     ],
//   ),
// );
