import 'package:flutter/material.dart';
import 'package:steapleaf/theme/tokens/tea_type_tokens.dart';
import 'package:steapleaf/theme/tokens/kanji_tokens.dart';


enum TeaType {
  green,
  black,
  oolong,
  white,
  yellow,
  puerh,
  herbal,
  fruit,
  rooibos,
  custom;

  String get label => switch (this) {
    TeaType.green   => 'Grün',
    TeaType.black   => 'Schwarz',
    TeaType.oolong  => 'Oolong',
    TeaType.white   => 'Weiß',
    TeaType.yellow  => 'Gelb',
    TeaType.puerh   => 'Pu-Erh',
    TeaType.herbal  => 'Kräuter',
    TeaType.fruit   => 'Früchte',
    TeaType.rooibos => 'Rooibos',
    TeaType.custom  => 'Extern'
  };

  /// Vollständiges Farb-Set aus dem Theme (container, onContainer, badge).
  TeaTypeColors get colors => switch (this) {
    TeaType.green   => TeaTypeTokens.green,
    TeaType.black   => TeaTypeTokens.black,
    TeaType.oolong  => TeaTypeTokens.oolong,
    TeaType.white   => TeaTypeTokens.white,
    TeaType.yellow  => TeaTypeTokens.yellow,
    TeaType.puerh   => TeaTypeTokens.puerh,
    TeaType.herbal  => TeaTypeTokens.herbal,
    TeaType.fruit   => TeaTypeTokens.fruit,
    TeaType.rooibos => TeaTypeTokens.rooibos,
    TeaType.custom => TeaTypeTokens.custom,
  };

  /// Kennfarbe für Badges und Chips.
  Color get color => colors.badge;

  /// Textfarbe auf der Kennfarbe.
  Color get textColor => colors.onContainer;

  /// Kanji-Symbol aus der SteapLeaf-Kanji-Bibliothek.
  String get kanji => switch (this) {
    TeaType.green   => SteapLeafKanji.typeGreen.character,
    TeaType.black   => SteapLeafKanji.typeBlack.character,
    TeaType.oolong  => SteapLeafKanji.typeOolong.character,
    TeaType.white   => SteapLeafKanji.typeWhite.character,
    TeaType.yellow  => SteapLeafKanji.typeYellow.character,
    TeaType.puerh   => SteapLeafKanji.typePuerh.character,
    TeaType.herbal  => SteapLeafKanji.typeHerbal.character,
    TeaType.fruit   => SteapLeafKanji.typeFruit.character,
    TeaType.rooibos => SteapLeafKanji.typeRooibos.character,
    TeaType.custom => SteapLeafKanji.typeCustom.character,
  };

  /// Empfohlene Brühtemperatur als Standardwert
  int get defaultTemp => switch (this) {
    TeaType.green   => 70,
    TeaType.yellow  => 75,
    TeaType.white   => 75,
    TeaType.oolong  => 85,
    TeaType.black   => 95,
    TeaType.puerh   => 95,
    TeaType.herbal  => 100,
    TeaType.fruit   => 100,
    TeaType.rooibos => 100,
    TeaType.custom => 100,
  };

  /// Empfohlene Ziehzeit als Standardwert
  Duration get defaultSteepTime => switch (this) {
    TeaType.green   => const Duration(minutes: 2),
    TeaType.yellow  => const Duration(minutes: 2),
    TeaType.black   => const Duration(minutes: 3),
    TeaType.oolong  => const Duration(minutes: 3),
    TeaType.puerh   => const Duration(minutes: 3),
    TeaType.white   => const Duration(minutes: 4),
    TeaType.herbal  => const Duration(minutes: 5),
    TeaType.fruit   => const Duration(minutes: 5),
    TeaType.rooibos => const Duration(minutes: 5),
    TeaType.custom => const Duration(minutes: 3),
  };

  static TeaType fromString(String value) {
    return TeaType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => TeaType.green,
    );
  }
}

/// Zubereitungsstil, der Wassermenge und Aufgussanzahl bestimmt.
///
/// Beeinflusst die Vorschlagswerte für Gramm pro Liter und Ziehzeit
/// beim Anlegen einer neuen Session.
enum BrewStyle {
  western,
  gongfu,
  coldBrew,
  custom;

  String get label => switch (this) {
    BrewStyle.western  => 'Westlich',
    BrewStyle.gongfu   => 'Gong Fu',
    BrewStyle.coldBrew => 'Cold Brew',
    BrewStyle.custom   => 'Benutzerdefiniert',
  };

  static BrewStyle fromString(String value) {
    return BrewStyle.values.firstWhere(
      (e) => e.name == value,
      orElse: () => BrewStyle.western,
    );
  }
}

const List<String> kStandardAdditions = [
  'Milch',
  'Zucker',
  'Honig',
  'Zitrone',
  'Kondensmilch',
];
