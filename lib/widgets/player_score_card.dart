import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/player.dart';

class PlayerScoreCard extends StatelessWidget {
  final Player player;
  final int eliminationLimit;
  final int rank;
  final bool isWinner;
  final VoidCallback? onTap;

  const PlayerScoreCard({
    super.key,
    required this.player,
    required this.eliminationLimit,
    required this.rank,
    this.isWinner = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (player.cumulativeScore / eliminationLimit).clamp(
      0.0,
      1.0,
    );
    final isDanger = player.cumulativeScore >= eliminationLimit;
    final isWarning =
        !isDanger && player.cumulativeScore >= (eliminationLimit * 0.75);

    Color cardBorderColor = AppColors.border;
    Color scoreColor = AppColors.textPrimary;
    Color progressColor = AppColors.emeraldAccent;

    if (player.isEliminated) {
      cardBorderColor = AppColors.border.withValues(alpha: 0.5);
      scoreColor = AppColors.textMuted;
      progressColor = AppColors.danger;
    } else if (isWinner) {
      cardBorderColor = AppColors.gold;
      scoreColor = AppColors.gold;
      progressColor = AppColors.gold;
    } else if (isDanger) {
      cardBorderColor = AppColors.danger;
      scoreColor = AppColors.danger;
      progressColor = AppColors.danger;
    } else if (isWarning) {
      cardBorderColor = AppColors.warning;
      scoreColor = AppColors.warning;
      progressColor = AppColors.warning;
    }

    return Container(
      decoration: BoxDecoration(
        color: player.isEliminated
            ? AppColors.surface.withValues(alpha: 0.6)
            : (isWinner ? AppColors.surfaceElevated : AppColors.surface),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cardBorderColor,
          width: isWinner || isDanger ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top row: Player name, rank & status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: isWinner
                          ? AppColors.gold
                          : (player.isEliminated
                                ? AppColors.surfaceLight
                                : AppColors.primaryLight),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: isWinner
                              ? AppColors.background
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: player.isEliminated
                              ? AppColors.textMuted
                              : AppColors.textPrimary,
                          decoration: player.isEliminated
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    _buildStatusBadge(),
                  ],
                ),
                const SizedBox(height: 10),

                // Score Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${player.cumulativeScore}',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: scoreColor,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '/ $eliminationLimit pts',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: AppColors.surfaceElevated,
                    valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                  ),
                ),

                // Revanche indicator if applicable
                if (player.revancheUsed) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.shield_outlined,
                        size: 14,
                        color: AppColors.gold,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          player.revancheScoreTaken != null
                              ? 'Revanche utilisée (${player.revancheScoreTaken} pts)'
                              : 'Revanche utilisée',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.gold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge() {
    if (isWinner) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.gold.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.gold, width: 1),
        ),
        child: const Text(
          '👑 Vainqueur',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.goldLight,
          ),
        ),
      );
    }

    if (player.isEliminated) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.danger.withValues(alpha: 0.6)),
        ),
        child: Text(
          player.eliminatedAtRound != null
              ? 'Éliminé (M${player.eliminatedAtRound})'
              : 'Éliminé',
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: AppColors.danger,
          ),
        ),
      );
    }

    if (player.cumulativeScore >= eliminationLimit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.danger),
        ),
        child: const Text(
          '⚠️ À éliminer',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.danger,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.6)),
      ),
      child: const Text(
        'En jeu',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.emeraldAccent,
        ),
      ),
    );
  }
}
