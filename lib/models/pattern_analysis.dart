class SymptomCorrelation {
  final String symptom1;
  final String symptom2;
  final double correlation;
  final int sampleSize;
  final String description;

  SymptomCorrelation({
    required this.symptom1,
    required this.symptom2,
    required this.correlation,
    required this.sampleSize,
    required this.description,
  });

  double get strength {
    return correlation.abs();
  }

  String get strengthLabel {
    if (strength >= 0.7) return 'Strong';
    if (strength >= 0.5) return 'Moderate';
    if (strength >= 0.3) return 'Weak';
    return 'Very Weak';
  }
}

class WeeklyPattern {
  final String dayOfWeek;
  final Map<String, double> averageSymptoms;
  final int logCount;

  WeeklyPattern({
    required this.dayOfWeek,
    required this.averageSymptoms,
    required this.logCount,
  });

  double getAverageForSymptom(String symptom) {
    return averageSymptoms[symptom] ?? 0.0;
  }
}

class TimePattern {
  final String timeOfDay;
  final Map<String, double> averageSymptoms;
  final int logCount;

  TimePattern({
    required this.timeOfDay,
    required this.averageSymptoms,
    required this.logCount,
  });

  double getAverageForSymptom(String symptom) {
    return averageSymptoms[symptom] ?? 0.0;
  }
}

class SymptomInsight {
  final String type; // 'correlation', 'weekly', 'time', 'trend'
  final String title;
  final String description;
  final String icon;
  final int priority; // 1-5, higher is more important
  final DateTime generatedAt;

  SymptomInsight({
    required this.type,
    required this.title,
    required this.description,
    required this.icon,
    required this.priority,
    DateTime? generatedAt,
  }) : generatedAt = generatedAt ?? DateTime.now();
}

class PatternAnalysisResult {
  final List<SymptomCorrelation> correlations;
  final List<WeeklyPattern> weeklyPatterns;
  final List<TimePattern> timePatterns;
  final List<SymptomInsight> insights;
  final DateTime analyzedAt;
  final int totalLogsAnalyzed;

  PatternAnalysisResult({
    required this.correlations,
    required this.weeklyPatterns,
    required this.timePatterns,
    required this.insights,
    required this.totalLogsAnalyzed,
    DateTime? analyzedAt,
  }) : analyzedAt = analyzedAt ?? DateTime.now();
}
