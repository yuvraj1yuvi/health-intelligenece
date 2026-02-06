import 'package:hive/hive.dart';

part 'daily_log.g.dart';

@HiveType(typeId: 0)
class DailyLog extends HiveObject {
  @HiveField(0)
  DateTime date;

  @HiveField(1)
  int headache; // 0-3

  @HiveField(2)
  int stress; // 0-3

  @HiveField(3)
  int fatigue; // 0-3

  @HiveField(4)
  int painLevel; // 0-10

  @HiveField(5)
  int mood; // 1-5

  @HiveField(6)
  String notes;

  @HiveField(7)
  int exerciseMinutes; // 0-180 minutes

  @HiveField(8)
  int sleepHours; // 0-12 hours

  @HiveField(9)
  int sleepQuality; // 1-5 (1=poor, 5=excellent)

  @HiveField(10)
  int waterGlasses; // 0-10 glasses

  @HiveField(11)
  int caffeineIntake; // 0-5 cups

  @HiveField(12)
  int screenTime; // 0-12 hours

  @HiveField(13)
  String weather; // 'sunny', 'cloudy', 'rainy', 'snowy', ''

  @HiveField(14)
  List<String> activities; // ['work', 'exercise', 'social', etc.]

  @HiveField(15)
  List<String> triggers; // ['stress', 'food', 'weather', etc.]

  DailyLog({
    required this.date,
    this.headache = 0,
    this.stress = 0,
    this.fatigue = 0,
    this.painLevel = 0,
    this.mood = 3,
    this.notes = '',
    this.exerciseMinutes = 0,
    this.sleepHours = 0,
    this.sleepQuality = 3,
    this.waterGlasses = 0,
    this.caffeineIntake = 0,
    this.screenTime = 0,
    this.weather = '',
    List<String>? activities,
    List<String>? triggers,
  }) : 
    activities = activities ?? [],
    triggers = triggers ?? [];

  String get moodEmoji {
    switch (mood) {
      case 1:
        return '😄';
      case 2:
        return '🙂';
      case 3:
        return '😐';
      case 4:
        return '😕';
      case 5:
        return '😢';
      default:
        return '😐';
    }
  }

  String get symptomSummary {
    List<String> entries = [];
    if (headache > 0) entries.add('Head Discomfort $headache');
    if (stress > 0) entries.add('Stress $stress');
    if (fatigue > 0) entries.add('Tiredness $fatigue');
    return entries.isEmpty ? 'No entries' : entries.join(' • ');
  }
}
