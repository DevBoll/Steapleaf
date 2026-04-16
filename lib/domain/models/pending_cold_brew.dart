import 'dart:convert';
import 'enums.dart';
import 'brew_variant.dart';

class PendingColdBrew {
  final String id;
  final String teaName;
  final TeaType teaType;
  final String? teaId;
  final BrewVariant brewVariant;
  final DateTime startTime;
  final Duration duration;
  final bool isFridge;
  final List<String> additions;

  const PendingColdBrew({
    required this.id,
    required this.teaName,
    required this.teaType,
    this.teaId,
    required this.brewVariant,
    required this.startTime,
    required this.duration,
    required this.isFridge,
    this.additions = const [],
  });

  DateTime get endTime => startTime.add(duration);

  bool get isFinished => DateTime.now().isAfter(endTime);

  Duration get remaining {
    final r = endTime.difference(DateTime.now());
    return r.isNegative ? Duration.zero : r;
  }

  double get progress {
    final totalSec = duration.inSeconds;
    if (totalSec == 0) return 1.0;
    final elapsed = DateTime.now().difference(startTime).inSeconds;
    return (elapsed / totalSec).clamp(0.0, 1.0);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'teaName': teaName,
        'teaType': teaType.name,
        'teaId': teaId,
        'brewVariant': brewVariant.toJson(),
        'startTime': startTime.toIso8601String(),
        'durationSeconds': duration.inSeconds,
        'isFridge': isFridge,
        'additions': additions,
      };

  factory PendingColdBrew.fromJson(Map<String, dynamic> json) =>
      PendingColdBrew(
        id: json['id'] as String,
        teaName: json['teaName'] as String,
        teaType: TeaType.fromString(json['teaType'] as String? ?? 'green'),
        teaId: json['teaId'] as String?,
        brewVariant: BrewVariant.fromJson(
          json['brewVariant'] as Map<String, dynamic>,
        ),
        startTime: DateTime.parse(json['startTime'] as String),
        duration: Duration(seconds: json['durationSeconds'] as int? ?? 0),
        isFridge: json['isFridge'] as bool? ?? true,
        additions: List<String>.from(json['additions'] as List? ?? []),
      );

  String toJsonString() => jsonEncode(toJson());

  factory PendingColdBrew.fromJsonString(String raw) =>
      PendingColdBrew.fromJson(jsonDecode(raw) as Map<String, dynamic>);
}
