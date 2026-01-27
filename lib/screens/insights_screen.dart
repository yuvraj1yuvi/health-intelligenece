import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/daily_log_provider.dart';
import '../services/symptom_analysis_service.dart';
import '../models/pattern_analysis.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  PatternAnalysisResult? _analysisResult;

  @override
  void initState() {
    super.initState();
    _analyzePatterns();
  }

  void _analyzePatterns() {
    final provider = Provider.of<DailyLogProvider>(context, listen: false);
    final logs = provider.getAllLogs();
    final result = SymptomAnalysisService.analyzePatterns(logs);
    setState(() {
      _analysisResult = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Trends'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _analyzePatterns,
            tooltip: 'Refresh Analysis',
          ),
        ],
      ),
      body: _analysisResult == null
          ? const Center(child: CircularProgressIndicator())
          : _buildInsightsContent(),
    );
  }

  Widget _buildInsightsContent() {
    if (_analysisResult!.totalLogsAnalyzed < 3) {
      return _buildInsufficientDataView();
    }

    return RefreshIndicator(
      onRefresh: () async {
        _analyzePatterns();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCard(),
          const SizedBox(height: 16),
          if (_analysisResult!.insights.isNotEmpty) ...[
            _buildInsightsSection(),
            const SizedBox(height: 16),
          ],
          // Correlations section removed for policy compliance
          if (_analysisResult!.weeklyPatterns.isNotEmpty) ...[
            _buildWeeklyPatternsSection(),
            const SizedBox(height: 16),
          ],
          if (_analysisResult!.timePatterns.isNotEmpty) ...[
            _buildTimePatternsSection(),
          ],
        ],
      ),
    );
  }

  Widget _buildInsufficientDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.analytics_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'Not Enough Data',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Log your symptoms for at least 3 days to see meaningful patterns and insights.',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.add),
              label: const Text('Start Logging'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.insights,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analysis Summary',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Based on ${_analysisResult!.totalLogsAnalyzed} symptom logs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Last analyzed: ${_formatDateTime(_analysisResult!.analyzedAt)}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsightsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Key Insights',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ..._analysisResult!.insights.map((insight) => Card(
          child: ListTile(
            leading: Text(
              insight.icon,
              style: const TextStyle(fontSize: 24),
            ),
            title: Text(insight.title),
            subtitle: Text(insight.description),
            trailing: _buildPriorityIndicator(insight.priority),
          ),
        )),
      ],
    );
  }

  Widget _buildCorrelationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Symptom Correlations',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        ..._analysisResult!.correlations.take(5).map((correlation) => Card(
          child: ListTile(
            leading: const Icon(Icons.link),
            title: Text(
              '${_capitalizeFirst(_getSymptomDisplayName(correlation.symptom1))} & ${_capitalizeFirst(_getSymptomDisplayName(correlation.symptom2))}',
            ),
            subtitle: Text(correlation.description),
            trailing: Text(
              correlation.strengthLabel,
              style: TextStyle(
                color: _getCorrelationColor(correlation.strength),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        )),
      ],
    );
  }

  Widget _buildWeeklyPatternsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Weekly Patterns',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _analysisResult!.weeklyPatterns.map((pattern) {
                final painLevel = pattern.getAverageForSymptom('painLevel');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          pattern.dayOfWeek.substring(0, 3),
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: painLevel / 10, // Normalize to 0-1
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        painLevel.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimePatternsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Time-based Patterns',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: _analysisResult!.timePatterns.map((pattern) {
                final fatigueLevel = pattern.getAverageForSymptom('fatigue');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        child: Text(
                          pattern.timeOfDay,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ),
                      Expanded(
                        child: LinearProgressIndicator(
                          value: fatigueLevel / 3, // Normalize to 0-1 (fatigue is 0-3)
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        fatigueLevel.toStringAsFixed(1),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityIndicator(int priority) {
    Color color;
    switch (priority) {
      case 5:
        color = Colors.red;
        break;
      case 4:
        color = Colors.orange;
        break;
      case 3:
        color = Colors.yellow;
        break;
      case 2:
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Color _getCorrelationColor(double strength) {
    if (strength >= 0.7) return Colors.red;
    if (strength >= 0.5) return Colors.orange;
    if (strength >= 0.3) return Colors.yellow.shade700;
    return Colors.grey;
  }

  String _getSymptomDisplayName(String symptom) {
    switch (symptom) {
      case 'headache':
        return 'headaches';
      case 'stress':
        return 'stress';
      case 'fatigue':
        return 'fatigue';
      case 'painLevel':
        return 'pain';
      case 'mood':
        return 'mood';
      default:
        return symptom;
    }
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
