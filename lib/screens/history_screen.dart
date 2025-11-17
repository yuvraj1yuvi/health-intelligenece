import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/daily_log_provider.dart';
import 'log_details_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DailyLogProvider>(context);
    final logs = provider.getAllLogs();

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: logs.isEmpty
          ? const Center(
              child: Text('No logs yet', style: TextStyle(fontSize: 18)),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: logs.length,
              itemBuilder: (context, index) {
                final log = logs[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    leading: Text(
                      log.moodEmoji,
                      style: const TextStyle(fontSize: 40),
                    ),
                    title: Text(
                      DateFormat('EEEE, MMM d, y').format(log.date),
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(log.symptomSummary),
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => LogDetailsScreen(log: log),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
