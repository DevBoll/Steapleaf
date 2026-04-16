import 'dart:convert';
import '../enums/enums.dart';
import 'infusion_spec.dart';

class BrewVariant {
  final String id;
  final String label;
  final BrewStyle style;
  final double? dosageGrams;
  final int? waterMl;
  final List<InfusionSpec> infusions;
  final List<String> additions;

 
  final bool hasRinse;
  final List<InfusionSpec> rinseInfusions;

  final bool isFridgeBrew;

  final String? customNotes;

  const BrewVariant({
    required this.id,
    required this.label,
    required this.style,
    this.dosageGrams,
    this.waterMl,
    required this.infusions,
    this.additions = const [],
    this.hasRinse = false,
    this.rinseInfusions = const [],
    this.isFridgeBrew = false,
    this.customNotes,
  });

  BrewVariant copyWith({
    String? id,
    String? label,
    BrewStyle? style,
    double? dosageGrams,
    int? waterMl,
    List<InfusionSpec>? infusions,
    List<String>? additions,
    bool? hasRinse,
    List<InfusionSpec>? rinseInfusions,
    bool? isFridgeBrew,
    Object? customNotes = _keep,
  }) {
    return BrewVariant(
      id: id ?? this.id,
      label: label ?? this.label,
      style: style ?? this.style,
      dosageGrams: dosageGrams ?? this.dosageGrams,
      waterMl: waterMl ?? this.waterMl,
      infusions: infusions ?? this.infusions,
      additions: additions ?? this.additions,
      hasRinse: hasRinse ?? this.hasRinse,
      rinseInfusions: rinseInfusions ?? this.rinseInfusions,
      isFridgeBrew: isFridgeBrew ?? this.isFridgeBrew,
      customNotes: identical(customNotes, _keep)
          ? this.customNotes
          : customNotes as String?,
    );
  }

  static const Object _keep = Object();

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'style': style.name,
        'dosageGrams': dosageGrams,
        'waterMl': waterMl,
        'infusions': infusions.map((e) => e.toJson()).toList(),
        'additions': additions,
        'hasRinse': hasRinse,
        'rinseInfusions': rinseInfusions.map((e) => e.toJson()).toList(),
        'isFridgeBrew': isFridgeBrew,
        'customNotes': customNotes,
      };

  factory BrewVariant.fromJson(Map<String, dynamic> json) => BrewVariant(
        id: json['id'] as String? ?? '',
        label: json['label'] as String? ?? '',
        style: BrewStyle.fromString(json['style'] as String? ?? 'western'),
        dosageGrams: (json['dosageGrams'] as num?)?.toDouble(),
        waterMl: json['waterMl'] as int?,
        infusions: (json['infusions'] as List? ?? [])
            .map((e) => InfusionSpec.fromJson(e as Map<String, dynamic>))
            .toList(),
        additions: List<String>.from(json['additions'] as List? ?? []),
        hasRinse: json['hasRinse'] as bool? ?? false,
        rinseInfusions: (json['rinseInfusions'] as List? ?? [])
            .map((e) => InfusionSpec.fromJson(e as Map<String, dynamic>))
            .toList(),
        isFridgeBrew: json['isFridgeBrew'] as bool? ?? false,
        customNotes: json['customNotes'] as String?,
      );

  String toJsonString() => jsonEncode(toJson());

  factory BrewVariant.fromJsonString(String json) =>
      BrewVariant.fromJson(jsonDecode(json) as Map<String, dynamic>);
}
