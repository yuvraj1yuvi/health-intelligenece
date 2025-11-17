import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'models/daily_log.dart';
import 'models/goals.dart';
import 'providers/theme_provider.dart';
import 'providers/daily_log_provider.dart';
import 'providers/goals_provider.dart';
import 'screens/home_screen.dart';
import 'theme/app_theme.dart';
import 'helpers/notification_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(DailyLogAdapter());
  Hive.registerAdapter(HealthGoalAdapter());
  Hive.registerAdapter(SmartReminderAdapter());
  
  // Open boxes with error handling
  try {
    await Hive.openBox<DailyLog>('daily_logs');
    await Hive.openBox('settings');
    await Hive.openBox<HealthGoal>('goals');
    await Hive.openBox<SmartReminder>('reminders');
  } catch (e) {
    // If boxes fail to open, continue anyway
    print('Failed to open Hive boxes: $e');
  }
  
  // Initialize timezone and notifications
  tz.initializeTimeZones();
  try {
    await NotificationHelper.initialize();
  } catch (e) {
    print('Failed to initialize notifications: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => DailyLogProvider()),
        ChangeNotifierProvider(create: (_) => GoalsProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp(
            title: 'Health Intelligence',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}