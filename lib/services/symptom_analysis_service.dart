import 'dart:math';
import '../models/daily_log.dart';
import '../models/pattern_analysis.dart';

class SymptomAnalysisService {
  static const List<String> symptomFields = ['headache', 'stress', 'fatigue', 'painLevel', 'mood'];
  static const List<String> healthFactors = ['exerciseMinutes', 'sleepHours', 'sleepQuality', 'waterGlasses', 'caffeineIntake', 'screenTime'];
  static const List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  static const List<String> timeOfDay = ['Morning', 'Afternoon', 'Evening', 'Night'];

  static PatternAnalysisResult analyzePatterns(List<DailyLog> logs) {
    if (logs.isEmpty) {
      return PatternAnalysisResult(
        correlations: [],
        weeklyPatterns: [],
        timePatterns: [],
        insights: [],
        totalLogsAnalyzed: 0,
      );
    }

    final correlations = _analyzeCorrelations(logs);
    final healthCorrelations = _analyzeHealthCorrelations(logs);
    final allCorrelations = [...correlations, ...healthCorrelations];
    final weeklyPatterns = _analyzeWeeklyPatterns(logs);
    final timePatterns = _analyzeTimePatterns(logs);
    final insights = _generateInsights(allCorrelations, weeklyPatterns, timePatterns, logs.length);

    return PatternAnalysisResult(
      correlations: correlations,
      weeklyPatterns: weeklyPatterns,
      timePatterns: timePatterns,
      insights: insights,
      totalLogsAnalyzed: logs.length,
    );
  }

  static List<SymptomCorrelation> _analyzeCorrelations(List<DailyLog> logs) {
    final correlations = <SymptomCorrelation>[];

    // Analyze correlations between each pair of symptoms
    for (int i = 0; i < symptomFields.length; i++) {
      for (int j = i + 1; j < symptomFields.length; j++) {
        final symptom1 = symptomFields[i];
        final symptom2 = symptomFields[j];

        final correlation = _calculateCorrelation(logs, symptom1, symptom2);
        if (correlation.abs() >= 0.1) { // Only include meaningful correlations
          final description = _generateCorrelationDescription(symptom1, symptom2, correlation);
          correlations.add(SymptomCorrelation(
            symptom1: symptom1,
            symptom2: symptom2,
            correlation: correlation,
            sampleSize: logs.length,
            description: description,
          ));
        }
      }
    }

    // Sort by correlation strength
    correlations.sort((a, b) => b.strength.compareTo(a.strength));
    return correlations.take(10).toList(); // Return top 10 correlations
  }

  static List<SymptomCorrelation> _analyzeHealthCorrelations(List<DailyLog> logs) {
    final correlations = <SymptomCorrelation>[];

    // Analyze correlations between symptoms and health factors
    for (final symptom in symptomFields) {
      for (final factor in healthFactors) {
        final correlation = _calculateCorrelation(logs, symptom, factor);
        if (correlation.abs() >= 0.2) { // Lower threshold for health factors
          final description = _generateCorrelationDescription(symptom, factor, correlation);
          correlations.add(SymptomCorrelation(
            symptom1: symptom,
            symptom2: factor,
            correlation: correlation,
            sampleSize: logs.length,
            description: description,
          ));
        }
      }
    }

    // Sort by correlation strength
    correlations.sort((a, b) => b.strength.compareTo(a.strength));
    return correlations.take(5).toList(); // Return top 5 health correlations
  }

  static double _calculateCorrelation(List<DailyLog> logs, String symptom1, String symptom2) {
    if (logs.length < 2) return 0.0;

    final values1 = logs.map((log) => getSymptomValue(log, symptom1)).toList();
    final values2 = logs.map((log) => getSymptomValue(log, symptom2)).toList();

    final mean1 = values1.fold<double>(0.0, (sum, value) => sum + value) / values1.length;
    final mean2 = values2.fold<double>(0.0, (sum, value) => sum + value) / values2.length;

    double numerator = 0.0;
    double sumSq1 = 0.0;
    double sumSq2 = 0.0;

    for (int i = 0; i < values1.length; i++) {
      final diff1 = values1[i] - mean1;
      final diff2 = values2[i] - mean2;
      numerator += diff1 * diff2;
      sumSq1 += diff1 * diff1;
      sumSq2 += diff2 * diff2;
    }

    final denominator = sqrt(sumSq1 * sumSq2);
    return denominator == 0 ? 0 : numerator / denominator;
  }

  static double getSymptomValue(DailyLog log, String field) {
    switch (field) {
      case 'headache':
        return log.headache.toDouble();
      case 'stress':
        return log.stress.toDouble();
      case 'fatigue':
        return log.fatigue.toDouble();
      case 'painLevel':
        return log.painLevel.toDouble();
      case 'mood':
        return log.mood.toDouble();
      case 'exerciseMinutes':
        return log.exerciseMinutes.toDouble();
      case 'sleepHours':
        return log.sleepHours.toDouble();
      case 'sleepQuality':
        return log.sleepQuality.toDouble();
      case 'waterGlasses':
        return log.waterGlasses.toDouble();
      case 'caffeineIntake':
        return log.caffeineIntake.toDouble();
      case 'screenTime':
        return log.screenTime.toDouble();
      default:
        return 0.0;
    }
  }

  static String _generateCorrelationDescription(String field1, String field2, double correlation) {
    final strength = correlation.abs() >= 0.7 ? 'strongly' : correlation.abs() >= 0.5 ? 'moderately' : 'weakly';

    // Check if field2 is a health factor
    final isHealthFactor = healthFactors.contains(field2);
    final direction = correlation > 0
        ? (isHealthFactor ? 'associated with higher' : 'tend to occur together')
        : (isHealthFactor ? 'associated with lower' : 'tend to be inversely related');

    final field1Name = _getSymptomDisplayName(field1);
    final field2Name = isHealthFactor ? _getFactorDisplayName(field2) : _getSymptomDisplayName(field2);

    if (isHealthFactor) {
      return '$field1Name $strength $direction $field2Name';
    } else {
      return '$field1Name and $field2Name $strength $direction';
    }
  }

  static String _getFactorDisplayName(String factor) {
    switch (factor) {
      case 'exerciseMinutes':
        return 'exercise levels';
      case 'sleepHours':
        return 'sleep duration';
      case 'sleepQuality':
        return 'sleep quality';
      case 'waterGlasses':
        return 'water intake';
      case 'caffeineIntake':
        return 'caffeine consumption';
      case 'screenTime':
        return 'screen time';
      default:
        return factor;
    }
  }

  static String _getSymptomDisplayName(String symptom) {
    switch (symptom) {
      case 'headache':
        return 'Headaches';
      case 'stress':
        return 'Stress levels';
      case 'fatigue':
        return 'Fatigue';
      case 'painLevel':
        return 'Pain levels';
      case 'mood':
        return 'Mood';
      default:
        return symptom;
    }
  }

  static List<WeeklyPattern> _analyzeWeeklyPatterns(List<DailyLog> logs) {
    final weeklyData = <String, List<DailyLog>>{};

    // Group logs by day of week
    for (final log in logs) {
      final dayName = daysOfWeek[log.date.weekday - 1];
      weeklyData.putIfAbsent(dayName, () => []).add(log);
    }

    final patterns = <WeeklyPattern>[];

    for (final day in daysOfWeek) {
      final dayLogs = weeklyData[day] ?? [];
      if (dayLogs.isEmpty) continue;

      final averages = <String, double>{};
      for (final symptom in symptomFields) {
        final values = dayLogs.map((log) => getSymptomValue(log, symptom)).toList();
        averages[symptom] = values.fold<double>(0.0, (sum, value) => sum + value) / values.length;
      }

      patterns.add(WeeklyPattern(
        dayOfWeek: day,
        averageSymptoms: averages,
        logCount: dayLogs.length,
      ));
    }

    return patterns;
  }

  static List<TimePattern> _analyzeTimePatterns(List<DailyLog> logs) {
    final timeData = <String, List<DailyLog>>{};

    // Group logs by time of day (assuming date represents when logged, not symptom time)
    for (final log in logs) {
      final hour = log.date.hour;
      String timeSlot;

      if (hour >= 5 && hour < 12) {
        timeSlot = 'Morning';
      } else if (hour >= 12 && hour < 17) {
        timeSlot = 'Afternoon';
      } else if (hour >= 17 && hour < 21) {
        timeSlot = 'Evening';
      } else {
        timeSlot = 'Night';
      }

      timeData.putIfAbsent(timeSlot, () => []).add(log);
    }

    final patterns = <TimePattern>[];

    for (final timeSlot in timeOfDay) {
      final slotLogs = timeData[timeSlot] ?? [];
      if (slotLogs.isEmpty) continue;

      final averages = <String, double>{};
      for (final symptom in symptomFields) {
        final values = slotLogs.map((log) => getSymptomValue(log, symptom)).toList();
        averages[symptom] = values.fold<double>(0.0, (sum, value) => sum + value) / values.length;
      }

      patterns.add(TimePattern(
        timeOfDay: timeSlot,
        averageSymptoms: averages,
        logCount: slotLogs.length,
      ));
    }

    return patterns;
  }

  static List<SymptomInsight> _generateInsights(
    List<SymptomCorrelation> correlations,
    List<WeeklyPattern> weeklyPatterns,
    List<TimePattern> timePatterns,
    int totalLogs,
  ) {
    final insights = <SymptomInsight>[];

    // Correlation insights
    if (correlations.isNotEmpty) {
      final topCorrelation = correlations.first;
      if (topCorrelation.strength >= 0.5) {
        insights.add(SymptomInsight(
          type: 'correlation',
          title: 'Symptom Relationship Found',
          description: topCorrelation.description,
          icon: '🔗',
          priority: topCorrelation.strength >= 0.7 ? 5 : 4,
        ));
      }
    }

    // Weekly pattern insights
    if (weeklyPatterns.isNotEmpty) {
      final worstDay = weeklyPatterns.reduce((a, b) =>
        a.getAverageForSymptom('painLevel') > b.getAverageForSymptom('painLevel') ? a : b
      );

      if (worstDay.getAverageForSymptom('painLevel') > 3.0) {
        insights.add(SymptomInsight(
          type: 'weekly',
          title: 'Weekly Pattern Detected',
          description: '${worstDay.dayOfWeek} shows higher average pain levels',
          icon: '📅',
          priority: 3,
        ));
      }
    }

    // Time pattern insights
    if (timePatterns.isNotEmpty) {
      final worstTime = timePatterns.reduce((a, b) =>
        a.getAverageForSymptom('fatigue') > b.getAverageForSymptom('fatigue') ? a : b
      );

      if (worstTime.getAverageForSymptom('fatigue') > 2.0) {
        insights.add(SymptomInsight(
          type: 'time',
          title: 'Time-based Pattern',
          description: 'Higher fatigue levels in the ${worstTime.timeOfDay.toLowerCase()}',
          icon: '⏰',
          priority: 3,
        ));
      }
    }

    // Data sufficiency insights
    if (totalLogs < 7) {
      insights.add(SymptomInsight(
        type: 'trend',
        title: 'More Data Needed',
        description: 'Log symptoms for at least a week to see meaningful patterns',
        icon: '📊',
        priority: 2,
      ));
    } else if (totalLogs >= 30) {
      insights.add(SymptomInsight(
        type: 'trend',
        title: 'Rich Data Available',
        description: 'You have enough data for detailed pattern analysis',
        icon: '🎯',
        priority: 1,
      ));
    }

    // Sort by priority
    insights.sort((a, b) => b.priority.compareTo(a.priority));
    return insights;
  }
}
