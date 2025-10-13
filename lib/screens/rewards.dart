import 'package:daily_habits/models/reward_model.dart';
import 'package:daily_habits/services/reward_service.dart';
import 'package:daily_habits/styles/styles.dart';
import 'package:flutter/material.dart';

class RewardsScreen extends StatefulWidget {
  const RewardsScreen({Key? key}) : super(key: key);

  @override
  State<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends State<RewardsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final List<Reward> availableRewards = Reward.getDefaultRewards();

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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Rewards'),
        backgroundColor: AppColors.primarys,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          tabs: const [
            Tab(text: 'Available', icon: Icon(Icons.card_giftcard)),
            Tab(text: 'Redeemed', icon: Icon(Icons.check_circle)),
          ],
        ),
      ),
      body: Column(
        children: [
          _buildCoinsHeader(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAvailableRewards(),
                _buildRedeemedRewards(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoinsHeader() {
    return StreamBuilder<UserCoins>(
      stream: RewardService.instance.getUserCoins(),
      builder: (context, snapshot) {
        final coins = snapshot.data ?? UserCoins();

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primarys, AppColors.primarys.withOpacity(0.7)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildCoinsStat(
                'Available Coins',
                coins.availableCoins,
                Icons.monetization_on,
                Colors.amber,
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildCoinsStat(
                'Total Earned',
                coins.totalCoins,
                Icons.star,
                Colors.yellow,
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildCoinsStat(
                'Spent',
                coins.spentCoins,
                Icons.shopping_cart,
                Colors.white70,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCoinsStat(String label, int value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildAvailableRewards() {
    return StreamBuilder<UserCoins>(
      stream: RewardService.instance.getUserCoins(),
      builder: (context, snapshot) {
        final userCoins = snapshot.data ?? UserCoins();

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: availableRewards.length,
          itemBuilder: (context, index) {
            final reward = availableRewards[index];
            final canAfford = userCoins.availableCoins >= reward.cost;

            return _buildRewardCard(reward, canAfford, userCoins);
          },
        );
      },
    );
  }

  Widget _buildRewardCard(Reward reward, bool canAfford, UserCoins userCoins) {
    return Card(
      elevation: canAfford ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: canAfford
            ? BorderSide(color: reward.color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: canAfford
            ? () => _showRedeemDialog(reward, userCoins)
            : () => _showInsufficientCoinsDialog(reward, userCoins),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: reward.color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  reward.icon,
                  size: 40,
                  color: reward.color,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                reward.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                reward.description,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: canAfford ? Colors.amber : Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.monetization_on,
                      size: 16,
                      color: canAfford ? Colors.white : Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${reward.cost}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: canAfford ? Colors.white : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              if (!canAfford) ...[
                const SizedBox(height: 8),
                Text(
                  'Need ${reward.cost - userCoins.availableCoins} more',
                  style: const TextStyle(
                    fontSize: 10,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRedeemedRewards() {
    return StreamBuilder<List<Reward>>(
      stream: RewardService.instance.getRedeemedRewards(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.card_giftcard, size: 64, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'No rewards redeemed yet',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Complete habits to earn coins!',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        final redeemedRewards = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: redeemedRewards.length,
          itemBuilder: (context, index) {
            final reward = redeemedRewards[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: reward.color.withOpacity(0.2),
                  child: Icon(reward.icon, color: reward.color),
                ),
                title: Text(reward.title),
                subtitle: Text(
                  reward.redeemedAt != null
                      ? 'Redeemed ${_formatDate(reward.redeemedAt!)}'
                      : 'Redeemed',
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.monetization_on, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        '${reward.cost}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRedeemDialog(Reward reward, UserCoins userCoins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Redeem ${reward.title}?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(reward.icon, size: 64, color: reward.color),
            const SizedBox(height: 16),
            Text(reward.description, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            Text(
              'Cost: ${reward.cost} coins',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(
              'You\'ll have ${userCoins.availableCoins - reward.cost} coins left',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await RewardService.instance.redeemReward(reward);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('🎉 ${reward.title} redeemed! Enjoy!'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Failed to redeem reward'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: reward.color),
            child: const Text('Redeem'),
          ),
        ],
      ),
    );
  }

  void _showInsufficientCoinsDialog(Reward reward, UserCoins userCoins) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Insufficient Coins'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning, size: 64, color: Colors.orange),
            const SizedBox(height: 16),
            Text(
              'You need ${reward.cost - userCoins.availableCoins} more coins to redeem this reward.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            const Text(
              'Complete more habits to earn coins!',
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}
