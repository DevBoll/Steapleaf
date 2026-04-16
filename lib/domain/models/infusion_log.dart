import 'dart:convert';

class InfusionLog {
  final int infusionNumber;
  final int tempActual;
  final Duration plannedTime;
  final Duration actualTime;

  const InfusionLog({
    required this.infusionNumber,
    required this.tempActual,
    required this.plannedTime,
    required this.actualTime,
  });

  Map<String, dynamic> toJson() => {
        'infusionNumber': infusionNumber,
        'tempActual': tempActual,
        'plannedSeconds': plannedTime.inSeconds,
        'actualSeconds': actualTime.inSeconds,
      };

  factory InfusionLog.fromJson(Map<String, dynamic> json) => InfusionLog(
        infusionNumber: json['infusionNumber'] as int? ?? 1,
        tempActual: json['tempActual'] as int? ?? 80,
        plannedTime: Duration(seconds: json['plannedSeconds'] as int? ?? 120),
        actualTime: Duration(seconds: json['actualSeconds'] as int? ?? 120),
      );

  static List<InfusionLog> listFromJson(String? json) {
    if (json == null || json.isEmpty) return [];
    try {
      final list = jsonDecode(json) as List;
      return list
          .map((e) => InfusionLog.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String listToJson(List<InfusionLog> logs) {
    return jsonEncode(logs.map((e) => e.toJson()).toList());
  }
}
