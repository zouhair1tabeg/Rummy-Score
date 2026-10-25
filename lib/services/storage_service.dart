import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/game.dart';

/// Service managing local persistence of games using SharedPreferences.
class StorageService {
  static const String _gamesKey = 'rummy_score_all_games_v1';
  static const String _activeGameIdKey = 'rummy_score_active_game_id_v1';

  final SharedPreferences _prefs;

  StorageService(this._prefs);

  static Future<StorageService> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    return StorageService(prefs);
  }

  /// Loads all stored games, safely handling corrupted entries.
  Future<List<Game>> getAllGames() async {
    try {
      final rawJson = _prefs.getString(_gamesKey);
      if (rawJson == null || rawJson.trim().isEmpty) {
        return [];
      }

      final dynamic decoded = jsonDecode(rawJson);
      if (decoded is! List) {
        debugPrint(
          '[StorageService] Stored games payload is not a List. Resetting.',
        );
        return [];
      }

      final List<Game> games = [];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          try {
            games.add(Game.fromJson(item));
          } catch (e, stack) {
            debugPrint(
              '[StorageService] Failed to parse game entry: $e\n$stack',
            );
            // Safely skip corrupted game entry without breaking other games
          }
        }
      }

      // Sort by creation date descending (newest first)
      games.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return games;
    } catch (e, stack) {
      debugPrint('[StorageService] Error loading all games: $e\n$stack');
      return [];
    }
  }

  /// Saves or updates a game.
  Future<void> saveGame(Game game) async {
    try {
      final games = await getAllGames();
      final index = games.indexWhere((g) => g.id == game.id);

      if (index >= 0) {
        games[index] = game;
      } else {
        games.insert(0, game);
      }

      final encoded = jsonEncode(games.map((g) => g.toJson()).toList());
      await _prefs.setString(_gamesKey, encoded);

      if (!game.isCompleted) {
        await _prefs.setString(_activeGameIdKey, game.id);
      } else {
        // If completed game was active, clear active game pointer
        final currentActiveId = _prefs.getString(_activeGameIdKey);
        if (currentActiveId == game.id) {
          await _prefs.remove(_activeGameIdKey);
        }
      }
    } catch (e, stack) {
      debugPrint('[StorageService] Error saving game: $e\n$stack');
      rethrow;
    }
  }

  /// Gets the currently active unfinished game, if any.
  Future<Game?> getActiveGame() async {
    try {
      final activeId = _prefs.getString(_activeGameIdKey);
      if (activeId == null) {
        // Fallback: look for most recent in-progress game
        final games = await getAllGames();
        return games.where((g) => !g.isCompleted).firstOrNull;
      }

      final games = await getAllGames();
      final game = games.where((g) => g.id == activeId).firstOrNull;
      if (game != null && !game.isCompleted) {
        return game;
      }

      return games.where((g) => !g.isCompleted).firstOrNull;
    } catch (e) {
      debugPrint('[StorageService] Error getting active game: $e');
      return null;
    }
  }

  /// Sets the active game ID.
  Future<void> setActiveGameId(String? gameId) async {
    if (gameId == null) {
      await _prefs.remove(_activeGameIdKey);
    } else {
      await _prefs.setString(_activeGameIdKey, gameId);
    }
  }

  /// Deletes a game permanently.
  Future<void> deleteGame(String gameId) async {
    try {
      final games = await getAllGames();
      games.removeWhere((g) => g.id == gameId);

      final encoded = jsonEncode(games.map((g) => g.toJson()).toList());
      await _prefs.setString(_gamesKey, encoded);

      final currentActiveId = _prefs.getString(_activeGameIdKey);
      if (currentActiveId == gameId) {
        await _prefs.remove(_activeGameIdKey);
      }
    } catch (e, stack) {
      debugPrint('[StorageService] Error deleting game: $e\n$stack');
      rethrow;
    }
  }
}
