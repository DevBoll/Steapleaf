import 'package:flutter/material.dart';


abstract final class SteapLeafShapes {
  SteapLeafShapes._();

  // ─── M3 Shape Scale ───────────────────────────────────────────────────────

  /// 0dp – Volle Kanten (Divider, Image-Assets)
  static const RoundedRectangleBorder none = RoundedRectangleBorder();

  /// extraSmall – Badges, Teetyp-Badge
  static const RoundedRectangleBorder extraSmall = RoundedRectangleBorder();

  /// small – Chips, Outlined Buttons, kleine Cards
  static const RoundedRectangleBorder small = RoundedRectangleBorder();

  /// medium – Standard-Cards (Brüh-Card, Last-Session-Card), Textfelder
  static const RoundedRectangleBorder medium = RoundedRectangleBorder();

  /// large – Bottom Sheets, Modal-Dialoge
  static const RoundedRectangleBorder large = RoundedRectangleBorder();

  /// extraLarge – FAB
  static const RoundedRectangleBorder extraLarge = RoundedRectangleBorder();

  /// full – Filled/Tonal/Text Buttons, Avatar-Kreise
  static const RoundedRectangleBorder full = RoundedRectangleBorder();

  // ─── BorderRadius Varianten (für direkte Nutzung in ClipRRect etc.) ───────

  static const BorderRadius radiusNone       = BorderRadius.zero;
  static const BorderRadius radiusExtraSmall = BorderRadius.zero;
  static const BorderRadius radiusSmall      = BorderRadius.zero;
  static const BorderRadius radiusMedium     = BorderRadius.zero;
  static const BorderRadius radiusLarge      = BorderRadius.zero;
  static const BorderRadius radiusExtraLarge = BorderRadius.zero;
  static const BorderRadius radiusFull       = BorderRadius.zero;

  // ─── SteapLeaf Komponenten-spezifisch ─────────────────────────────────────

  /// Tee-Avatar
  static const BorderRadius avatar = BorderRadius.zero;

  /// Timer-Kreis auf dem Timer-Screen
  static const BorderRadius timerCircle = BorderRadius.zero;

  /// Hero-Bild auf Tee-Detailseite
  static const BorderRadius heroImage = BorderRadius.zero;

  /// Bottom Sheet
  static const BorderRadius bottomSheet = BorderRadius.zero;

  /// Handwriting-Underline: kein Radius (ist eine Linie)
  static const BorderRadius brandLine = BorderRadius.zero;
}
