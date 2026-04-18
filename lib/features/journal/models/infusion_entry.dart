import 'package:flutter/material.dart';

import '../../../domain/models/infusion_log.dart';

/// Datenmodell für einen manuell erfassten Aufguss.
/// Hält TextEditingController für Temp, Minuten und Sekunden.
/// Muss in dispose() des übergeordneten Widgets disposed werden.
class InfusionEntry {
  final TextEditingController tempCtrl;
  final TextEditingController minCtrl;
  final TextEditingController secCtrl;

  InfusionEntry({
    String defaultTemp = '80',
    String defaultMin = '03',
    String defaultSec = '00',
  })  : tempCtrl = TextEditingController(text: defaultTemp),
        minCtrl = TextEditingController(text: defaultMin),
        secCtrl = TextEditingController(text: defaultSec);

  void dispose() {
    tempCtrl.dispose();
    minCtrl.dispose();
    secCtrl.dispose();
  }

  int get temp => int.tryParse(tempCtrl.text) ?? 80;
  int get minutes => int.tryParse(minCtrl.text) ?? 0;
  int get seconds => int.tryParse(secCtrl.text) ?? 0;
  Duration get duration => Duration(minutes: minutes, seconds: seconds);

  InfusionLog toLog(int index) => InfusionLog(
        infusionNumber: index + 1,
        tempActual: temp.clamp(30, 100),
        plannedTime: duration,
        actualTime: duration,
      );
}
