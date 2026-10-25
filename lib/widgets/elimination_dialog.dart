import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../logic/game_engine.dart';
import '../models/game.dart';
import '../models/player.dart';

class EliminationDialog extends StatelessWidget {
  final Game game;
  final Player player;
  final VoidCallback onDefinitiveElimination;
  final VoidCallback onRevanche;

  const EliminationDialog({
    super.key,
    required this.game,
    required this.player,
    required this.onDefinitiveElimination,
    required this.onRevanche,
  });

  @override
  Widget build(BuildContext context) {
    final canRevanche = GameEngine.canTakeRevanche(game, player.id);
    final targetScore = GameEngine.getRevancheTargetScore(game, player.id);

    return PopScope(
      canPop: false,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.dangerSurface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: AppColors.danger,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Décision d\'élimination',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Player overview card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8F9FC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE8EBF2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player.name,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      RichText(
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                          children: [
                            const TextSpan(text: 'Score cumulé : '),
                            TextSpan(
                              text: '${player.cumulativeScore} pts',
                              style: const TextStyle(
                                color: AppColors.danger,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: ' (Limite : ${game.eliminationLimit} pts)',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Le joueur a atteint ou dépassé la limite. Choisissez son issue :',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 14),

                // Revanche option
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: canRevanche
                        ? const Color(0xFFF4F2FC)
                        : const Color(0xFFF7F8FB),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: canRevanche
                          ? AppColors.secondary.withValues(alpha: 0.5)
                          : const Color(0xFFE8EAF0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.shield_rounded,
                            size: 16,
                            color: canRevanche
                                ? AppColors.secondaryDark
                                : AppColors.textMuted,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Option 1 : La Revanche',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: canRevanche
                                  ? AppColors.secondaryDark
                                  : AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      if (player.revancheUsed)
                        const Text(
                          'Revanche déjà utilisée. Règle : une seule fois par joueur.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.danger,
                          ),
                        )
                      else if (targetScore == null)
                        const Text(
                          'Aucun score actif sous la limite disponible.',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.danger,
                          ),
                        )
                      else
                        Text(
                          'Copie le score le plus élevé des autres joueurs actifs : $targetScore points.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                // Definitive elimination option
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF4F4),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.danger.withValues(alpha: 0.25),
                    ),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_off_rounded,
                            size: 16,
                            color: AppColors.danger,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Option 2 : Élimination définitive',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Le joueur quitte définitivement la partie. Les autres continuent.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.danger,
                      backgroundColor: Colors.white,
                      side: BorderSide(
                        color: AppColors.danger.withValues(alpha: 0.4),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: onDefinitiveElimination,
                    child: const Text(
                      'Élimination',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canRevanche
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                      foregroundColor: canRevanche
                          ? Colors.white
                          : AppColors.textMuted,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: canRevanche ? onRevanche : null,
                    child: const Text(
                      'Revanche',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
