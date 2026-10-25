import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/game.dart';
import '../state/game_notifier.dart';
import '../utils/date_formatter.dart';
import '../widgets/glass_background.dart';
import 'game_over_screen.dart';
import 'new_game_screen.dart';
import 'scoreboard_screen.dart';

class HistoryScreen extends StatefulWidget {
  final GameNotifier notifier;

  const HistoryScreen({super.key, required this.notifier});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _confirmDeleteGame(Game game) {
    showDialog(
      context: context,
      builder: (_) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: AlertDialog(
          backgroundColor: Colors.white.withValues(alpha: 0.95),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: Colors.white, width: 1.5),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                color: AppColors.danger,
                size: 22,
              ),
              SizedBox(width: 8),
              Text(
                'Supprimer la partie',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          content: Text(
            'Voulez-vous supprimer cette partie (${game.players.length} joueurs, ${game.rounds.length} manches) ?',
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                'Annuler',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                await widget.notifier.deleteGame(game.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Partie supprimée.')),
                  );
                }
              },
              child: const Text('Supprimer'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openGame(Game game) async {
    await widget.notifier.loadGame(game.id);
    if (!mounted) return;

    if (game.isCompleted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GameOverScreen(game: game, notifier: widget.notifier),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ScoreboardScreen(notifier: widget.notifier),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final allGames = widget.notifier.allGames;
        final inProgress = widget.notifier.inProgressGames;
        final completed = widget.notifier.completedGames;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Historique des parties'),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(48),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.textSecondary,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  dividerColor: Colors.transparent,
                  tabs: [
                    Tab(text: 'Toutes (${allGames.length})'),
                    Tab(text: 'En cours (${inProgress.length})'),
                    Tab(text: 'Finies (${completed.length})'),
                  ],
                ),
              ),
            ),
          ),
          body: GlassBackground(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildGamesList(allGames),
                _buildGamesList(inProgress),
                _buildGamesList(completed),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewGameScreen(notifier: widget.notifier),
                ),
              );
            },
            icon: const Icon(Icons.add_rounded),
            label: const Text(
              'Nouvelle partie',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        );
      },
    );
  }

  Widget _buildGamesList(List<Game> games) {
    if (games.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 48,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 12),
              Text(
                'Aucune partie trouvée',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Vos parties s\'afficheront ici automatiquement.',
                style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: games.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final game = games[index];
        final dateStr = AppDateFormatter.formatGameDate(game.createdAt);

        return Container(
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: game.isCompleted
                  ? Colors.white
                  : AppColors.primary.withValues(alpha: 0.3),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF25283B).withValues(alpha: 0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => _openGame(game),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                                color: game.isCompleted
                                    ? const Color(0xFFE8EEFC)
                                    : AppColors.successSurface,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                game.isCompleted ? 'Terminée' : 'En cours',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: game.isCompleted
                                      ? AppColors.primaryDark
                                      : AppColors.success,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline_rounded,
                            size: 19,
                            color: AppColors.textMuted,
                          ),
                          tooltip: 'Supprimer',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () => _confirmDeleteGame(game),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    if (game.isCompleted && game.winner != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gagné par ${game.winner!.name} (${game.winner!.cumulativeScore} pts)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${game.rounds.length} manche(s) • Limite : ${game.eliminationLimit} pts',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    const SizedBox(height: 8),

                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: game.players.map((p) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7F8FB),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: p.isEliminated
                                  ? const Color(0xFFE5E7EB)
                                  : const Color(0xFFE9ECF2),
                            ),
                          ),
                          child: Text(
                            '${p.name}: ${p.cumulativeScore}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.isEliminated
                                  ? AppColors.textMuted
                                  : AppColors.textPrimary,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
