import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/glass_background.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Règles du jeu de Rami')),
      body: GlassBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildIntroCard(),
                const SizedBox(height: 16),
                _buildRuleSection(
                  number: '1',
                  title: 'Limite d\'élimination',
                  icon: Icons.flag_rounded,
                  accentColor: AppColors.primary,
                  content:
                      'La limite par défaut est fixée à 151 points (personnalisable). '
                      'Un joueur est éliminé dès que son score cumulé atteint ou dépasse cette limite. '
                      'Atteindre la limite ne signifie pas gagner : cela signifie être éliminé !',
                ),
                const SizedBox(height: 12),
                _buildRuleSection(
                  number: '2',
                  title: 'Décompte des manches',
                  icon: Icons.sports_score_rounded,
                  accentColor: AppColors.success,
                  content:
                      'À chaque manche, un vainqueur est désigné. '
                      'Le vainqueur reçoit 0 point supplémentaire. '
                      'Tous les autres joueurs actifs reçoivent les points de leurs cartes restantes en main. '
                      'Le score cumulé ne se réinitialise jamais entre les manches.',
                ),
                const SizedBox(height: 12),
                _buildRuleSection(
                  number: '3',
                  title: 'Gestion de l\'élimination',
                  icon: Icons.person_off_rounded,
                  accentColor: AppColors.danger,
                  content:
                      'Lorsqu\'un joueur atteint ou dépasse la limite, il est éligible à l\'élimination. '
                      'Deux choix lui sont alors proposés :\n'
                      '• Élimination définitive : le joueur quitte définitivement la partie.\n'
                      '• Revanche : le joueur tente de rester dans la partie selon la règle ci-dessous.',
                ),
                const SizedBox(height: 12),
                _buildRuleSection(
                  number: '4',
                  title: 'La Revanche (Règle clé)',
                  icon: Icons.shield_rounded,
                  accentColor: AppColors.secondary,
                  highlight: true,
                  content:
                      'Conditions obligatoires :\n'
                      '• La partie doit avoir été créée avec exactement 4 joueurs.\n'
                      '• Il doit rester au moins 3 joueurs actifs au moment de l\'élimination (joueur concerné inclus).\n'
                      '• Chaque joueur ne peut utiliser la Revanche qu\'une seule fois par partie.\n\n'
                      'Quand un joueur choisit la Revanche :\n'
                      '1. L\'application recherche le score cumulé le plus élevé parmi les AUTRES joueurs encore actifs.\n'
                      '2. Le score du joueur est remplacé par ce score le plus élevé.\n'
                      '3. Les scores de tous les autres joueurs restent inchangés.\n'
                      '4. La Revanche est marquée comme consommée pour ce joueur.\n'
                      '5. Le joueur redevient actif avec la même limite d\'élimination.\n\n'
                      'Exemple : Avec une limite à 151 pts, si les scores sont User 1 (36), User 2 (67), User 3 (80) et User 4 (151). '
                      'User 4 prend sa Revanche : son score devient 80 (le plus haut score des autres joueurs actifs).',
                ),
                const SizedBox(height: 12),
                _buildRuleSection(
                  number: '5',
                  title: 'Fin de la partie',
                  icon: Icons.emoji_events_rounded,
                  accentColor: AppColors.primary,
                  content:
                      'La partie se termine dès qu\'il ne reste plus qu\'un seul joueur actif en lice. '
                      'Ce dernier joueur restant est déclaré Vainqueur de la partie !',
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25283B).withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.auto_stories_rounded,
              color: AppColors.primary,
              size: 26,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Feuille de marque électronique',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Application conçue pour enregistrer fidèlement et sans erreur les scores lors de vos parties.',
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
    required Color accentColor,
    required String content,
    bool highlight = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: highlight
            ? const Color(0xFFF7F6FE)
            : Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: highlight
              ? AppColors.secondary.withValues(alpha: 0.5)
              : Colors.white,
          width: highlight ? 1.4 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF25283B).withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: accentColor.withValues(alpha: 0.15),
                child: Text(
                  number,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: accentColor,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(icon, size: 17, color: accentColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
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
