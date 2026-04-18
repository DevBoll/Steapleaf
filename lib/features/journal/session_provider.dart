import 'package:flutter/foundation.dart';
import 'package:steapleaf/domain/repositories/session_repository.dart';
import '../../domain/enums/enums.dart';
import '../../domain/models/session.dart';
import '../../domain/repositories/tea_repository.dart';

class SessionProvider extends ChangeNotifier {
  final SessionRepository _repository;

  SessionProvider(this._repository);

  List<Session> _sessions = [];
  bool _loading = false;
  _SessionStats _stats = _SessionStats.empty();

  List<Session> get sessions => _sessions;
  bool get loading => _loading;

  Session? get lastSession => _sessions.isNotEmpty ? _sessions.first : null;

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _sessions = await _repository.getAll();
    _stats = _SessionStats.compute(_sessions);
    _loading = false;
    notifyListeners();
  }

  Future<void> addSession(Session session) async {
    await _repository.save(session);
    await load();
    notifyListeners();
  }

  Future<void> updateSession(Session session) async {
    await _repository.update(session);
    _sessions = [for (final s in _sessions) s.id == session.id ? session : s];
    _invalidateStats();
    notifyListeners();
  }

  Future<void> deleteSession(String id) async {
    await _repository.delete(id);
    _sessions = _sessions.where((s) => s.id != id).toList();
    _invalidateStats();
    notifyListeners();
  }

  void _invalidateStats() {
    _stats = _SessionStats.compute(_sessions);
  }

  int get currentYearSessions => _stats.currentYearSessions;
  double get averageRating => _stats.averageRating;
  int get uniqueTeasCount => _stats.uniqueTeasCount;
  int get teaDaysCount => _stats.teaDaysCount;
  String get mostBrewedTea => _stats.mostBrewedTea;
  Map<DateTime, int> get heatmapData => _stats.heatmapData;
  Map<TeaType, int> get byTeaType => _stats.byTeaType;
  Map<String, int> get byMonth => _stats.byMonth;
}

class _SessionStats {
  final int currentYearSessions;
  final double averageRating;
  final int uniqueTeasCount;
  final int teaDaysCount;
  final String mostBrewedTea;
  final Map<DateTime, int> heatmapData;
  final Map<TeaType, int> byTeaType;
  final Map<String, int> byMonth;

  const _SessionStats({
    required this.currentYearSessions,
    required this.averageRating,
    required this.uniqueTeasCount,
    required this.teaDaysCount,
    required this.mostBrewedTea,
    required this.heatmapData,
    required this.byTeaType,
    required this.byMonth,
  });

  factory _SessionStats.empty() => const _SessionStats(
        currentYearSessions: 0,
        averageRating: 0,
        uniqueTeasCount: 0,
        teaDaysCount: 0,
        mostBrewedTea: '–',
        heatmapData: {},
        byTeaType: {},
        byMonth: {},
      );

  factory _SessionStats.compute(List<Session> sessions) {
    final now = DateTime.now();
    final thisYear = sessions.where((s) => s.dateTime.year == now.year).toList();

    // currentYearSessions
    final currentYearSessions = thisYear.length;

    // averageRating
    final rated = sessions.where((s) => s.rating > 0).toList();
    final averageRating = rated.isEmpty
        ? 0.0
        : rated.map((s) => s.rating).reduce((a, b) => a + b) / rated.length;

    // uniqueTeasCount
    final uniqueTeasCount = sessions.map((s) => s.teaName).toSet().length;

    // teaDaysCount
    final days = thisYear
        .map((s) => DateTime(s.dateTime.year, s.dateTime.month, s.dateTime.day))
        .toSet();
    final teaDaysCount = days.length;

    // mostBrewedTea
    String mostBrewedTea = '–';
    if (thisYear.isNotEmpty) {
      final counts = <String, int>{};
      for (final s in thisYear) {
        counts[s.teaName] = (counts[s.teaName] ?? 0) + 1;
      }
      mostBrewedTea = counts.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    // heatmapData
    final heatmapData = <DateTime, int>{};
    for (final s in sessions) {
      final day = DateTime(s.dateTime.year, s.dateTime.month, s.dateTime.day);
      heatmapData[day] = (heatmapData[day] ?? 0) + 1;
    }

    // byTeaType
    final byTeaType = <TeaType, int>{};
    for (final s in sessions) {
      byTeaType[s.teaType] = (byTeaType[s.teaType] ?? 0) + 1;
    }

    // byMonth (letzte 12 Monate)
    final byMonth = <String, int>{};
    for (var i = 11; i >= 0; i--) {
      final month = DateTime(now.year, now.month - i);
      final key = '${month.year}-${month.month.toString().padLeft(2, '0')}';
      byMonth[key] = 0;
    }
    for (final s in sessions) {
      final key =
          '${s.dateTime.year}-${s.dateTime.month.toString().padLeft(2, '0')}';
      if (byMonth.containsKey(key)) {
        byMonth[key] = byMonth[key]! + 1;
      }
    }

    return _SessionStats(
      currentYearSessions: currentYearSessions,
      averageRating: averageRating,
      uniqueTeasCount: uniqueTeasCount,
      teaDaysCount: teaDaysCount,
      mostBrewedTea: mostBrewedTea,
      heatmapData: heatmapData,
      byTeaType: byTeaType,
      byMonth: byMonth,
    );
  }
}
