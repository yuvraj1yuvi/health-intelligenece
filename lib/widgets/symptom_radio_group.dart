import 'package:flutter/material.dart';

class SymptomRadioGroup extends StatelessWidget {
  final String label;
  final int value;
  final Function(int) onChanged;

  const SymptomRadioGroup({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(4, (index) {
            return Expanded(
              child: Column(
                children: [
                  Radio<int>(
                    value: index,
                    groupValue: value,
                    onChanged: (val) => onChanged(val!),
                  ),
                  Text(
                    index.toString(),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }
}