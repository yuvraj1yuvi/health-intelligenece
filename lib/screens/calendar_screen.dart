import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/daily_log_provider.dart';
import '../models/daily_log.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyLogProvider>(context);
    final logsMap = provider.getLogsMap();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              calendarFormat: CalendarFormat.month,
              eventLoader: (day) {
                final normalizedDay = DateTime(day.year, day.month, day.day);
                return logsMap.containsKey(normalizedDay) ? [logsMap[normalizedDay]!] : [];
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });
              },
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                markerDecoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.tertiary,
                  shape: BoxShape.circle,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
              ),
            ),
          ),
          if (_selectedDay != null) ...[
            const Divider(),
            Expanded(
              child: _buildSelectedDayView(logsMap),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSelectedDayView(Map<DateTime, DailyLog> logsMap) {
    final normalizedDay = DateTime(_selectedDay!.year, _selectedDay!.month, _selectedDay!.day);
    final log = logsMap[normalizedDay];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: log != null
          ? Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormat('EEEE, MMM d, y').format(_selectedDay!),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(log.moodEmoji, style: const TextStyle(fontSize: 64)),
                    ),
                    const SizedBox(height: 16),
                    _buildSymptomRow('Headache', log.headache, 3),
                    _buildSymptomRow('Stress', log.stress, 3),
                    _buildSymptomRow('Fatigue', log.fatigue, 3),
                    _buildSymptomRow('Pain Level', log.painLevel, 10),
                    if (log.notes.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Text('Notes:', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 4),
                      Text(log.notes),
                    ],
                  ],
                ),
              ),
            )
          : Center(
              child: Text(
                'No log for ${DateFormat('MMM d').format(_selectedDay!)}',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
    );
  }

  Widget _buildSymptomRow(String label, int value, int max) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          ),
          Expanded(
            child: LinearProgressIndicator(
              value: value / max,
              backgroundColor: Theme.of(context).colorScheme.surface,
              color: Theme.of(context).colorScheme.primary,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 12),
          Text('$value/$max'),
        ],
      ),
    );
  }
}