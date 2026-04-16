import 'dart:convert';
import 'enums.dart';
import 'brew_variant.dart';
import 'infusion_log.dart';

class Session {
  final String id;
  final DateTime dateTime;
  final String? teaId;
  final String teaName;
  final TeaType teaType;
  final BrewVariant? brewVariant;
  final List<InfusionLog> infusionLogs;
  final List<String> additions;
  final String? notes;
  final int rating;
  final bool isManual;

  const Session({
    required this.id,
    required this.dateTime,
    this.teaId,
    required this.teaName,
    required this.teaType,
    this.brewVariant,
    this.infusionLogs = const [],
    this.additions = const [],
    this.notes,
    this.rating = 0,
    this.isManual = false,
  });

  Session copyWith({
    String? id,
    DateTime? dateTime,
    String? teaId,
    String? teaName,
    TeaType? teaType,
    BrewVariant? brewVariant,
    List<InfusionLog>? infusionLogs,
    List<String>? additions,
    String? notes,
    int? rating,
    bool? isManual,
  }) {
    return Session(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      teaId: teaId ?? this.teaId,
      teaName: teaName ?? this.teaName,
      teaType: teaType ?? this.teaType,
      brewVariant: brewVariant ?? this.brewVariant,
      infusionLogs: infusionLogs ?? this.infusionLogs,
      additions: additions ?? this.additions,
      notes: notes ?? this.notes,
      rating: rating ?? this.rating,
      isManual: isManual ?? this.isManual,
    );
  }

  Map<String, dynamic> toMap() => {
        'id': id,
        'dateTime': dateTime.toIso8601String(),
        'teaId': teaId,
        'teaName': teaName,
        'teaType': teaType.name,
        'brewVariant':
            brewVariant != null ? jsonEncode(brewVariant!.toJson()) : null,
        'infusionLogs': InfusionLog.listToJson(infusionLogs),
        'additions': jsonEncode(additions),
        'notes': notes,
        'rating': rating,
        'isManual': isManual ? 1 : 0,
      };

  factory Session.fromMap(Map<String, dynamic> map) => Session(
        id: map['id'] as String,
        dateTime: DateTime.parse(map['dateTime'] as String),
        teaId: map['teaId'] as String?,
        teaName: map['teaName'] as String,
        teaType: TeaType.fromString(map['teaType'] as String? ?? 'green'),
        brewVariant: map['brewVariant'] != null
            ? BrewVariant.fromJsonString(map['brewVariant'] as String)
            : null,
        infusionLogs:
            InfusionLog.listFromJson(map['infusionLogs'] as String?),
        additions: List<String>.from(
            jsonDecode(map['additions'] as String? ?? '[]') as List,),
        notes: map['notes'] as String?,
        rating: map['rating'] as int? ?? 0,
        isManual: (map['isManual'] as int? ?? 0) == 1,
      );
}
