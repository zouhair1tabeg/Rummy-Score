import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../logic/game_engine.dart';
import '../models/game.dart';
import '../state/game_notifier.dart';
import 'new_game_screen.dart';

class GameOverScreen extends StatelessWidget {
  final Game game;
  final GameNotifier notifier;

  const GameOverScreen({super.key, required this.game, required this.notifier});

  @override
  Widget build(BuildContext context) {
    final rankings = GameEngine.calculateRankings(game);
    final winner =
        game.winner ?? (rankings.isNotEmpty ? rankings.first.player : null);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              // Trophy / Winner Banner
              Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceElevated,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.gold, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.gold.withValues(alpha: 0.35),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.emoji_events_rounded,
                    size: 64,
                    color: AppColors.gold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Partie terminée !',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                winner != null
                    ? '${winner.name} remporte la partie 👑'
                    : 'Le dernier joueur en lice est déclaré vainqueur.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.goldLight,
                ),
              ),
              const SizedBox(height: 24),

              // Game summary chips
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildSummaryItem('Manches', '${game.rounds.length}'),
                    Container(height: 24, width: 1, color: AppColors.border),
                    _buildSummaryItem('Joueurs', '${game.players.length}'),
                    Container(height: 24, width: 1, color: AppColors.border),
                    _buildSummaryItem('Limite', '${game.eliminationLimit} pts'),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Final Rankings Section
              const Text(
                'Classement final',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),

              ...rankings.map((entry) {
                return _buildRankingCard(entry);
              }),

              const SizedBox(height: 28),

              // Actions
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (_) => NewGameScreen(notifier: notifier),
                    ),
                  );
                },
                icon: const Icon(Icons.replay_rounded, size: 22),
                label: const Text(
                  'Nouvelle partie',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                icon: const Icon(Icons.home_rounded, size: 20),
                label: const Text(
                  'Retour à l\'accueil',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
        ),
      ],
    );
  }

  Widget _buildRankingCard(PlayerRanking entry) {
    final isFirst = entry.rank == 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isFirst ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isFirst ? AppColors.gold : AppColors.border,
          width: isFirst ? 1.8 : 1.0,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isFirst ? AppColors.gold : AppColors.surfaceLight,
            child: Text(
              '${entry.rank}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isFirst ? AppColors.background : AppColors.textPrimary,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.player.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isFirst
                              ? AppColors.goldLight
                              : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isFirst)
                      const Text(
                        '👑 Vainqueur',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.gold,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Text(
                      entry.statusDescription,
                      style: TextStyle(
                        fontSize: 12,
                        color: isFirst
                            ? AppColors.emeraldAccent
                            : AppColors.textMuted,
                      ),
                    ),
                    if (entry.player.revancheUsed) ...[
                      const SizedBox(width: 6),
                      const Text(
                        '• Revanche utilisée',
                        style: TextStyle(fontSize: 11, color: AppColors.gold),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.player.cumulativeScore}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: isFirst ? AppColors.goldLight : AppColors.textPrimary,
                ),
              ),
              const Text(
                'pts final',
                style: TextStyle(fontSize: 10, color: AppColors.textMuted),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
