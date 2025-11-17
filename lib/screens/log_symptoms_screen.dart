import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/daily_log.dart';
import '../providers/daily_log_provider.dart';
import '../widgets/mood_picker.dart';
import '../widgets/symptom_radio_group.dart';
import '../widgets/pain_slider.dart';

class LogSymptomsScreen extends StatefulWidget {
  final DailyLog? existingLog;

  const LogSymptomsScreen({super.key, this.existingLog});

  @override
  State<LogSymptomsScreen> createState() => _LogSymptomsScreenState();
}

class _LogSymptomsScreenState extends State<LogSymptomsScreen> {
  late int _mood;
  late int _headache;
  late int _stress;
  late int _fatigue;
  late double _painLevel;
  late TextEditingController _notesController;

  // New health metrics
  late int _exerciseMinutes;
  late int _sleepHours;
  late int _sleepQuality;
  late int _waterGlasses;
  late int _caffeineIntake;
  late int _screenTime;
  late String _weather;
  late List<String> _activities;
  late List<String> _triggers;

  @override
  void initState() {
    super.initState();
    _mood = widget.existingLog?.mood ?? 3;
    _headache = widget.existingLog?.headache ?? 0;
    _stress = widget.existingLog?.stress ?? 0;
    _fatigue = widget.existingLog?.fatigue ?? 0;
    _painLevel = (widget.existingLog?.painLevel ?? 0).toDouble();
    _notesController = TextEditingController(text: widget.existingLog?.notes ?? '');

    // Initialize new health metrics
    _exerciseMinutes = widget.existingLog?.exerciseMinutes ?? 0;
    _sleepHours = widget.existingLog?.sleepHours ?? 0;
    _sleepQuality = widget.existingLog?.sleepQuality ?? 3;
    _waterGlasses = widget.existingLog?.waterGlasses ?? 0;
    _caffeineIntake = widget.existingLog?.caffeineIntake ?? 0;
    _screenTime = widget.existingLog?.screenTime ?? 0;
    _weather = widget.existingLog?.weather ?? '';
    _activities = List.from(widget.existingLog?.activities ?? []);
    _triggers = List.from(widget.existingLog?.triggers ?? []);
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _saveLog() async {
    final log = DailyLog(
      date: DateTime.now(),
      mood: _mood,
      headache: _headache,
      stress: _stress,
      fatigue: _fatigue,
      painLevel: _painLevel.toInt(),
      notes: _notesController.text,
      exerciseMinutes: _exerciseMinutes,
      sleepHours: _sleepHours,
      sleepQuality: _sleepQuality,
      waterGlasses: _waterGlasses,
      caffeineIntake: _caffeineIntake,
      screenTime: _screenTime,
      weather: _weather,
      activities: _activities,
      triggers: _triggers,
    );

    await Provider.of<DailyLogProvider>(context, listen: false).saveLog(log);
    
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Log saved successfully')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingLog == null ? 'Log Symptoms' : 'Edit Log'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('How are you feeling?', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    MoodPicker(
                      selectedMood: _mood,
                      onMoodChanged: (mood) => setState(() => _mood = mood),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SymptomRadioGroup(
                      label: 'Headache',
                      value: _headache,
                      onChanged: (val) => setState(() => _headache = val),
                    ),
                    const Divider(height: 32),
                    SymptomRadioGroup(
                      label: 'Stress',
                      value: _stress,
                      onChanged: (val) => setState(() => _stress = val),
                    ),
                    const Divider(height: 32),
                    SymptomRadioGroup(
                      label: 'Fatigue',
                      value: _fatigue,
                      onChanged: (val) => setState(() => _fatigue = val),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: PainSlider(
                  value: _painLevel,
                  onChanged: (val) => setState(() => _painLevel = val),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Notes', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _notesController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        hintText: 'Any additional notes...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveLog,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Save Log', style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
