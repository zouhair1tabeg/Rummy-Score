import 'dart:ui';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../logic/game_engine.dart';
import '../models/game.dart';
import '../state/game_notifier.dart';
import '../widgets/elimination_dialog.dart';
import '../widgets/glass_background.dart';
import '../widgets/player_score_card.dart';
import '../widgets/round_history_view.dart';
import '../widgets/undo_dialog.dart';
import 'add_round_screen.dart';
import 'game_over_screen.dart';
import 'rules_screen.dart';

class ScoreboardScreen extends StatefulWidget {
  final GameNotifier notifier;

  const ScoreboardScreen({super.key, required this.notifier});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  bool _isHandlingElimination = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkPendingDecisions();
    });
  }

  void _checkPendingDecisions() {
    final game = widget.notifier.activeGame;
    if (game == null) return;

    if (game.isCompleted) {
      _navigateToGameOver(game);
      return;
    }

    if (game.hasPendingDecisions && !_isHandlingElimination) {
      _showNextEliminationDialog(game);
    }
  }

  void _navigateToGameOver(Game game) {
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => GameOverScreen(game: game, notifier: widget.notifier),
      ),
    );
  }

  Future<void> _showNextEliminationDialog(Game game) async {
    final pending = game.pendingEliminationPlayers;
    if (pending.isEmpty) {
      _isHandlingElimination = false;
      if (game.isCompleted) {
        _navigateToGameOver(game);
      }
      return;
    }

    _isHandlingElimination = true;
    final candidate = pending.first;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return EliminationDialog(
          game: game,
          player: candidate,
          onDefinitiveElimination: () async {
            Navigator.of(dialogContext).pop();
            await widget.notifier.applyDefinitiveElimination(candidate.id);
            _isHandlingElimination = false;
            if (mounted) {
              _checkPendingDecisions();
            }
          },
          onRevanche: () async {
            Navigator.of(dialogContext).pop();
            await widget.notifier.applyRevanche(candidate.id);
            _isHandlingElimination = false;
            if (mounted) {
              _checkPendingDecisions();
            }
          },
        );
      },
    );
  }

  void _confirmUndo() {
    final game = widget.notifier.activeGame;
    if (game == null || game.rounds.isEmpty || game.undoSnapshots.isEmpty) {
      return;
    }

    final roundToUndo = game.rounds.last;
    showDialog(
      context: context,
      builder: (_) => UndoDialog(
        roundToUndo: roundToUndo,
        onConfirm: () async {
          await widget.notifier.undoLastRound();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Manche ${roundToUndo.roundNumber} annulée avec succès.',
                ),
              ),
            );
          }
        },
      ),
    );
  }

  void _openAddRoundScreen(Game game) {
    if (game.hasPendingDecisions) {
      _showNextEliminationDialog(game);
      return;
    }

    Navigator.of(context)
        .push(
          MaterialPageRoute(
            builder: (_) => AddRoundScreen(
              game: game,
              onCommitRound:
                  ({
                    required String winnerId,
                    required Map<String, int> scoresToAdd,
                  }) async {
                    await widget.notifier.commitRound(
                      winnerId: winnerId,
                      scoresToAdd: scoresToAdd,
                    );
                  },
            ),
          ),
        )
        .then((_) {
          _checkPendingDecisions();
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.notifier,
      builder: (context, _) {
        final game = widget.notifier.activeGame;

        if (game == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Tableau des scores')),
            body: const Center(
              child: Text(
                'Aucune partie sélectionnée.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          );
        }

        final rankings = GameEngine.calculateRankings(game);
        final canAdd = GameEngine.canAddRound(game);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tableau des scores'),
            actions: [
              IconButton(
                icon: const Icon(Icons.menu_book_outlined),
                tooltip: 'Règles du jeu',
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const RulesScreen()),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                color: Colors.white.withValues(alpha: 0.95),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: const BorderSide(
                    color: AppColors.glassBorderSubtle,
                    width: 0.8,
                  ),
                ),
                onSelected: (value) {
                  if (value == 'undo') {
                    _confirmUndo();
                  } else if (value == 'rules') {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const RulesScreen()),
                    );
                  } else if (value == 'leave') {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'undo',
                    enabled: game.undoSnapshots.isNotEmpty,
                    child: const Row(
                      children: [
                        Icon(
                          Icons.undo_rounded,
                          color: AppColors.warning,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Annuler la dernière manche'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'rules',
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          color: AppColors.primary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Règles du jeu'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'leave',
                    child: Row(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          color: AppColors.textSecondary,
                          size: 18,
                        ),
                        SizedBox(width: 8),
                        Text('Quitter vers l\'accueil'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: GlassBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header Status Banner
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFF25283B,
                            ).withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.flag_rounded,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Limite: ${game.eliminationLimit} pts',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F3F8),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${game.rounds.length} manche${game.rounds.length > 1 ? 's' : ''}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Pending elimination warning
                    if (game.hasPendingDecisions) ...[
                      InkWell(
                        onTap: () => _showNextEliminationDialog(game),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF4F4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: AppColors.danger.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.warning_amber_rounded,
                                color: AppColors.danger,
                                size: 22,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${game.pendingEliminationPlayers.length} joueur(s) ont atteint la limite ! Cliquez pour trancher.',
                                  style: const TextStyle(
                                    color: AppColors.danger,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              const Icon(
                                Icons.chevron_right_rounded,
                                color: AppColors.danger,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                    ],

                    // Player Score Cards Grid
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth > 550
                            ? 3
                            : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                                mainAxisExtent: 140,
                              ),
                          itemCount: rankings.length,
                          itemBuilder: (context, index) {
                            final item = rankings[index];
                            return PlayerScoreCard(
                              player: item.player,
                              eliminationLimit: game.eliminationLimit,
                              rank: item.rank,
                              isWinner: item.isWinner,
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 18),

                    // Round History
                    RoundHistoryView(game: game, onUndoLastRound: _confirmUndo),

                    const SizedBox(height: 85),
                  ],
                ),
              ),
            ),
          ),
          bottomSheet: ClipRRect(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                color: Colors.white.withValues(alpha: 0.88),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: SafeArea(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: canAdd
                          ? AppColors.primary
                          : const Color(0xFFE5E7EB),
                      foregroundColor: canAdd
                          ? Colors.white
                          : AppColors.textMuted,
                      minimumSize: const Size.fromHeight(52),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: canAdd ? () => _openAddRoundScreen(game) : null,
                    icon: const Icon(Icons.add_circle_outline, size: 20),
                    label: Text(
                      game.hasPendingDecisions
                          ? 'Régler l\'élimination avant d\'ajouter'
                          : (game.isCompleted
                                ? 'Partie terminée'
                                : 'Ajouter une manche'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
