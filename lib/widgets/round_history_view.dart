import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/game.dart';
import '../models/round.dart';
import '../utils/date_formatter.dart';

class RoundHistoryView extends StatelessWidget {
  final Game game;
  final VoidCallback? onUndoLastRound;

  const RoundHistoryView({super.key, required this.game, this.onUndoLastRound});

  @override
  Widget build(BuildContext context) {
    if (game.rounds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.style_outlined,
                size: 54,
                color: AppColors.textMuted.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aucune manche enregistrée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Appuyez sur "Ajouter une manche" pour commencer à saisir les scores.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    final reversedRounds = game.rounds.reversed.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Historique des manches (${game.rounds.length})',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (onUndoLastRound != null && game.undoSnapshots.isNotEmpty)
                TextButton.icon(
                  onPressed: onUndoLastRound,
                  icon: const Icon(
                    Icons.undo,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  label: const Text(
                    'Annuler la dernière',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppColors.warning,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                  ),
                ),
            ],
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reversedRounds.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final round = reversedRounds[index];
            final isLatest = index == 0;
            return _buildRoundCard(context, round, isLatest);
          },
        ),
      ],
    );
  }

  Widget _buildRoundCard(BuildContext context, Round round, bool isLatest) {
    final winner = game.players
        .where((p) => p.id == round.winnerId)
        .firstOrNull;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isLatest ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isLatest
              ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.border,
          width: isLatest ? 1.4 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Round #, Time, Winner
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Manche ${round.roundNumber}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldLight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    AppDateFormatter.formatTime(round.timestamp),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              if (winner != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.emoji_events,
                      size: 14,
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Text(
                        winner.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.goldLight,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Scores grid/row for each participating player
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: game.players.map((player) {
              final added = round.scoresAdded[player.id];
              final totalAfter = round.cumulativeScoresAfter[player.id];
              final isWinner = player.id == round.winnerId;

              if (added == null && totalAfter == null) {
                // Player was eliminated prior to this round
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.border.withValues(alpha: 0.4),
                    ),
                  ),
                  child: Text(
                    '${player.name}: —',
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isWinner
                      ? AppColors.gold.withValues(alpha: 0.15)
                      : AppColors.background,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isWinner
                        ? AppColors.gold.withValues(alpha: 0.6)
                        : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${player.name}: ',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isWinner
                            ? AppColors.goldLight
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '+${added ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isWinner
                            ? AppColors.emeraldAccent
                            : (added != null && added > 0
                                  ? AppColors.warning
                                  : AppColors.textPrimary),
                      ),
                    ),
                    if (totalAfter != null) ...[
                      Text(
                        ' → $totalAfter',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),

          // Revanche / Elimination events if any
          if (round.revancheEvents.isNotEmpty ||
              round.eliminationEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.background.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...round.revancheEvents.entries.map((entry) {
                    final p = game.players
                        .where((pl) => pl.id == entry.key)
                        .firstOrNull;
                    return Text(
                      '🛡️ Revanche : ${p?.name ?? 'Joueur'} a copié le score de ${entry.value} pts',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.gold,
                      ),
                    );
                  }),
                  ...round.eliminationEvents.map((playerId) {
                    final p = game.players
                        .where((pl) => pl.id == playerId)
                        .firstOrNull;
                    return Text(
                      '❌ Élimination définitive : ${p?.name ?? 'Joueur'}',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.danger,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
