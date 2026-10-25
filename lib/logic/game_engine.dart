import 'dart:math' as math;
import '../models/game.dart';
import '../models/game_state_snapshot.dart';
import '../models/player.dart';
import '../models/round.dart';

/// Preview result before committing a round.
class RoundPreview {
  final Map<String, int> previousScores;
  final Map<String, int> addedScores;
  final Map<String, int> resultingScores;
  final List<String> newlyEliminatedEligibleIds;

  const RoundPreview({
    required this.previousScores,
    required this.addedScores,
    required this.resultingScores,
    required this.newlyEliminatedEligibleIds,
  });
}

/// Final ranking entry for a player.
class PlayerRanking {
  final int rank;
  final Player player;
  final bool isWinner;
  final String statusDescription;

  const PlayerRanking({
    required this.rank,
    required this.player,
    required this.isWinner,
    required this.statusDescription,
  });
}

/// Pure business logic for Rummy scoring rules, eliminations, revanches, and undo.
class GameEngine {
  GameEngine._();

  /// Creates a new game with validated players and elimination limit.
  static Game createNewGame({
    required List<String> playerNames,
    int eliminationLimit = 151,
  }) {
    if (eliminationLimit <= 0) {
      throw ArgumentError(
        'La limite d\'élimination doit être strictement supérieure à 0.',
      );
    }

    if (playerNames.length < 2 || playerNames.length > 4) {
      throw ArgumentError('Une partie doit comporter entre 2 et 4 joueurs.');
    }

    final trimmedNames = playerNames.map((n) => n.trim()).toList();

    for (int i = 0; i < trimmedNames.length; i++) {
      if (trimmedNames[i].isEmpty) {
        throw ArgumentError('Le nom du joueur ${i + 1} ne peut pas être vide.');
      }
    }

    final lowerNames = trimmedNames.map((n) => n.toLowerCase()).toSet();
    if (lowerNames.length != trimmedNames.length) {
      throw ArgumentError('Tous les joueurs doivent avoir des noms distincts.');
    }

    final players = <Player>[];
    for (int i = 0; i < trimmedNames.length; i++) {
      players.add(
        Player(
          id: 'player_${i + 1}_${DateTime.now().millisecondsSinceEpoch}',
          name: trimmedNames[i],
          cumulativeScore: 0,
          isEliminated: false,
          revancheUsed: false,
        ),
      );
    }

    final gameId = 'game_${DateTime.now().millisecondsSinceEpoch}';

    return Game(
      id: gameId,
      createdAt: DateTime.now(),
      eliminationLimit: eliminationLimit,
      initialPlayerCount: players.length,
      players: players,
      rounds: const [],
      status: GameStatus.inProgress,
      undoSnapshots: const [],
    );
  }

  /// Checks if a new round can be initiated.
  static bool canAddRound(Game game) {
    if (game.status != GameStatus.inProgress) return false;
    if (game.activePlayers.length < 2) return false;
    // Must resolve pending eliminations first
    if (game.hasPendingDecisions) return false;
    return true;
  }

  /// Validates round inputs and generates a preview of resulting scores.
  static RoundPreview previewRound({
    required Game game,
    required String winnerId,
    required Map<String, int> scoresToAdd,
  }) {
    if (game.status != GameStatus.inProgress) {
      throw StateError('La partie est déjà terminée.');
    }

    final activePlayers = game.activePlayers;
    final activeIds = activePlayers.map((p) => p.id).toSet();

    if (!activeIds.contains(winnerId)) {
      throw ArgumentError(
        'Le vainqueur sélectionné doit être un joueur actif.',
      );
    }

    final previousScores = <String, int>{};
    final addedScores = <String, int>{};
    final resultingScores = <String, int>{};
    final newlyEligible = <String>[];

    for (final player in activePlayers) {
      previousScores[player.id] = player.cumulativeScore;

      if (player.id == winnerId) {
        addedScores[player.id] = 0;
      } else {
        final score = scoresToAdd[player.id];
        if (score == null || score < 0) {
          throw ArgumentError(
            'Chaque joueur actif doit avoir un score valide supérieur ou égal à 0.',
          );
        }
        addedScores[player.id] = score;
      }

      final newTotal = previousScores[player.id]! + addedScores[player.id]!;
      resultingScores[player.id] = newTotal;

      if (newTotal >= game.eliminationLimit) {
        newlyEligible.add(player.id);
      }
    }

    return RoundPreview(
      previousScores: previousScores,
      addedScores: addedScores,
      resultingScores: resultingScores,
      newlyEliminatedEligibleIds: newlyEligible,
    );
  }

  /// Commits a round to the game, creating a safety snapshot before modifying scores.
  static Game commitRound({
    required Game game,
    required String winnerId,
    required Map<String, int> scoresToAdd,
  }) {
    final preview = previewRound(
      game: game,
      winnerId: winnerId,
      scoresToAdd: scoresToAdd,
    );

    // Create safety snapshot for undo
    final snapshot = game.createSnapshot();
    final updatedSnapshots = [...game.undoSnapshots, snapshot];

    final updatedPlayers = game.players.map((player) {
      if (!player.isActive) return player;

      final added = preview.addedScores[player.id] ?? 0;
      final newTotal = player.cumulativeScore + added;

      return player.copyWith(cumulativeScore: newTotal);
    }).toList();

    final roundNumber = game.rounds.length + 1;
    final newRound = Round(
      roundNumber: roundNumber,
      winnerId: winnerId,
      scoresAdded: Map<String, int>.from(preview.addedScores),
      cumulativeScoresAfter: Map<String, int>.from(preview.resultingScores),
      timestamp: DateTime.now(),
    );

    return game.copyWith(
      players: updatedPlayers,
      rounds: [...game.rounds, newRound],
      undoSnapshots: updatedSnapshots,
    );
  }

  /// Returns the target score a player would copy if they chose Revanche.
  /// Rule 4: "Find the highest current cumulative score among the OTHER players who are still active."
  /// Must be strictly below the elimination limit to prevent immediate re-elimination.
  static int? getRevancheTargetScore(Game game, String playerId) {
    final otherCandidates = game.activePlayers.where((p) {
      return p.id != playerId && p.cumulativeScore < game.eliminationLimit;
    }).toList();

    if (otherCandidates.isEmpty) {
      return null;
    }

    return otherCandidates.map((p) => p.cumulativeScore).reduce(math.max);
  }

  /// Determines if an active player is eligible to take Revanche.
  /// Revanche is allowed ONLY when both conditions are satisfied:
  /// 1. The game was originally created with exactly 4 players.
  /// 2. There are at least 3 active players, INCLUDING the player who triggered the elimination decision.
  static bool canTakeRevanche(Game game, String playerId) {
    // Condition 1: Must have been originally created with exactly 4 players
    if (game.initialPlayerCount != 4) {
      return false;
    }

    // Condition 2: At least 3 active players, including the affected player
    if (game.activePlayers.length < 3) {
      return false;
    }

    final player = game.players.where((p) => p.id == playerId).firstOrNull;
    if (player == null) return false;
    if (player.isEliminated) return false;
    if (player.revancheUsed) return false;
    if (player.cumulativeScore < game.eliminationLimit) return false;

    return getRevancheTargetScore(game, playerId) != null;
  }

  /// Applies Revanche to an eligible player.
  /// Replaces their score with the highest score of another active player,
  /// marks Revanche as used, and keeps all other scores unchanged.
  static Game applyRevanche(Game game, String playerId) {
    if (!canTakeRevanche(game, playerId)) {
      throw StateError(
        'Ce joueur ne peut pas utiliser la revanche (conditions non remplies, déjà utilisée ou aucune cible valide).',
      );
    }

    final targetScore = getRevancheTargetScore(game, playerId)!;

    final updatedPlayers = game.players.map((player) {
      if (player.id == playerId) {
        return player.copyWith(
          cumulativeScore: targetScore,
          revancheUsed: true,
          revancheAtRound: game.rounds.length,
          revancheScoreTaken: targetScore,
        );
      }
      return player;
    }).toList();

    // Annotate last round with revanche event
    List<Round> updatedRounds = game.rounds;
    if (game.rounds.isNotEmpty) {
      final lastRound = game.rounds.last;
      final updatedRevancheEvents = Map<String, int>.from(
        lastRound.revancheEvents,
      );
      updatedRevancheEvents[playerId] = targetScore;
      final modifiedLastRound = lastRound.copyWith(
        revancheEvents: updatedRevancheEvents,
      );
      updatedRounds = [
        ...game.rounds.sublist(0, game.rounds.length - 1),
        modifiedLastRound,
      ];
    }

    return game.copyWith(players: updatedPlayers, rounds: updatedRounds);
  }

  /// Applies definitive elimination to a player who reached or exceeded the limit.
  static Game applyDefinitiveElimination(Game game, String playerId) {
    final player = game.players.where((p) => p.id == playerId).firstOrNull;
    if (player == null) {
      throw ArgumentError('Joueur introuvable.');
    }
    if (player.isEliminated) {
      return game; // Already eliminated
    }

    final currentRoundNum = game.rounds.length;

    final updatedPlayers = game.players.map((p) {
      if (p.id == playerId) {
        return p.copyWith(
          isEliminated: true,
          eliminatedAtRound: currentRoundNum,
        );
      }
      return p;
    }).toList();

    // Annotate last round with elimination event
    List<Round> updatedRounds = game.rounds;
    if (game.rounds.isNotEmpty) {
      final lastRound = game.rounds.last;
      final updatedEliminations = List<String>.from(
        lastRound.eliminationEvents,
      );
      if (!updatedEliminations.contains(playerId)) {
        updatedEliminations.add(playerId);
      }
      final modifiedLastRound = lastRound.copyWith(
        eliminationEvents: updatedEliminations,
      );
      updatedRounds = [
        ...game.rounds.sublist(0, game.rounds.length - 1),
        modifiedLastRound,
      ];
    }

    var updatedGame = game.copyWith(
      players: updatedPlayers,
      rounds: updatedRounds,
    );

    // Rule 5: When only one active player remains, finish the game
    final remainingActive = updatedGame.activePlayers;
    if (remainingActive.length == 1) {
      final winner = remainingActive.first;
      updatedGame = updatedGame.copyWith(
        status: GameStatus.completed,
        winnerId: winner.id,
        completedAt: DateTime.now(),
      );
    }

    return updatedGame;
  }

  /// Checks if undo is possible.
  static bool canUndo(Game game) {
    return game.undoSnapshots.isNotEmpty;
  }

  /// Restores game state to immediately before the last committed round.
  static Game undoLastRound(Game game) {
    if (!canUndo(game)) {
      throw StateError('Aucune manche à annuler.');
    }

    final lastSnapshot = game.undoSnapshots.last;
    final remainingSnapshots = game.undoSnapshots.sublist(
      0,
      game.undoSnapshots.length - 1,
    );

    return game.copyWith(
      players: lastSnapshot.players.map((p) => p.copyWith()).toList(),
      rounds: lastSnapshot.rounds.map((r) => r.copyWith()).toList(),
      status: lastSnapshot.status,
      winnerId: lastSnapshot.winnerId,
      completedAt: lastSnapshot.completedAt,
      undoSnapshots: remainingSnapshots,
    );
  }

  /// Calculates rankings for display on scoreboard or game-over screen.
  static List<PlayerRanking> calculateRankings(Game game) {
    final List<PlayerRanking> rankings = [];

    if (game.isCompleted && game.winner != null) {
      // Winner is rank 1
      rankings.add(
        PlayerRanking(
          rank: 1,
          player: game.winner!,
          isWinner: true,
          statusDescription: 'Vainqueur 👑',
        ),
      );

      // Eliminated players ranked by rounds survived (descending), then score (ascending)
      final others = game.players.where((p) => p.id != game.winner!.id).toList()
        ..sort((a, b) {
          final roundA = a.eliminatedAtRound ?? 0;
          final roundB = b.eliminatedAtRound ?? 0;
          if (roundB != roundA) return roundB.compareTo(roundA);
          return a.cumulativeScore.compareTo(b.cumulativeScore);
        });

      for (int i = 0; i < others.length; i++) {
        final p = others[i];
        final roundInfo = p.eliminatedAtRound != null
            ? 'Éliminé(e) manche ${p.eliminatedAtRound}'
            : 'Éliminé(e)';
        rankings.add(
          PlayerRanking(
            rank: i + 2,
            player: p,
            isWinner: false,
            statusDescription: roundInfo,
          ),
        );
      }
    } else {
      // In-progress: Rank active players first (lowest score = rank 1), then eliminated
      final active = List<Player>.from(game.activePlayers)
        ..sort((a, b) => a.cumulativeScore.compareTo(b.cumulativeScore));
      final eliminated = List<Player>.from(game.eliminatedPlayers)
        ..sort((a, b) => a.cumulativeScore.compareTo(b.cumulativeScore));

      int currentRank = 1;
      for (final p in active) {
        rankings.add(
          PlayerRanking(
            rank: currentRank++,
            player: p,
            isWinner: false,
            statusDescription: 'En jeu',
          ),
        );
      }
      for (final p in eliminated) {
        rankings.add(
          PlayerRanking(
            rank: currentRank++,
            player: p,
            isWinner: false,
            statusDescription: p.eliminatedAtRound != null
                ? 'Éliminé(e) manche ${p.eliminatedAtRound}'
                : 'Éliminé(e)',
          ),
        );
      }
    }

    return rankings;
  }
}
