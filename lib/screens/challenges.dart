import 'package:daily_habits/models/challenge_model.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> {
  final List<Challenge> challenges = [];

  @override
  void initState() {
    super.initState();
    _loadChallenges();
  }

  void _loadChallenges() {
    // Sample challenges - in production these would come from Firebase
    DateTime now = DateTime.now();

    challenges.add(Challenge(
      title: '7-Day Consistency Challenge',
      description: 'Complete all your habits for 7 days straight',
      durationDays: 7,
      startDate: now.subtract(const Duration(days: 2)),
      endDate: now.add(const Duration(days: 5)),
      participants: ['user1', 'user2', 'user3'],
      createdBy: 'system',
      category: 'Consistency',
      targetCount: 7,
    ));

    challenges.add(Challenge(
      title: '30-Day Fitness Challenge',
      description: 'Exercise every day for 30 days',
      durationDays: 30,
      startDate: now.subtract(const Duration(days: 5)),
      endDate: now.add(const Duration(days: 25)),
      participants: ['user1', 'user2'],
      createdBy: 'system',
      category: 'Health',
      targetCount: 30,
    ));

    challenges.add(Challenge(
      title: 'Morning Routine Master',
      description: 'Start your day right with a morning routine',
      durationDays: 21,
      startDate: now,
      endDate: now.add(const Duration(days: 21)),
      participants: ['user1'],
      createdBy: 'system',
      category: 'Productivity',
      targetCount: 21,
    ));

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Challenges'),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateChallengeDialog();
            },
          ),
        ],
      ),
      body: challenges.isEmpty
          ? const Center(
              child: Text('No challenges available'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: challenges.length,
              itemBuilder: (BuildContext context, int index) {
                final challenge = challenges[index];
                final isParticipating =
                    challenge.participants.contains('user1');
                final progress = challenge.getProgress(
                    isParticipating ? index * 3 : 0);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        _CategoryChip(
                                            category: challenge.category),
                                        const Spacer(),
                                        if (challenge.isActive())
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              'Active',
                                              style: TextStyle(
                                                color: Colors.green[700],
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      challenge.title,
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      challenge.description,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Icon(Icons.calendar_today,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${challenge.durationDays} days',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.people,
                                            size: 16, color: Colors.grey[600]),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${challenge.participants.length} joined',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              CircularPercentIndicator(
                                radius: 40.0,
                                lineWidth: 8.0,
                                percent: progress,
                                center: Text(
                                  "${(progress * 100).toInt()}%",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                progressColor: _getProgressColor(progress),
                                backgroundColor: Colors.grey[200]!,
                                circularStrokeCap: CircularStrokeCap.round,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (challenge.isActive())
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        if (isParticipating) {
                                          challenge.participants.remove('user1');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Left challenge successfully'),
                                            ),
                                          );
                                        } else {
                                          challenge.participants.add('user1');
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Joined challenge successfully!'),
                                            ),
                                          );
                                        }
                                      });
                                    },
                                    icon: Icon(isParticipating
                                        ? Icons.exit_to_app
                                        : Icons.emoji_events),
                                    label: Text(isParticipating
                                        ? 'Leave Challenge'
                                        : 'Join Challenge'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: isParticipating
                                          ? Colors.grey[300]
                                          : AppColors.purplelow,
                                      foregroundColor: isParticipating
                                          ? Colors.black87
                                          : Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                if (isParticipating) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    '${challenge.getDaysRemaining()} days left',
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _showCreateChallengeDialog() {
    showDialog(
      context: context,
      builder: (context) => _CreateChallengeDialog(
        onChallengeCreated: (challenge) {
          setState(() {
            challenges.add(challenge);
          });
        },
      ),
    );
  }

  Color _getProgressColor(double progress) {
    if (progress < 0.3) return Colors.red;
    if (progress < 0.7) return Colors.orange;
    return Colors.green;
  }
}

class _CategoryChip extends StatelessWidget {
  final String category;

  const _CategoryChip({required this.category});

  @override
  Widget build(BuildContext context) {
    final colors = {
      'Consistency': Colors.blue,
      'Health': Colors.green,
      'Productivity': Colors.purple,
      'General': Colors.grey,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (colors[category] ?? Colors.grey).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        category,
        style: TextStyle(
          color: colors[category] ?? Colors.grey,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _CreateChallengeDialog extends StatefulWidget {
  final Function(Challenge) onChallengeCreated;

  const _CreateChallengeDialog({required this.onChallengeCreated});

  @override
  State<_CreateChallengeDialog> createState() => _CreateChallengeDialogState();
}

class _CreateChallengeDialogState extends State<_CreateChallengeDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  final durationController = TextEditingController(text: '7');
  final targetController = TextEditingController(text: '7');
  String selectedCategory = 'General';

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    durationController.dispose();
    targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Create Custom Challenge'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Challenge Title*',
                hintText: 'e.g., Morning Meditation Challenge',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description*',
                hintText: 'What is this challenge about?',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (days)*',
                hintText: 'e.g., 7, 14, 21, 30',
                border: OutlineInputBorder(),
                suffixText: 'days',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              decoration: const InputDecoration(
                labelText: 'Target Count*',
                hintText: 'e.g., 7 days of completion',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category*',
                border: OutlineInputBorder(),
              ),
              items: ['General', 'Consistency', 'Health', 'Productivity']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate inputs
            if (titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a title')),
              );
              return;
            }

            if (descriptionController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a description')),
              );
              return;
            }

            final duration = int.tryParse(durationController.text);
            if (duration == null || duration < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a valid duration')),
              );
              return;
            }

            final target = int.tryParse(targetController.text);
            if (target == null || target < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter a valid target count')),
              );
              return;
            }

            // Create new challenge
            final now = DateTime.now();
            final newChallenge = Challenge(
              title: titleController.text.trim(),
              description: descriptionController.text.trim(),
              durationDays: duration,
              startDate: now,
              endDate: now.add(Duration(days: duration)),
              participants: ['user1'], // Auto-join creator
              createdBy: 'user1',
              category: selectedCategory,
              targetCount: target,
            );

            widget.onChallengeCreated(newChallenge);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Challenge "${newChallenge.title}" created! 🎉'),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarys,
            foregroundColor: Colors.white,
          ),
          child: const Text('Create'),
        ),
      ],
    );
  }
}
