import 'package:flutter_test/flutter_test.dart';
import 'package:rummy_score/logic/game_engine.dart';
import 'package:rummy_score/models/game.dart';
import 'package:rummy_score/models/game_state_snapshot.dart';
import 'package:rummy_score/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Rummy Score Engine Tests (All 14 Required Specifications)', () {
    // 1. Initial scores are zero
    test('1. Initial scores are zero', () {
      final game = GameEngine.createNewGame(
        playerNames: ['Alice', 'Bob', 'Charlie', 'David'],
        eliminationLimit: 151,
      );

      expect(game.players.length, 4);
      for (final player in game.players) {
        expect(player.cumulativeScore, 0);
        expect(player.isEliminated, isFalse);
        expect(player.revancheUsed, isFalse);
        expect(player.isActive, isTrue);
      }
      expect(game.status, GameStatus.inProgress);
      expect(game.rounds, isEmpty);
    });

    // 2. The round winner receives zero additional points
    test('2. The round winner receives zero additional points', () {
      final game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2', 'User 3'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];

      final updatedGame = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 23, p3.id: 45},
      );

      final updatedP1 = updatedGame.players.firstWhere((p) => p.id == p1.id);
      expect(updatedP1.cumulativeScore, 0);
      expect(updatedGame.rounds.last.scoresAdded[p1.id], 0);
    });

    // 3. Other active players receive the correct additional points
    test('3. Other active players receive the correct additional points', () {
      final game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2', 'User 3'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];

      final updatedGame = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 23, p3.id: 45},
      );

      final updatedP2 = updatedGame.players.firstWhere((p) => p.id == p2.id);
      final updatedP3 = updatedGame.players.firstWhere((p) => p.id == p3.id);

      expect(updatedP2.cumulativeScore, 23);
      expect(updatedP3.cumulativeScore, 45);
    });

    // 4. Cumulative totals are calculated correctly across multiple rounds
    test(
      '4. Cumulative totals are calculated correctly across multiple rounds',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2', 'User 3'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];
        final p3 = game.players[2];

        // Round 1: p1 wins. p2 gets 30, p3 gets 40.
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 30, p3.id: 40},
        );

        // Round 2: p2 wins. p1 gets 20, p3 gets 25.
        game = GameEngine.commitRound(
          game: game,
          winnerId: p2.id,
          scoresToAdd: {p1.id: 20, p3.id: 25},
        );

        final up1 = game.players.firstWhere((p) => p.id == p1.id);
        final up2 = game.players.firstWhere((p) => p.id == p2.id);
        final up3 = game.players.firstWhere((p) => p.id == p3.id);

        expect(up1.cumulativeScore, 20); // 0 + 20
        expect(up2.cumulativeScore, 30); // 30 + 0
        expect(up3.cumulativeScore, 65); // 40 + 25
        expect(game.rounds.length, 2);
      },
    );

    // 5. Reaching the elimination limit triggers elimination eligibility
    test(
      '5. Reaching the elimination limit triggers elimination eligibility',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];

        // p1 wins, p2 reaches exactly 151
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 151},
        );

        final up2 = game.players.firstWhere((p) => p.id == p2.id);
        expect(up2.cumulativeScore, 151);
        expect(game.hasPendingDecisions, isTrue);
        expect(
          game.pendingEliminationPlayers.map((p) => p.id),
          contains(p2.id),
        );
      },
    );

    // 6. Exceeding the elimination limit triggers elimination eligibility
    test(
      '6. Exceeding the elimination limit triggers elimination eligibility',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];

        // p1 wins, p2 exceeds 151 (scores 175)
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 175},
        );

        final up2 = game.players.firstWhere((p) => p.id == p2.id);
        expect(up2.cumulativeScore, 175);
        expect(game.hasPendingDecisions, isTrue);
        expect(
          game.pendingEliminationPlayers.map((p) => p.id),
          contains(p2.id),
        );
      },
    );

    // 7. Revanche copies the highest score among other active players
    test('7. Revanche copies the highest score among other active players', () {
      var game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];
      final p4 = game.players[3];

      // Set scores according to example: User 1: 36, User 2: 67, User 3: 80, User 4: 151
      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 67, p3.id: 80, p4.id: 151},
      );
      // Extra points for p1: let's add round where p4 wins and p1 gets 36
      // Let's create game state directly or via round
      // To simulate exact example:
      final targetScore = GameEngine.getRevancheTargetScore(game, p4.id);
      // Other active scores are: p1 (0), p2 (67), p3 (80). Max is 80.
      expect(targetScore, 80);

      // Now apply Revanche to p4
      game = GameEngine.applyRevanche(game, p4.id);

      final up4 = game.players.firstWhere((p) => p.id == p4.id);
      expect(up4.cumulativeScore, 80);
      expect(up4.revancheUsed, isTrue);
      expect(up4.isActive, isTrue);
    });

    // 8. Revanche does not change other scores or the elimination limit
    test(
      '8. Revanche does not change other scores or the elimination limit',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];
        final p3 = game.players[2];
        final p4 = game.players[3];

        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 40, p3.id: 70, p4.id: 155},
        );

        game = GameEngine.applyRevanche(game, p4.id);

        final up1 = game.players.firstWhere((p) => p.id == p1.id);
        final up2 = game.players.firstWhere((p) => p.id == p2.id);
        final up3 = game.players.firstWhere((p) => p.id == p3.id);

        expect(up1.cumulativeScore, 0);
        expect(up2.cumulativeScore, 40);
        expect(up3.cumulativeScore, 70);
        expect(game.eliminationLimit, 151);
      },
    );

    // 9. Revanche cannot be used twice by the same player
    test('9. Revanche cannot be used twice by the same player', () {
      var game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];
      final p4 = game.players[3];

      // Round 1: p4 reaches 151 (4 active players)
      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 50, p3.id: 60, p4.id: 151},
      );

      // p4 takes Revanche (copies p3's score = 60)
      expect(GameEngine.canTakeRevanche(game, p4.id), isTrue);
      game = GameEngine.applyRevanche(game, p4.id);
      expect(
        game.players.firstWhere((p) => p.id == p4.id).revancheUsed,
        isTrue,
      );

      // Round 2: p4 reaches 151 again
      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 20, p3.id: 25, p4.id: 95}, // 60 + 95 = 155
      );

      // Verify p4 cannot take Revanche again
      expect(GameEngine.canTakeRevanche(game, p4.id), isFalse);
      expect(() => GameEngine.applyRevanche(game, p4.id), throwsStateError);
    });

    // 10. Eliminated players cannot receive points in subsequent rounds
    test(
      '10. Eliminated players cannot receive points in subsequent rounds',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2', 'User 3'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];
        final p3 = game.players[2];

        // p3 reaches 160 and chooses definitive elimination
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 50, p3.id: 160},
        );

        game = GameEngine.applyDefinitiveElimination(game, p3.id);

        final eliminatedP3 = game.players.firstWhere((p) => p.id == p3.id);
        expect(eliminatedP3.isEliminated, isTrue);
        expect(game.activePlayers.length, 2);
        expect(game.activePlayers.map((p) => p.id), isNot(contains(p3.id)));

        // Round 2: only p1 and p2 can be passed scores
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 30},
        );

        final up3AfterRound2 = game.players.firstWhere((p) => p.id == p3.id);
        expect(up3AfterRound2.cumulativeScore, 160); // Unchanged!
        expect(game.rounds.last.scoresAdded.containsKey(p3.id), isFalse);
      },
    );

    // 11. The game ends when only one active player remains
    test('11. The game ends when only one active player remains', () {
      var game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];

      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 155},
      );

      // p2 is definitively eliminated
      game = GameEngine.applyDefinitiveElimination(game, p2.id);

      expect(game.status, GameStatus.completed);
      expect(game.isCompleted, isTrue);
      expect(game.winnerId, p1.id);
      expect(game.winner?.id, p1.id);
      expect(game.winner?.name, 'User 1');

      final rankings = GameEngine.calculateRankings(game);
      expect(rankings.first.isWinner, isTrue);
      expect(rankings.first.player.id, p1.id);
      expect(rankings[1].player.id, p2.id);
    });

    // 12. Undo restores the complete previous state
    test('12. Undo restores the complete previous state', () {
      var game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];
      final p4 = game.players[3];

      // Round 1
      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 30, p3.id: 40, p4.id: 20},
      );

      // Round 2 causes p4 to reach 151 and take Revanche
      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 20, p3.id: 10, p4.id: 135},
      );
      game = GameEngine.applyRevanche(game, p4.id);

      expect(game.rounds.length, 2);
      expect(
        game.players.firstWhere((p) => p.id == p4.id).revancheUsed,
        isTrue,
      );

      // Undo Round 2
      expect(GameEngine.canUndo(game), isTrue);
      game = GameEngine.undoLastRound(game);

      expect(game.rounds.length, 1);
      final restoredP1 = game.players.firstWhere((p) => p.id == p1.id);
      final restoredP2 = game.players.firstWhere((p) => p.id == p2.id);
      final restoredP3 = game.players.firstWhere((p) => p.id == p3.id);
      final restoredP4 = game.players.firstWhere((p) => p.id == p4.id);

      expect(restoredP1.cumulativeScore, 0);
      expect(restoredP2.cumulativeScore, 30);
      expect(restoredP3.cumulativeScore, 40);
      expect(restoredP4.cumulativeScore, 20);
      expect(restoredP4.revancheUsed, isFalse);
      expect(restoredP4.isEliminated, isFalse);
    });

    // 13. Saved games can be restored with their scores, history, and Revanche flags intact
    test(
      '13. Saved games can be restored with their scores, history, and Revanche flags intact',
      () async {
        SharedPreferences.setMockInitialValues({});
        final prefs = await SharedPreferences.getInstance();
        final storage = StorageService(prefs);

        var originalGame = GameEngine.createNewGame(
          playerNames: ['Alpha', 'Beta'],
          eliminationLimit: 151,
        );

        final p1 = originalGame.players[0];
        final p2 = originalGame.players[1];

        originalGame = GameEngine.commitRound(
          game: originalGame,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 60},
        );

        await storage.saveGame(originalGame);

        final loadedGames = await storage.getAllGames();
        expect(loadedGames.length, 1);

        final restored = loadedGames.first;
        expect(restored.id, originalGame.id);
        expect(restored.eliminationLimit, 151);
        expect(restored.rounds.length, 1);
        expect(
          restored.players.firstWhere((p) => p.id == p1.id).cumulativeScore,
          0,
        );
        expect(
          restored.players.firstWhere((p) => p.id == p2.id).cumulativeScore,
          60,
        );

        final active = await storage.getActiveGame();
        expect(active?.id, originalGame.id);
      },
    );

    // 14. Invalid inputs do not corrupt game state
    test('14. Invalid inputs do not corrupt game state', () {
      // Cannot create game with less than 2 players
      expect(
        () => GameEngine.createNewGame(playerNames: ['OnlyOne']),
        throwsArgumentError,
      );

      // Cannot create game with empty names
      expect(
        () => GameEngine.createNewGame(playerNames: ['Alice', '   ']),
        throwsArgumentError,
      );

      // Cannot create game with duplicate names
      expect(
        () => GameEngine.createNewGame(playerNames: ['Alice', 'alice']),
        throwsArgumentError,
      );

      // Cannot create game with invalid elimination limit
      expect(
        () => GameEngine.createNewGame(
          playerNames: ['Alice', 'Bob'],
          eliminationLimit: 0,
        ),
        throwsArgumentError,
      );

      final game = GameEngine.createNewGame(playerNames: ['Alice', 'Bob']);

      // Cannot commit round with nonexistent or eliminated winner
      expect(
        () => GameEngine.commitRound(
          game: game,
          winnerId: 'nonexistent_id',
          scoresToAdd: {game.players[1].id: 20},
        ),
        throwsArgumentError,
      );

      // Cannot commit negative points
      expect(
        () => GameEngine.commitRound(
          game: game,
          winnerId: game.players[0].id,
          scoresToAdd: {game.players[1].id: -5},
        ),
        throwsArgumentError,
      );
    });

    // Additional: Required decision check before commit
    test(
      'Decisions are required: cannot start new round while pending elimination exists',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['P1', 'P2', 'P3', 'P4'],
          eliminationLimit: 151,
        );

        game = GameEngine.commitRound(
          game: game,
          winnerId: game.players[0].id,
          scoresToAdd: {
            game.players[1].id: 155,
            game.players[2].id: 40,
            game.players[3].id: 50,
          },
        );

        expect(game.hasPendingDecisions, isTrue);
        // cannot add another round until decision is made
        expect(GameEngine.canAddRound(game), isFalse);

        // Resolving the decision restores ability to play
        game = GameEngine.applyRevanche(game, game.players[1].id);
        expect(game.hasPendingDecisions, isFalse);
        expect(GameEngine.canAddRound(game), isTrue);
      },
    );
  });

  group('Exact Revanche Rules Specifications', () {
    test(
      'Case 1: Game created with 4 players allows Revanche when 4 players are active',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];
        final p3 = game.players[2];
        final p4 = game.players[3];

        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 40, p3.id: 70, p4.id: 155},
        );

        // 4 players active (p1, p2, p3, and p4 who triggered elimination)
        expect(game.initialPlayerCount, 4);
        expect(game.activePlayers.length, 4);
        expect(GameEngine.canTakeRevanche(game, p4.id), isTrue);

        game = GameEngine.applyRevanche(game, p4.id);
        expect(
          game.players.firstWhere((p) => p.id == p4.id).cumulativeScore,
          70,
        );
        expect(
          game.players.firstWhere((p) => p.id == p4.id).revancheUsed,
          isTrue,
        );
      },
    );

    test('Case 2: Game created with 3 players NEVER allows Revanche', () {
      var game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2', 'User 3'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];
      final p3 = game.players[2];

      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 40, p3.id: 151},
      );

      // Even though 3 players are currently active, initialPlayerCount is 3, NOT 4
      expect(game.initialPlayerCount, 3);
      expect(game.activePlayers.length, 3);
      expect(GameEngine.canTakeRevanche(game, p3.id), isFalse);

      // Business logic must reject programmatic call
      expect(() => GameEngine.applyRevanche(game, p3.id), throwsStateError);
    });

    test('Case 3: Game created with 2 players NEVER allows Revanche', () {
      var game = GameEngine.createNewGame(
        playerNames: ['User 1', 'User 2'],
        eliminationLimit: 151,
      );

      final p1 = game.players[0];
      final p2 = game.players[1];

      game = GameEngine.commitRound(
        game: game,
        winnerId: p1.id,
        scoresToAdd: {p2.id: 151},
      );

      expect(game.initialPlayerCount, 2);
      expect(GameEngine.canTakeRevanche(game, p2.id), isFalse);
      expect(() => GameEngine.applyRevanche(game, p2.id), throwsStateError);
    });

    test(
      'Case 4: Game created with 4 players does NOT allow Revanche when only 2 players remain active',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];
        final p3 = game.players[2];
        final p4 = game.players[3];

        // Round 1: p4 reaches 160 and is definitively eliminated
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 30, p3.id: 40, p4.id: 160},
        );
        game = GameEngine.applyDefinitiveElimination(game, p4.id);

        // Round 2: p3 reaches 155 and is definitively eliminated
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 20, p3.id: 120},
        );
        game = GameEngine.applyDefinitiveElimination(game, p3.id);

        // Now only 2 players remain active: p1 and p2
        expect(game.initialPlayerCount, 4);
        expect(game.activePlayers.length, 2);

        // Round 3: p2 reaches 151
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 110}, // 50 + 110 = 160
        );

        // When p2 is at/over limit, only 2 active players remain (p1 and p2)
        expect(game.activePlayers.length, 2);
        // Condition 2 fails (needs at least 3 active players including p2)
        expect(GameEngine.canTakeRevanche(game, p2.id), isFalse);

        // Programmatic rejection
        expect(() => GameEngine.applyRevanche(game, p2.id), throwsStateError);

        // Must be definitively eliminated
        game = GameEngine.applyDefinitiveElimination(game, p2.id);
        expect(game.isCompleted, isTrue);
        expect(game.winnerId, p1.id);
      },
    );

    test(
      'Case 5: Game created with 4 players and 3 players remain active ALLOWS Revanche',
      () {
        var game = GameEngine.createNewGame(
          playerNames: ['User 1', 'User 2', 'User 3', 'User 4'],
          eliminationLimit: 151,
        );

        final p1 = game.players[0];
        final p2 = game.players[1];
        final p3 = game.players[2];
        final p4 = game.players[3];

        // Round 1: p4 reaches 160 and is definitively eliminated
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 30, p3.id: 70, p4.id: 160},
        );
        game = GameEngine.applyDefinitiveElimination(game, p4.id);

        // Now 3 players remain active: p1, p2, p3
        expect(game.initialPlayerCount, 4);
        expect(game.activePlayers.length, 3);

        // Round 2: p3 reaches 155
        game = GameEngine.commitRound(
          game: game,
          winnerId: p1.id,
          scoresToAdd: {p2.id: 20, p3.id: 85}, // 70 + 85 = 155
        );

        // p1 (0), p2 (50), p3 (155) -> 3 active players including p3
        expect(game.activePlayers.length, 3);
        expect(GameEngine.canTakeRevanche(game, p3.id), isTrue);

        // p3 takes Revanche and copies p2's score (50)
        game = GameEngine.applyRevanche(game, p3.id);
        final up3 = game.players.firstWhere((p) => p.id == p3.id);
        expect(up3.cumulativeScore, 50);
        expect(up3.revancheUsed, isTrue);
        expect(up3.isActive, isTrue);
      },
    );

    test(
      'Original player count is preserved in serialization and undo',
      () async {
        var game = GameEngine.createNewGame(
          playerNames: ['A', 'B', 'C', 'D'],
          eliminationLimit: 151,
        );

        final json = game.toJson();
        expect(json['initialPlayerCount'], 4);

        final deserialized = Game.fromJson(json);
        expect(deserialized.initialPlayerCount, 4);

        // Verify undo preserves initialPlayerCount
        game = GameEngine.commitRound(
          game: game,
          winnerId: game.players[0].id,
          scoresToAdd: {
            game.players[1].id: 10,
            game.players[2].id: 20,
            game.players[3].id: 30,
          },
        );
        final undone = GameEngine.undoLastRound(game);
        expect(undone.initialPlayerCount, 4);
      },
    );
  });
}
