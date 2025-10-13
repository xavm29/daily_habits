import 'package:daily_habits/models/completed_goal.dart';
import 'package:daily_habits/models/goals_model.dart';
import 'package:flutter/material.dart';

class QuantitativeDialog extends StatefulWidget {
  final Goal goal;
  final Function(double value, String? notes, String? mood) onComplete;

  const QuantitativeDialog({
    Key? key,
    required this.goal,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<QuantitativeDialog> createState() => _QuantitativeDialogState();
}

class _QuantitativeDialogState extends State<QuantitativeDialog> {
  late TextEditingController valueController;
  late TextEditingController notesController;
  String? selectedMood;

  final List<Map<String, dynamic>> moods = [
    {'emoji': '😊', 'label': 'Great'},
    {'emoji': '🙂', 'label': 'Good'},
    {'emoji': '😐', 'label': 'Okay'},
    {'emoji': '😔', 'label': 'Bad'},
    {'emoji': '😢', 'label': 'Terrible'},
  ];

  @override
  void initState() {
    super.initState();
    valueController = TextEditingController();
    notesController = TextEditingController();
  }

  @override
  void dispose() {
    valueController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String unitLabel = widget.goal.goalType == Goal.kTypeDuration
        ? (widget.goal.unit ?? 'minutes')
        : (widget.goal.unit ?? 'units');

    return AlertDialog(
      title: Text(widget.goal.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Target: ${widget.goal.targetValue} $unitLabel',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: valueController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Achieved Value',
                suffixText: unitLabel,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'How do you feel?',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: moods.map((mood) {
                bool isSelected = selectedMood == mood['label'];
                return ChoiceChip(
                  label: Text('${mood['emoji']} ${mood['label']}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      selectedMood = selected ? mood['label'] : null;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: notesController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
                hintText: 'Add any notes about this completion...',
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (valueController.text.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a value')),
              );
              return;
            }

            double? value = double.tryParse(valueController.text);
            if (value == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid number')),
              );
              return;
            }

            String? notes = notesController.text.isEmpty ? null : notesController.text;
            widget.onComplete(value, notes, selectedMood);
            Navigator.pop(context);
          },
          child: const Text('Complete'),
        ),
      ],
    );
  }
}
