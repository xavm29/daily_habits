import 'package:daily_habits/models/challenge_model.dart';
import 'package:daily_habits/models/challenge_progress_model.dart';
import 'package:daily_habits/screens/challenge_detail_screen.dart';
import 'package:daily_habits/services/challenge_service.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../l10n/app_localizations.dart';

class Challenges extends StatefulWidget {
  const Challenges({Key? key}) : super(key: key);

  @override
  State<Challenges> createState() => _ChallengesState();
}

class _ChallengesState extends State<Challenges> with SingleTickerProviderStateMixin {
  final ChallengeService _challengeService = ChallengeService.instance;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(l10n.challenges),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
        actions: [
          // Botón temporal para recrear retos (DEBUG)
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () async {
              await _challengeService.recreateDefaultChallenges();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.challengesRecreated),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(text: l10n.myChallenges),
            Tab(text: l10n.allChallenges),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyChallengesTodo(),
          _buildAllChallenges(),
        ],
      ),
    );
  }

  // Tab para los retos en los que el usuario está participando
  Widget _buildMyChallengesTodo() {
    return StreamBuilder<List<Challenge>>(
      stream: _challengeService.getUserChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          final l10n = AppLocalizations.of(context);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_outlined, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  l10n.noChalllengesYet,
                  style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.goToAllChallenges,
                  style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            return _buildChallengeCard(challenges[index], isParticipating: true);
          },
        );
      },
    );
  }

  // Tab para todos los retos disponibles
  Widget _buildAllChallenges() {
    return StreamBuilder<List<Challenge>>(
      stream: _challengeService.getActiveChallenges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final challenges = snapshot.data ?? [];

        if (challenges.isEmpty) {
          final l10n = AppLocalizations.of(context);
          return Center(
            child: Text(l10n.noChallengesAvailable),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: challenges.length,
          itemBuilder: (context, index) {
            final challenge = challenges[index];
            // No pasamos isParticipating aquí, lo calculamos dinámicamente en la tarjeta
            return _buildChallengeCardDynamic(challenge);
          },
        );
      },
    );
  }

  // Tarjeta con detección dinámica de participación
  Widget _buildChallengeCardDynamic(Challenge challenge) {
    // Recalcular isParticipating cada vez que el challenge se actualiza
    final isParticipating = challenge.isParticipant(
      _challengeService.currentUserId ?? '',
    );
    return _buildChallengeCard(challenge, isParticipating: isParticipating);
  }

  // Construye la tarjeta del reto con progreso real
  Widget _buildChallengeCard(Challenge challenge, {required bool isParticipating}) {
    final l10n = AppLocalizations.of(context);
    return StreamBuilder<ChallengeProgress?>(
      stream: isParticipating
        ? _challengeService.getUserProgress(challenge.id)
        : Stream.value(null),
      builder: (context, progressSnapshot) {
        final progress = progressSnapshot.data;
        final progressPercent = progress?.getProgress(challenge.targetCount) ?? 0.0;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16.0),
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: InkWell(
              onTap: isParticipating
                  ? () => _navigateToChallengeDetail(challenge)
                  : null,
              borderRadius: BorderRadius.circular(12),
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
                                  _CategoryChip(category: challenge.category),
                                  const Spacer(),
                                  if (challenge.isActiveNow())
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green[100],
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        l10n.active,
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
                                challenge.getLocalizedTitle(l10n),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                challenge.getLocalizedDescription(l10n),
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
                                    '${challenge.durationDays} ${l10n.daysLabel}',
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
                                    '${challenge.participants.length} ${l10n.participantsLabel}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              if (isParticipating && progress != null) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.local_fire_department,
                                        size: 16, color: Colors.orange[700]),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${l10n.streakLabel}: ${progress.currentStreak} ${l10n.daysLabel}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange[700],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        if (isParticipating)
                          CircularPercentIndicator(
                            radius: 40.0,
                            lineWidth: 8.0,
                            percent: progressPercent,
                            center: Text(
                              "${(progressPercent * 100).toInt()}%",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            progressColor: _getProgressColor(progressPercent),
                            backgroundColor: Colors.grey[200]!,
                            circularStrokeCap: CircularStrokeCap.round,
                          ),
                      ],
                    ),
                    if (isParticipating && progress != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        '${progress.completedDays} de ${challenge.targetCount} ${l10n.daysCompleted}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    if (challenge.isActiveNow())
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                if (isParticipating) {
                                  await _challengeService.leaveChallenge(challenge.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.leftChallenge),
                                      ),
                                    );
                                  }
                                } else {
                                  await _challengeService.joinChallenge(challenge.id);
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(l10n.joinedChallenge),
                                      ),
                                    );
                                  }
                                }
                              },
                              icon: Icon(isParticipating
                                  ? Icons.exit_to_app
                                  : Icons.emoji_events),
                              label: Text(isParticipating
                                  ? l10n.leaveChallenge
                                  : l10n.joinChallenge),
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
                              '${challenge.getDaysRemaining()} ${l10n.daysRemaining}',
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
          ),
        );
      },
    );
  }

  void _navigateToChallengeDetail(Challenge challenge) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChallengeDetailScreen(challenge: challenge),
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
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(l10n.createCustomChallenge),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: l10n.challengeTitleLabel,
                hintText: l10n.challengeTitleHint,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: l10n.descriptionLabel,
                hintText: l10n.descriptionHint,
                border: const OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: durationController,
              decoration: InputDecoration(
                labelText: l10n.durationDaysLabel,
                hintText: l10n.durationHint,
                border: const OutlineInputBorder(),
                suffixText: l10n.daysLabel,
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: targetController,
              decoration: InputDecoration(
                labelText: l10n.targetDaysLabel,
                hintText: l10n.targetDaysHint,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: InputDecoration(
                labelText: l10n.categoryLabel,
                border: const OutlineInputBorder(),
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
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: () {
            // Validate inputs
            if (titleController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pleaseEnterTitle)),
              );
              return;
            }

            if (descriptionController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pleaseEnterDescription)),
              );
              return;
            }

            final duration = int.tryParse(durationController.text);
            if (duration == null || duration < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.pleaseEnterValidDuration)),
              );
              return;
            }

            final target = int.tryParse(targetController.text);
            if (target == null || target < 1) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text(l10n.pleaseEnterValidTarget)),
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
                content: Text(l10n.challengeCreatedMessage(newChallenge.title)),
                backgroundColor: Colors.green,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primarys,
            foregroundColor: Colors.white,
          ),
          child: Text(l10n.createButton),
        ),
      ],
    );
  }
}
