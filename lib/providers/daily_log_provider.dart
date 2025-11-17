import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_log.dart';

class DailyLogProvider extends ChangeNotifier {
  Box<DailyLog> get _box => Hive.box<DailyLog>('daily_logs');

  List<DailyLog> getAllLogs() {
    return _box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  DailyLog? getLogForDate(DateTime date) {
    final dateKey = _getDateKey(date);
    return _box.get(dateKey);
  }

  Future<void> saveLog(DailyLog log) async {
    final dateKey = _getDateKey(log.date);
    await _box.put(dateKey, log);
    notifyListeners();
  }

  Future<void> deleteLog(DateTime date) async {
    final dateKey = _getDateKey(date);
    await _box.delete(dateKey);
    notifyListeners();
  }

  Map<DateTime, DailyLog> getLogsMap() {
    Map<DateTime, DailyLog> map = {};
    for (var log in _box.values) {
      final normalizedDate = DateTime(log.date.year, log.date.month, log.date.day);
      map[normalizedDate] = log;
    }
    return map;
  }

  String _getDateKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
