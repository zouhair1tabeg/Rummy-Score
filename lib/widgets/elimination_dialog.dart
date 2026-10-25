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
      canPop: false, // Must make an explicit decision
      child: AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.border, width: 1.5),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.dangerSurface,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.danger,
                size: 28,
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
              // Player name & score overview
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.goldLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                        children: [
                          const TextSpan(text: 'Score cumulé : '),
                          TextSpan(
                            text: '${player.cumulativeScore} points',
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
              const SizedBox(height: 16),
              const Text(
                'Ce joueur a atteint ou dépassé la limite d\'élimination. Choisissez son issue :',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),

              // Revanche Option Card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: canRevanche
                      ? AppColors.surface
                      : AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: canRevanche ? AppColors.gold : AppColors.border,
                    width: canRevanche ? 1.4 : 1.0,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.shield,
                          size: 18,
                          color: canRevanche
                              ? AppColors.gold
                              : AppColors.textMuted,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Option 1 : La Revanche',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: canRevanche
                                ? AppColors.goldLight
                                : AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (player.revancheUsed)
                      const Text(
                        '❌ Revanche déjà utilisée lors d\'une manche précédente. Chaque joueur ne peut l\'utiliser qu\'une seule fois par partie.',
                        style: TextStyle(fontSize: 12, color: AppColors.danger),
                      )
                    else if (targetScore == null)
                      const Text(
                        '❌ Aucun joueur actif avec un score valide en dessous de la limite n\'est disponible.',
                        style: TextStyle(fontSize: 12, color: AppColors.danger),
                      )
                    else
                      Text(
                        'Copie le score le plus élevé parmi les autres joueurs actifs. Nouveau score : $targetScore points.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Definitive elimination card
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person_off_rounded,
                          size: 18,
                          color: AppColors.danger,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Option 2 : Élimination définitive',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.danger,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Le joueur quitte définitivement la partie. Les autres joueurs poursuivent la compétition.',
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
                    side: const BorderSide(color: AppColors.danger),
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
                        ? AppColors.gold
                        : AppColors.surfaceLight,
                    foregroundColor: canRevanche
                        ? AppColors.background
                        : AppColors.textMuted,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: canRevanche ? onRevanche : null,
                  child: const Text(
                    'Revanche',
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
