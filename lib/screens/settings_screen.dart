import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive/hive.dart';
import '../providers/theme_provider.dart';
import '../helpers/notification_helper.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  TimeOfDay? _reminderTime;

  @override
  void initState() {
    super.initState();
    _loadReminderTime();
  }

  void _loadReminderTime() {
    final box = Hive.box('settings');
    final hour = box.get('reminderHour', defaultValue: 20);
    final minute = box.get('reminderMinute', defaultValue: 0);
    setState(() {
      _reminderTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
    );

    if (picked != null) {
      setState(() {
        _reminderTime = picked;
      });
      
      final box = Hive.box('settings');
      await box.put('reminderHour', picked.hour);
      await box.put('reminderMinute', picked.minute);
      
      await NotificationHelper.scheduleDailyReminder(picked);
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reminder time updated')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: SwitchListTile(
              title: const Text('Dark Mode'),
              subtitle: const Text('Switch between light and dark theme'),
              value: themeProvider.isDark,
              onChanged: (_) => themeProvider.toggleTheme(),
              secondary: Icon(
                themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text('Daily Reminder'),
              subtitle: Text(
                _reminderTime != null
                    ? 'Remind me at ${_reminderTime!.format(context)}'
                    : 'Not set',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectTime,
            ),
          ),
        ],
      ),
    );
  }
}
