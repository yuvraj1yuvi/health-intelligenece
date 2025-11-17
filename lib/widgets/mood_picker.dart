import 'package:flutter/material.dart';

class MoodPicker extends StatelessWidget {
  final int selectedMood;
  final Function(int) onMoodChanged;

  const MoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodChanged,
  });

  @override
  Widget build(BuildContext context) {
    final moods = [
      {'emoji': '😄', 'value': 1},
      {'emoji': '🙂', 'value': 2},
      {'emoji': '😐', 'value': 3},
      {'emoji': '😕', 'value': 4},
      {'emoji': '😢', 'value': 5},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: moods.map((mood) {
        final isSelected = selectedMood == mood['value'];
        return GestureDetector(
          onTap: () => onMoodChanged(mood['value'] as int),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected
                  ? Theme.of(context).colorScheme.primaryContainer
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              mood['emoji'] as String,
              style: TextStyle(
                fontSize: isSelected ? 48 : 40,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
