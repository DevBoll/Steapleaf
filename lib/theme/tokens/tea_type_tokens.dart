import 'package:flutter/material.dart';

/// Farb-Set für einen einzelnen Tee-Typ.
@immutable
class TeaTypeColors {
  const TeaTypeColors({
    required this.container,
    required this.onContainer,
    required this.badge,
  });

  final Color container;
  final Color onContainer;
  final Color badge;

  /// Erzeugt eine [TeaTypeColors] Instanz für Dark Theme.
  TeaTypeColors darkened() => TeaTypeColors(
        container: HSLColor.fromColor(container)
            .withLightness(
                (HSLColor.fromColor(container).lightness - 0.35).clamp(0.1, 1.0))
            .toColor(),
        onContainer: HSLColor.fromColor(onContainer)
            .withLightness(
                (HSLColor.fromColor(onContainer).lightness + 0.5).clamp(0.0, 1.0))
            .toColor(),
        badge: HSLColor.fromColor(badge)
            .withLightness(
                (HSLColor.fromColor(badge).lightness + 0.4).clamp(0.0, 1.0))
            .toColor(),
      );
}

/// Alle 9 Teetyp-Farbpaletten für SteapLeaf.
///
/// Verwendung:
/// ```dart
/// final colors = TeaTypeTokens.forType(TeaType.green);
/// Container(color: colors.container, child: Text('Grün', style: TextStyle(color: colors.badge)));
/// ```
abstract final class TeaTypeTokens {
  TeaTypeTokens._();

  static const TeaTypeColors green = TeaTypeColors(
    container:   Color(0xFFC8DDB4),
    onContainer: Color(0xFF1C3A0E),
    badge:       Color(0xFF2D5A27),
  );

  static const TeaTypeColors black = TeaTypeColors(
    container:   Color(0xFFC4AFA5),
    onContainer: Color(0xFF2C1A14),
    badge:       Color(0xFF5C3728),
  );

  static const TeaTypeColors oolong = TeaTypeColors(
    container:   Color(0xFFD4BA8A),
    onContainer: Color(0xFF3A2800),
    badge:       Color(0xFF6B4F10),
  );

  static const TeaTypeColors white = TeaTypeColors(
    container:   Color(0xFFE8E0D0),
    onContainer: Color(0xFF2A2418),
    badge:       Color(0xFF6B6459),
  );

  static const TeaTypeColors puerh = TeaTypeColors(
    container:   Color(0xFFB89080),
    onContainer: Color(0xFF280E08),
    badge:       Color(0xFF5C2E20),
  );

  static const TeaTypeColors herbal = TeaTypeColors(
    container:   Color(0xFFB8D4B0),
    onContainer: Color(0xFF0F2E14),
    badge:       Color(0xFF2A5430),
  );

  static const TeaTypeColors fruit = TeaTypeColors(
    container:   Color(0xFFF0C4A0),
    onContainer: Color(0xFF3C1600),
    badge:       Color(0xFF8B3A0A),
  );

  static const TeaTypeColors rooibos = TeaTypeColors(
    container:   Color(0xFFD4A898),
    onContainer: Color(0xFF38100A),
    badge:       Color(0xFF7A2E22),
  );

  static const TeaTypeColors yellow = TeaTypeColors(
  container:   Color(0xFFE8D890),
  onContainer: Color(0xFF2E2400),
  badge:       Color(0xFF7A6010),
);

  /// Für externe Tees ohne definierten Typ.
  static const TeaTypeColors custom = TeaTypeColors(
    container:   Color(0xFFC8C0B8),
    onContainer: Color(0xFF1A1714),
    badge:       Color(0xFF6B6459),
  );

  /// Gibt die passenden Farben für einen Teetyp zurück.
  static TeaTypeColors forType(TeaType type) {
    return switch (type) {
      TeaType.green   => green,
      TeaType.black   => black,
      TeaType.oolong  => oolong,
      TeaType.white   => white,
      TeaType.puerh   => puerh,
      TeaType.herbal  => herbal,
      TeaType.fruit   => fruit,
      TeaType.rooibos => rooibos,
      TeaType.yellow => yellow,
      TeaType.custom  => custom,
    };
  }
}

enum TeaType {
  green,
  black,
  oolong,
  white,
  puerh,
  herbal,
  fruit,
  rooibos,
  yellow,
  custom;

  String get label => switch (this) {
    TeaType.green   => 'Grün',
    TeaType.black   => 'Schwarz',
    TeaType.oolong  => 'Oolong',
    TeaType.white   => 'Weiß',
    TeaType.puerh   => 'Pu-Erh',
    TeaType.herbal  => 'Kräuter',
    TeaType.fruit   => 'Früchte',
    TeaType.yellow => 'Gelb',
    TeaType.rooibos => 'Rooibos',
    TeaType.custom  => 'Extern',
  };

  /// Kanji-Icon für diesen Teetyp.
  String get kanji => switch (this) {
    TeaType.green   => '緑',
    TeaType.black   => '黒',
    TeaType.oolong  => '青',
    TeaType.white   => '白',
    TeaType.puerh   => '普',
    TeaType.herbal  => '草',
    TeaType.fruit   => '果',
    TeaType.rooibos => '赤',
    TeaType.yellow => '黄',
    TeaType.custom  => '外',
  };
}
