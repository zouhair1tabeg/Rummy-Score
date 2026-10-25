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

    Color cardBorderColor = Colors.white.withValues(alpha: 0.9);
    Color progressColor = AppColors.primary;
    Color cardBg = Colors.white.withValues(alpha: 0.88);

    if (player.isEliminated) {
      cardBg = Colors.white.withValues(alpha: 0.55);
      cardBorderColor = AppColors.glassBorderSubtle;
      progressColor = AppColors.danger.withValues(alpha: 0.4);
    } else if (isWinner) {
      cardBg = const Color(0xFFF7F8FE);
      cardBorderColor = AppColors.primary.withValues(alpha: 0.5);
      progressColor = AppColors.primary;
    } else if (isDanger) {
      cardBg = const Color(0xFFFEF7F7);
      cardBorderColor = AppColors.danger.withValues(alpha: 0.45);
      progressColor = AppColors.danger;
    } else if (isWarning) {
      cardBorderColor = AppColors.warning.withValues(alpha: 0.4);
      progressColor = AppColors.warning;
    }

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: cardBorderColor,
          width: isWinner || isDanger ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25283B).withValues(alpha: 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top row: Avatar rank + Player name + status badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: isWinner
                          ? AppColors.primary
                          : (player.isEliminated
                                ? const Color(0xFFE5E7EB)
                                : const Color(0xFFE8EEFC)),
                      child: Text(
                        '$rank',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isWinner
                              ? Colors.white
                              : (player.isEliminated
                                    ? AppColors.textMuted
                                    : AppColors.primaryDark),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        player.name,
                        style: TextStyle(
                          fontSize: 14,
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
                    const SizedBox(width: 4),
                    _buildStatusBadge(),
                  ],
                ),

                // Middle: Score Display
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '${player.cumulativeScore}',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: player.isEliminated
                            ? AppColors.textMuted
                            : (isDanger
                                  ? AppColors.danger
                                  : AppColors.textPrimary),
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      '/ $eliminationLimit',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),

                // Bottom: Progress bar & Revanche indicator
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 5,
                        backgroundColor: const Color(0xFFE9ECF2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          progressColor,
                        ),
                      ),
                    ),
                    if (player.revancheUsed) ...[
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 11,
                            color: AppColors.secondaryDark,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              player.revancheScoreTaken != null
                                  ? 'Revanche (${player.revancheScoreTaken} pts)'
                                  : 'Revanche',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.secondaryDark,
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
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EEFC),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '👑 Vainqueur',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.primaryDark,
          ),
        ),
      );
    }

    if (player.isEliminated) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F2F6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          player.eliminatedAtRound != null
              ? 'M${player.eliminatedAtRound}'
              : 'Éliminé',
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    if (player.cumulativeScore >= eliminationLimit) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.dangerSurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          '⚠️ Éliminé',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.danger,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.successSurface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        'En jeu',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: AppColors.success,
        ),
      ),
    );
  }
}
