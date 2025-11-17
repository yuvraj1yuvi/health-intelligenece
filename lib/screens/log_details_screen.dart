import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/daily_log.dart';
import 'log_symptoms_screen.dart';

class LogDetailsScreen extends StatelessWidget {
  final DailyLog log;

  const LogDetailsScreen({super.key, required this.log});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => LogSymptomsScreen(existingLog: log),
                ),
              );
            },
          ),
        ],
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Text(
                      DateFormat('EEEE, MMMM d, y').format(log.date),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 20),
                    Text(log.moodEmoji, style: const TextStyle(fontSize: 80)),
                    const SizedBox(height: 8),
                    Text(
                      _getMoodLabel(log.mood),
                      style: Theme.of(context).textTheme.titleMedium,
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
                    Text('Symptoms', style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 16),
                    _buildSymptomTile('Headache', log.headache, 3),
                    _buildSymptomTile('Stress', log.stress, 3),
                    _buildSymptomTile('Fatigue', log.fatigue, 3),
                    _buildSymptomTile('Pain Level', log.painLevel, 10),
                  ],
                ),
              ),
            ),
            if (log.notes.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Notes', style: Theme.of(context).textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(log.notes, style: Theme.of(context).textTheme.bodyLarge),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomTile(String label, int value, int max) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text('$value / $max'),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: value / max,
            backgroundColor: Colors.grey[300],
            minHeight: 10,
            borderRadius: BorderRadius.circular(5),
          ),
        ],
      ),
    );
  }

  String _getMoodLabel(int mood) {
    switch (mood) {
      case 1:
        return 'Very Happy';
      case 2:
        return 'Happy';
      case 3:
        return 'Neutral';
      case 4:
        return 'Sad';
      case 5:
        return 'Very Sad';
      default:
        return 'Neutral';
    }
  }
}
