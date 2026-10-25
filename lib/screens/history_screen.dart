import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../models/game.dart';
import '../state/game_notifier.dart';
import '../utils/date_formatter.dart';
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
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surfaceElevated,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Row(
          children: [
            Icon(Icons.delete_outline, color: AppColors.danger, size: 24),
            SizedBox(width: 8),
            Text('Supprimer la partie'),
          ],
        ),
        content: Text(
          'Voulez-vous supprimer définitivement cette partie (${game.players.length} joueurs, ${game.rounds.length} manches) ? Cette action est irréversible.',
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
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
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppColors.gold,
              labelColor: AppColors.goldLight,
              unselectedLabelColor: AppColors.textMuted,
              tabs: [
                Tab(text: 'Toutes (${allGames.length})'),
                Tab(text: 'En cours (${inProgress.length})'),
                Tab(text: 'Terminées (${completed.length})'),
              ],
            ),
          ),
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildGamesList(allGames),
              _buildGamesList(inProgress),
              _buildGamesList(completed),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: AppColors.gold,
            foregroundColor: AppColors.background,
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => NewGameScreen(notifier: widget.notifier),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text(
              'Nouvelle partie',
              style: TextStyle(fontWeight: FontWeight.w800),
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
                size: 54,
                color: AppColors.textMuted,
              ),
              SizedBox(height: 12),
              Text(
                'Aucune partie trouvée',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textSecondary,
                ),
              ),
              SizedBox(height: 6),
              Text(
                'Vos parties s\'afficheront ici automatiquement.',
                style: TextStyle(fontSize: 13, color: AppColors.textMuted),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
      itemCount: games.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final game = games[index];
        final dateStr = AppDateFormatter.formatGameDate(game.createdAt);

        return Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: game.isCompleted
                  ? AppColors.border
                  : AppColors.emeraldAccent.withValues(alpha: 0.5),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _openGame(game),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Top row: Status & date & delete button
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
                                    ? AppColors.primary
                                    : AppColors.successSurface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                game.isCompleted ? 'Terminée' : 'En cours',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: game.isCompleted
                                      ? AppColors.goldLight
                                      : AppColors.emeraldAccent,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              dateStr,
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            size: 20,
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

                    // Winner or round status
                    if (game.isCompleted && game.winner != null)
                      Row(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            size: 16,
                            color: AppColors.gold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Gagné par ${game.winner!.name} (${game.winner!.cumulativeScore} pts)',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.goldLight,
                            ),
                          ),
                        ],
                      )
                    else
                      Text(
                        '${game.rounds.length} manche(s) jouée(s) • Limite : ${game.eliminationLimit} pts',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    const SizedBox(height: 8),

                    // Players & scores overview
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
                            color: AppColors.surfaceElevated,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: p.isEliminated
                                  ? AppColors.danger.withValues(alpha: 0.5)
                                  : AppColors.border,
                            ),
                          ),
                          child: Text(
                            '${p.name}: ${p.cumulativeScore}',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: p.isEliminated
                                  ? AppColors.textMuted
                                  : AppColors.textSecondary,
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
