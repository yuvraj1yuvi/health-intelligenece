import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:daily_symptoms_tracker/main.dart';
import 'package:daily_symptoms_tracker/models/daily_log.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(DailyLogAdapter());
    
    // Open boxes for testing
    await Hive.openBox<DailyLog>('daily_logs');
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    // Close boxes after testing
    await Hive.close();
  });

  testWidgets('App launches and displays home screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the app title is displayed.
    expect(find.text('Daily Symptoms Tracker'), findsOneWidget);
    
    // Verify that we can find the main UI elements.
    expect(find.byType(Card), findsWidgets);
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}