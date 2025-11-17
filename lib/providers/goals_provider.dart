import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_log.dart';
import '../models/goals.dart';
import '../models/pattern_analysis.dart';
import '../services/symptom_analysis_service.dart';

class GoalsProvider extends ChangeNotifier {
  Box<HealthGoal> get _goalsBox => Hive.box<HealthGoal>('goals');
  Box<SmartReminder> get _remindersBox => Hive.box<SmartReminder>('reminders');

  List<HealthGoal> get goals => _goalsBox.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  List<SmartReminder> get reminders => _remindersBox.values.toList()
    ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  StreakInfo calculateStreak(List<DailyLog> logs) {
    if (logs.isEmpty) {
      return StreakInfo(
        currentStreak: 0,
        longestStreak: 0,
        lastLogDate: DateTime.now(),
        totalLogs: 0,
      );
    }

    // Sort logs by date (most recent first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    final today = DateTime.now();
    final todayNormalized = DateTime(today.year, today.month, today.day);

    int currentStreak = 0;
    int longestStreak = 0;
    int tempStreak = 0;

    DateTime? lastDate;

    for (final log in logs) {
      final logDate = DateTime(log.date.year, log.date.month, log.date.day);

      if (lastDate == null) {
        tempStreak = 1;
        currentStreak = 1;
      } else {
        final difference = lastDate.difference(logDate).inDays;
        if (difference == 1) {
          tempStreak++;
          if (logDate.year == todayNormalized.year &&
              logDate.month == todayNormalized.month &&
              logDate.day == todayNormalized.day) {
            currentStreak = tempStreak;
          }
        } else {
          longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;
          tempStreak = 1;
        }
      }

      lastDate = logDate;
    }

    longestStreak = tempStreak > longestStreak ? tempStreak : longestStreak;

    return StreakInfo(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastLogDate: logs.first.date,
      totalLogs: logs.length,
    );
  }

  Future<void> createGoal({
    required String title,
    required String description,
    required String type,
    required Map<String, dynamic> target,
  }) async {
    final goal = HealthGoal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      type: type,
      target: target,
      current: {},
    );

    await _goalsBox.put(goal.id, goal);
    notifyListeners();
  }

  Future<void> updateGoalProgress(String goalId, List<DailyLog> logs) async {
    final goal = _goalsBox.get(goalId);
    if (goal == null) return;

    Map<String, dynamic> current = {};

    switch (goal.type) {
      case 'symptom_reduction':
        final symptom = goal.target['symptom'] as String;
        if (logs.isNotEmpty) {
          final recentLogs = logs.take(7); // Last 7 days
          final average = recentLogs.map((log) => _getSymptomValue(log, symptom)).reduce((a, b) => a + b) / recentLogs.length;
          current['averageLevel'] = average;
        }
        break;

      case 'logging_streak':
        final streakInfo = calculateStreak(logs);
        current['currentStreak'] = streakInfo.currentStreak;
        break;

      case 'exercise':
        if (logs.isNotEmpty) {
          final recentLogs = logs.take(7);
          final average = recentLogs.map((log) => log.exerciseMinutes).reduce((a, b) => a + b) / recentLogs.length;
          current['averageMinutes'] = average;
        }
        break;

      case 'sleep':
        if (logs.isNotEmpty) {
          final recentLogs = logs.take(7);
          final average = recentLogs.map((log) => log.sleepHours).reduce((a, b) => a + b) / recentLogs.length;
          current['averageHours'] = average;
        }
        break;
    }

    final updatedGoal = HealthGoal(
      id: goal.id,
      title: goal.title,
      description: goal.description,
      type: goal.type,
      target: goal.target,
      current: current,
      createdAt: goal.createdAt,
      targetDate: goal.targetDate,
      isCompleted: _isGoalCompleted(goal, current),
      completedAt: _isGoalCompleted(goal, current) ? DateTime.now() : goal.completedAt,
    );

    await _goalsBox.put(goalId, updatedGoal);
    notifyListeners();
  }

  bool _isGoalCompleted(HealthGoal goal, Map<String, dynamic> current) {
    switch (goal.type) {
      case 'symptom_reduction':
        final targetLevel = goal.target['targetLevel'] as int? ?? 0;
        final currentLevel = current['averageLevel'] as double? ?? 0;
        return currentLevel <= targetLevel;

      case 'logging_streak':
        final targetDays = goal.target['days'] as int? ?? 1;
        final currentDays = current['currentStreak'] as int? ?? 0;
        return currentDays >= targetDays;

      case 'exercise':
        final targetMinutes = goal.target['minutes'] as int? ?? 30;
        final currentMinutes = current['averageMinutes'] as double? ?? 0;
        return currentMinutes >= targetMinutes;

      case 'sleep':
        final targetHours = goal.target['hours'] as int? ?? 8;
        final currentHours = current['averageHours'] as double? ?? 0;
        return currentHours >= targetHours;

      default:
        return false;
    }
  }

  Future<void> deleteGoal(String goalId) async {
    await _goalsBox.delete(goalId);
    notifyListeners();
  }

  Future<void> createSmartReminder({
    required String title,
    required String message,
    required String triggerType,
    required Map<String, dynamic> conditions,
    DateTime? scheduledTime,
  }) async {
    final reminder = SmartReminder(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      triggerType: triggerType,
      conditions: conditions,
      scheduledTime: scheduledTime,
    );

    await _remindersBox.put(reminder.id, reminder);
    notifyListeners();
  }

  List<SmartReminder> checkReminders(DateTime currentTime, Map<String, dynamic> context) {
    final triggeredReminders = <SmartReminder>[];

    for (final reminder in _remindersBox.values) {
      if (reminder.shouldTrigger(currentTime, context)) {
        triggeredReminders.add(reminder);
        // Update last triggered time
        final updatedReminder = SmartReminder(
          id: reminder.id,
          title: reminder.title,
          message: reminder.message,
          triggerType: reminder.triggerType,
          conditions: reminder.conditions,
          scheduledTime: reminder.scheduledTime,
          isEnabled: reminder.isEnabled,
          createdAt: reminder.createdAt,
          lastTriggered: currentTime,
        );
        _remindersBox.put(reminder.id, updatedReminder);
      }
    }

    if (triggeredReminders.isNotEmpty) {
      notifyListeners();
    }

    return triggeredReminders;
  }

  Future<void> deleteReminder(String reminderId) async {
    await _remindersBox.delete(reminderId);
    notifyListeners();
  }

  Future<void> toggleReminder(String reminderId) async {
    final reminder = _remindersBox.get(reminderId);
    if (reminder != null) {
      final updatedReminder = SmartReminder(
        id: reminder.id,
        title: reminder.title,
        message: reminder.message,
        triggerType: reminder.triggerType,
        conditions: reminder.conditions,
        scheduledTime: reminder.scheduledTime,
        isEnabled: !reminder.isEnabled,
        createdAt: reminder.createdAt,
        lastTriggered: reminder.lastTriggered,
      );
      await _remindersBox.put(reminderId, updatedReminder);
      notifyListeners();
    }
  }

  // Generate personalized reminders based on patterns
  List<SmartReminder> generatePersonalizedReminders(PatternAnalysisResult analysis) {
    final reminders = <SmartReminder>[];

    // Generate reminders based on correlations
    for (final correlation in analysis.correlations.take(3)) {
      if (correlation.strength >= 0.5) {
        final reminder = SmartReminder(
          id: 'pattern_${correlation.symptom1}_${correlation.symptom2}',
          title: 'Symptom Pattern Alert',
          message: 'Consider monitoring ${correlation.symptom1} levels when ${correlation.symptom2} is elevated',
          triggerType: 'pattern_based',
          conditions: {
            'symptom': correlation.symptom1,
            'threshold': 2, // Medium threshold
          },
        );
        reminders.add(reminder);
      }
    }

    // Generate time-based reminders for peak symptom times
    for (final timePattern in analysis.timePatterns) {
      final maxSymptom = SymptomAnalysisService.symptomFields.reduce((a, b) =>
        timePattern.getAverageForSymptom(a) > timePattern.getAverageForSymptom(b) ? a : b
      );

      if (timePattern.getAverageForSymptom(maxSymptom) > 2.0) {
        final reminder = SmartReminder(
          id: 'time_${timePattern.timeOfDay}_${maxSymptom}',
          title: 'Daily Check-in',
          message: 'Remember to log your symptoms during ${timePattern.timeOfDay.toLowerCase()} when $maxSymptom tends to be higher',
          triggerType: 'time_based',
          conditions: {},
          scheduledTime: _getTimeForPeriod(timePattern.timeOfDay),
        );
        reminders.add(reminder);
      }
    }

    return reminders;
  }

  DateTime _getTimeForPeriod(String period) {
    final now = DateTime.now();
    switch (period) {
      case 'Morning':
        return DateTime(now.year, now.month, now.day, 9, 0);
      case 'Afternoon':
        return DateTime(now.year, now.month, now.day, 14, 0);
      case 'Evening':
        return DateTime(now.year, now.month, now.day, 19, 0);
      case 'Night':
        return DateTime(now.year, now.month, now.day, 21, 0);
      default:
        return DateTime(now.year, now.month, now.day, 12, 0);
    }
  }

  double _getSymptomValue(DailyLog log, String symptom) {
    return SymptomAnalysisService.getSymptomValue(log, symptom);
  }
}
