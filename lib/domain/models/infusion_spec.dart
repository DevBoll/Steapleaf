import 'package:uuid/uuid.dart';

class InfusionSpec {
  final String id;
  final int tempMin;
  final int? tempMax;
  final Duration steepTime;

  InfusionSpec({
    String? id,
    required this.tempMin,
    this.tempMax,
    required this.steepTime,
  }) : id = id ?? const Uuid().v4();

  String get tempDisplay {
    if (tempMax != null && tempMax != tempMin) {
      return '$tempMin–$tempMax °C';
    }
    return '$tempMin °C';
  }

  InfusionSpec copyWith({
    int? tempMin,
    int? tempMax,
    bool clearTempMax = false,
    Duration? steepTime,
  }) {
    return InfusionSpec(
      id: id,
      tempMin: tempMin ?? this.tempMin,
      tempMax: clearTempMax ? null : (tempMax ?? this.tempMax),
      steepTime: steepTime ?? this.steepTime,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'tempMin': tempMin,
        'tempMax': tempMax,
        'steepSeconds': steepTime.inSeconds,
      };

  factory InfusionSpec.fromJson(Map<String, dynamic> json) => InfusionSpec(
        id: json['id'] as String?,
        tempMin: json['tempMin'] as int? ?? 80,
        tempMax: json['tempMax'] as int?,
        steepTime: Duration(seconds: json['steepSeconds'] as int? ?? 120),
      );

}
