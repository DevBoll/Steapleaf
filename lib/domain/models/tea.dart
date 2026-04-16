import 'dart:convert';
import '../enums/enums.dart';
import 'tasting_profile.dart';
import 'brew_variant.dart';

class Tea {
  final String id;
  final String name;
  final TeaType type;
  final String? origin;
  final String? vendor;
  final bool inStock;
  final String? photoTeaPath;
  final String? photoLabelPath;
  final String? notes;
  final int rating;
  final bool isFavorite;
  final List<String> tags;
  final TastingProfile tastingProfile;
  final List<BrewVariant> brewVariants;
  final String? defaultVariantId;
  final DateTime createdAt;

  const Tea({
    required this.id,
    required this.name,
    required this.type,
    this.origin,
    this.vendor,
    this.inStock = true,
    this.photoTeaPath,
    this.photoLabelPath,
    this.notes,
    this.rating = 0,
    this.isFavorite = false,
    this.tags = const [],
    required this.tastingProfile,
    this.brewVariants = const [],
    this.defaultVariantId,
    required this.createdAt,
  });

  Tea copyWith({
    String? id,
    String? name,
    TeaType? type,
    String? origin,
    String? vendor,
    bool? inStock,
    String? photoTeaPath,
    String? photoLabelPath,
    String? notes,
    int? rating,
    bool? isFavorite,
    List<String>? tags,
    TastingProfile? tastingProfile,
    List<BrewVariant>? brewVariants,
    Object? defaultVariantId = _keep,
    DateTime? createdAt,
  }) {
    return Tea(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      origin: origin ?? this.origin,
      vendor: vendor ?? this.vendor,
      inStock: inStock ?? this.inStock,
      photoTeaPath: photoTeaPath ?? this.photoTeaPath,
      photoLabelPath: photoLabelPath ?? this.photoLabelPath,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      isFavorite: isFavorite ?? this.isFavorite,
      tags: tags ?? this.tags,
      tastingProfile: tastingProfile ?? this.tastingProfile,
      brewVariants: brewVariants ?? this.brewVariants,
      defaultVariantId: identical(defaultVariantId, _keep)
          ? this.defaultVariantId
          : defaultVariantId as String?,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  static const Object _keep = Object();

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'type': type.name,
        'origin': origin,
        'vendor': vendor,
        'inStock': inStock ? 1 : 0,
        'photoTeaPath': photoTeaPath,
        'photoLabelPath': photoLabelPath,
        'notes': notes,
        'rating': rating,
        'isFavorite': isFavorite ? 1 : 0,
        'tags': jsonEncode(tags),
        'flavorProfile': jsonEncode(tastingProfile.toJson()),
        'brewVariants':
            jsonEncode(brewVariants.map((e) => e.toJson()).toList()),
        'defaultVariantId': defaultVariantId,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Tea.fromMap(Map<String, dynamic> map) => Tea(
        id: map['id'] as String,
        name: map['name'] as String,
        type: TeaType.fromString(map['type'] as String? ?? 'green'),
        origin: map['origin'] as String?,
        vendor: map['vendor'] as String?,
        inStock: (map['inStock'] as int? ?? 1) == 1,
        photoTeaPath: map['photoTeaPath'] as String?,
        photoLabelPath: map['photoLabelPath'] as String?,
        notes: map['notes'] as String?,
        rating: map['rating'] as int? ?? 0,
        isFavorite: (map['isFavorite'] as int? ?? 0) == 1,
        tags: List<String>.from(
            jsonDecode(map['tags'] as String? ?? '[]') as List,),
        tastingProfile: TastingProfile.fromJson(
            jsonDecode(map['flavorProfile'] as String? ?? '{}') as Map<String, dynamic>),
        brewVariants:
            (jsonDecode(map['brewVariants'] as String? ?? '[]') as List)
                .map((e) => BrewVariant.fromJson(e as Map<String, dynamic>))
                .toList(),
        defaultVariantId: map['defaultVariantId'] as String?,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}
