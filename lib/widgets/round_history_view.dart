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
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.style_outlined,
                  size: 38,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Aucune manche enregistrée',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Appuyez sur "Ajouter une manche" pour commencer à saisir les scores.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (onUndoLastRound != null && game.undoSnapshots.isNotEmpty)
                TextButton.icon(
                  onPressed: onUndoLastRound,
                  icon: const Icon(
                    Icons.undo_rounded,
                    size: 15,
                    color: AppColors.warning,
                  ),
                  label: const Text(
                    'Annuler la dernière',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warning,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    backgroundColor: AppColors.warningSurface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isLatest
            ? Colors.white.withValues(alpha: 0.95)
            : Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isLatest
              ? AppColors.primary.withValues(alpha: 0.4)
              : Colors.white.withValues(alpha: 0.8),
          width: isLatest ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25283B).withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
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
                      color: isLatest
                          ? const Color(0xFFE8EEFC)
                          : const Color(0xFFF1F3F8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'Manche ${round.roundNumber}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: isLatest
                            ? AppColors.primaryDark
                            : AppColors.textPrimary,
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
                      Icons.emoji_events_rounded,
                      size: 14,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 4),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 130),
                      child: Text(
                        winner.name,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Scores wrap
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: game.players.map((player) {
              final added = round.scoresAdded[player.id];
              final totalAfter = round.cumulativeScoresAfter[player.id];
              final isWinner = player.id == round.winnerId;

              if (added == null && totalAfter == null) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF4F5F9),
                    borderRadius: BorderRadius.circular(8),
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
                      ? const Color(0xFFE8EEFC)
                      : const Color(0xFFF7F8FB),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isWinner
                        ? AppColors.primary.withValues(alpha: 0.3)
                        : const Color(0xFFE9ECF2),
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
                            ? AppColors.primaryDark
                            : AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      '+${added ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: isWinner
                            ? AppColors.success
                            : (added != null && added > 0
                                  ? AppColors.textPrimary
                                  : AppColors.textSecondary),
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

          // Events (Revanche / Elimination)
          if (round.revancheEvents.isNotEmpty ||
              round.eliminationEvents.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F8FB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFECEFF5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...round.revancheEvents.entries.map((entry) {
                    final p = game.players
                        .where((pl) => pl.id == entry.key)
                        .firstOrNull;
                    return Row(
                      children: [
                        const Icon(
                          Icons.shield_rounded,
                          size: 13,
                          color: AppColors.secondaryDark,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Revanche : ${p?.name ?? 'Joueur'} a copié ${entry.value} pts',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.secondaryDark,
                          ),
                        ),
                      ],
                    );
                  }),
                  ...round.eliminationEvents.map((playerId) {
                    final p = game.players
                        .where((pl) => pl.id == playerId)
                        .firstOrNull;
                    return Row(
                      children: [
                        const Icon(
                          Icons.cancel_rounded,
                          size: 13,
                          color: AppColors.danger,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'Élimination définitive : ${p?.name ?? 'Joueur'}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
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
