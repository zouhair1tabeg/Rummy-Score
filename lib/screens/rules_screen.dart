import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Règles du jeu de Rami')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildIntroCard(),
              const SizedBox(height: 20),
              _buildRuleSection(
                number: '1',
                title: 'Limite d\'élimination',
                icon: Icons.flag_rounded,
                content:
                    'La limite par défaut est fixée à 151 points (personnalisable). '
                    'Un joueur est éliminé dès que son score cumulé atteint ou dépasse cette limite. '
                    'Atteindre la limite ne signifie pas gagner : cela signifie être éliminé !',
              ),
              const SizedBox(height: 14),
              _buildRuleSection(
                number: '2',
                title: 'Décompte des manches',
                icon: Icons.sports_score_rounded,
                content:
                    'À chaque manche, un vainqueur est désigné. '
                    'Le vainqueur reçoit 0 point supplémentaire. '
                    'Tous les autres joueurs actifs reçoivent les points de leurs cartes restantes en main. '
                    'Le score cumulé ne se réinitialise jamais entre les manches.',
              ),
              const SizedBox(height: 14),
              _buildRuleSection(
                number: '3',
                title: 'Gestion de l\'élimination',
                icon: Icons.person_off_rounded,
                content:
                    'Lorsqu\'un joueur atteint ou dépasse la limite, il est éligible à l\'élimination. '
                    'Deux choix lui sont alors proposés :\n'
                    '• Élimination définitive : le joueur quitte définitivement la partie.\n'
                    '• Revanche : le joueur tente de rester dans la partie selon la règle ci-dessous.',
              ),
              const SizedBox(height: 14),
              _buildRuleSection(
                number: '4',
                title: 'La Revanche (Règle clé)',
                icon: Icons.shield_rounded,
                highlight: true,
                content:
                    'Chaque joueur ne peut utiliser la Revanche qu\'une seule fois par partie.\n\n'
                    'Quand un joueur choisit la Revanche :\n'
                    '1. L\'application recherche le score cumulé le plus élevé parmi les AUTRES joueurs encore actifs.\n'
                    '2. Le score du joueur est remplacé par ce score le plus élevé.\n'
                    '3. Les scores de tous les autres joueurs restent inchangés.\n'
                    '4. La Revanche est marquée comme consommée pour ce joueur.\n'
                    '5. Le joueur redevient actif avec la même limite d\'élimination.\n\n'
                    'Exemple : Avec une limite à 151 pts, si les scores sont User 1 (36), User 2 (67), User 3 (80) et User 4 (151). '
                    'User 4 prend sa Revanche : son score devient 80 (le plus haut score des autres joueurs actifs).',
              ),
              const SizedBox(height: 14),
              _buildRuleSection(
                number: '5',
                title: 'Fin de la partie',
                icon: Icons.emoji_events_rounded,
                content:
                    'La partie se termine dès qu\'il ne reste plus qu\'un seul joueur actif en lice. '
                    'Ce dernier joueur restant est déclaré Vainqueur de la partie !',
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold, width: 1.2),
      ),
      child: const Row(
        children: [
          Icon(Icons.auto_stories_rounded, color: AppColors.gold, size: 32),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feuille de marque électronique',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.goldLight,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Application conçue pour enregistrer fidèlement et sans erreur les scores lors de vos soirées Rami.',
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
    );
  }

  Widget _buildRuleSection({
    required String number,
    required String title,
    required IconData icon,
    required String content,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight ? AppColors.surfaceElevated : AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlight ? AppColors.gold : AppColors.border,
          width: highlight ? 1.5 : 1.0,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 13,
                backgroundColor: highlight
                    ? AppColors.gold
                    : AppColors.primaryLight,
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: highlight
                        ? AppColors.background
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                icon,
                size: 18,
                color: highlight ? AppColors.gold : AppColors.emeraldAccent,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: highlight
                        ? AppColors.goldLight
                        : AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }
}
