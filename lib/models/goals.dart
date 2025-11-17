import 'package:hive/hive.dart';

part 'goals.g.dart';

@HiveType(typeId: 1)
class HealthGoal extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String description;

  @HiveField(3)
  String type; // 'symptom_reduction', 'logging_streak', 'exercise', 'sleep'

  @HiveField(4)
  Map<String, dynamic> target; // e.g., {'symptom': 'headache', 'targetLevel': 2}

  @HiveField(5)
  Map<String, dynamic> current; // current progress

  @HiveField(6)
  DateTime createdAt;

  @HiveField(7)
  DateTime? targetDate;

  @HiveField(8)
  bool isCompleted;

  @HiveField(9)
  DateTime? completedAt;

  HealthGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.current,
    DateTime? createdAt,
    this.targetDate,
    this.isCompleted = false,
    this.completedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  double get progress {
    switch (type) {
      case 'symptom_reduction':
        final targetLevel = target['targetLevel'] as int? ?? 0;
        final currentLevel = current['averageLevel'] as double? ?? 0;
        return ((targetLevel - currentLevel) / targetLevel).clamp(0.0, 1.0);

      case 'logging_streak':
        final targetDays = target['days'] as int? ?? 1;
        final currentDays = current['currentStreak'] as int? ?? 0;
        return (currentDays / targetDays).clamp(0.0, 1.0);

      case 'exercise':
        final targetMinutes = target['minutes'] as int? ?? 30;
        final currentMinutes = current['averageMinutes'] as double? ?? 0;
        return (currentMinutes / targetMinutes).clamp(0.0, 1.0);

      case 'sleep':
        final targetHours = target['hours'] as int? ?? 8;
        final currentHours = current['averageHours'] as double? ?? 0;
        return (currentHours / targetHours).clamp(0.0, 1.0);

      default:
        return 0.0;
    }
  }

  String get progressText {
    final percent = (progress * 100).round();
    return '$percent% complete';
  }
}

@HiveType(typeId: 2)
class SmartReminder extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String message;

  @HiveField(3)
  String triggerType; // 'pattern_based', 'time_based', 'goal_based'

  @HiveField(4)
  Map<String, dynamic> conditions; // conditions that trigger the reminder

  @HiveField(5)
  DateTime? scheduledTime;

  @HiveField(6)
  bool isEnabled;

  @HiveField(7)
  DateTime createdAt;

  @HiveField(8)
  DateTime? lastTriggered;

  SmartReminder({
    required this.id,
    required this.title,
    required this.message,
    required this.triggerType,
    required this.conditions,
    this.scheduledTime,
    this.isEnabled = true,
    DateTime? createdAt,
    this.lastTriggered,
  }) : createdAt = createdAt ?? DateTime.now();

  bool shouldTrigger(DateTime currentTime, Map<String, dynamic> context) {
    if (!isEnabled) return false;

    switch (triggerType) {
      case 'time_based':
        if (scheduledTime != null) {
          return currentTime.hour == scheduledTime!.hour &&
                 currentTime.minute == scheduledTime!.minute;
        }
        return false;

      case 'pattern_based':
        // Check if conditions match current context
        final symptom = conditions['symptom'] as String?;
        final threshold = conditions['threshold'] as int?;
        if (symptom != null && threshold != null) {
          final currentValue = context[symptom] as int?;
          return currentValue != null && currentValue >= threshold;
        }
        return false;

      case 'goal_based':
        final goalId = conditions['goalId'] as String?;
        final progressThreshold = conditions['progressThreshold'] as double?;
        if (goalId != null && progressThreshold != null) {
          final goalProgress = context['goal_$goalId'] as double?;
          return goalProgress != null && goalProgress >= progressThreshold;
        }
        return false;

      default:
        return false;
    }
  }
}

class StreakInfo {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastLogDate;
  final int totalLogs;

  StreakInfo({
    required this.currentStreak,
    required this.longestStreak,
    required this.lastLogDate,
    required this.totalLogs,
  });

  bool get isActive {
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    return lastLogDate.year == today.year &&
           lastLogDate.month == today.month &&
           lastLogDate.day == today.day ||
           lastLogDate.year == yesterday.year &&
           lastLogDate.month == yesterday.month &&
           lastLogDate.day == yesterday.day;
  }

  String get streakText {
    if (currentStreak == 0) return 'Start your streak today!';
    if (currentStreak == 1) return '1 day streak';
    return '$currentStreak day streak';
  }

  String get badgeEmoji {
    if (currentStreak >= 30) return '🏆';
    if (currentStreak >= 14) return '🥇';
    if (currentStreak >= 7) return '🥈';
    if (currentStreak >= 3) return '🥉';
    return '🔥';
  }
}
