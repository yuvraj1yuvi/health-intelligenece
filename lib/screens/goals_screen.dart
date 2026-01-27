import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_log_provider.dart';
import '../providers/goals_provider.dart';
import '../models/goals.dart';

class GoalsScreen extends StatefulWidget {
  const GoalsScreen({super.key});

  @override
  State<GoalsScreen> createState() => _GoalsScreenState();
}

class _GoalsScreenState extends State<GoalsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Goals & Streaks'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showCreateGoalDialog,
            tooltip: 'Create Goal',
          ),
        ],
      ),
      body: Consumer2<DailyLogProvider, GoalsProvider>(
        builder: (context, dailyProvider, goalsProvider, child) {
          final logs = dailyProvider.getAllLogs();
          final streakInfo = goalsProvider.calculateStreak(logs);

          return RefreshIndicator(
            onRefresh: () async {
              // Update goal progress
              for (final goal in goalsProvider.goals) {
                await goalsProvider.updateGoalProgress(goal.id, logs);
              }
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildStreakCard(streakInfo),
                const SizedBox(height: 16),
                _buildGoalsSection(goalsProvider.goals, logs),
                const SizedBox(height: 16),
                _buildQuickGoalsSection(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStreakCard(StreakInfo streakInfo) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Text(
                  streakInfo.badgeEmoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        streakInfo.streakText,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Longest streak: ${streakInfo.longestStreak} days',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: streakInfo.currentStreak / max(streakInfo.longestStreak, 7),
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${streakInfo.totalLogs} total logs',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalsSection(List<HealthGoal> goals, List logs) {
    if (goals.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Icon(
                Icons.flag_outlined,
                size: 48,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Goals Yet',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Set goals to track your progress and stay motivated',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Your Goals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ...goals.map((goal) => Card(
          child: ListTile(
            leading: Icon(
              _getGoalIcon(goal.type),
              color: goal.isCompleted
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            title: Text(goal.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(goal.description),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: goal.progress,
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.isCompleted
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.secondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  goal.progressText,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
            trailing: goal.isCompleted
                ? const Icon(Icons.check_circle, color: Colors.green)
                : IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _deleteGoal(goal.id),
                  ),
          ),
        )),
      ],
    );
  }

  Widget _buildQuickGoalsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Quick Goals',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              _buildQuickGoalTile(
                '7-Day Logging Streak',
                'Log symptoms every day for a week',
                Icons.local_fire_department,
                () => _createQuickGoal('logging_streak', '7-Day Logging Streak', 'Log symptoms every day for a week', {'days': 7}),
              ),
              const Divider(height: 1),
              _buildQuickGoalTile(
                'Reduce Headache Frequency',
                'Keep headache levels below 2 on average',
                Icons.healing,
                () => _createQuickGoal('symptom_reduction', 'Reduce Headache Frequency', 'Keep headache levels below 2 on average', {'symptom': 'headache', 'targetLevel': 2}),
              ),

              const Divider(height: 1),
              _buildQuickGoalTile(
                '8 Hours Sleep',
                'Get at least 8 hours of sleep nightly',
                Icons.bed,
                () => _createQuickGoal('sleep', '8 Hours Sleep', 'Get at least 8 hours of sleep nightly', {'hours': 8}),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickGoalTile(String title, String description, IconData icon, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
      title: Text(title),
      subtitle: Text(description),
      trailing: const Icon(Icons.add),
      onTap: onTap,
    );
  }

  IconData _getGoalIcon(String type) {
    switch (type) {
      case 'symptom_reduction':
        return Icons.healing;
      case 'logging_streak':
        return Icons.local_fire_department;
      case 'exercise':
        return Icons.fitness_center;
      case 'sleep':
        return Icons.bed;
      default:
        return Icons.flag;
    }
  }

  void _showCreateGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create Custom Goal'),
        content: const Text('Custom goal creation coming soon! Use Quick Goals for now.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _createQuickGoal(String type, String title, String description, Map<String, dynamic> target) async {
    final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
    await goalsProvider.createGoal(
      title: title,
      description: description,
      type: type,
      target: target,
    );

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal "$title" created!')),
    );
  }

  void _deleteGoal(String goalId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: const Text('Are you sure you want to delete this goal?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final goalsProvider = Provider.of<GoalsProvider>(context, listen: false);
      await goalsProvider.deleteGoal(goalId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Goal deleted')),
      );
    }
  }
}
