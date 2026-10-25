import 'package:flutter/foundation.dart';
import '../logic/game_engine.dart';
import '../models/game.dart';
import '../services/storage_service.dart';

/// Central state notifier managing the active game, saved history, and persistence.
class GameNotifier extends ChangeNotifier {
  final StorageService _storageService;

  Game? _activeGame;
  List<Game> _allGames = [];
  bool _isLoading = true;
  String? _errorMessage;

  GameNotifier(this._storageService);

  Game? get activeGame => _activeGame;
  List<Game> get allGames => _allGames;
  List<Game> get completedGames =>
      _allGames.where((g) => g.isCompleted).toList();
  List<Game> get inProgressGames =>
      _allGames.where((g) => !g.isCompleted).toList();
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// Loads saved games and the active game on startup.
  Future<void> init() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allGames = await _storageService.getAllGames();
      _activeGame = await _storageService.getActiveGame();
    } catch (e) {
      _errorMessage = 'Impossible de charger les données: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Refreshes games list from storage.
  Future<void> refreshGames() async {
    try {
      _allGames = await _storageService.getAllGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Erreur lors du rechargement des parties: $e';
      notifyListeners();
    }
  }

  /// Starts a new game session.
  Future<Game> startNewGame({
    required List<String> playerNames,
    int eliminationLimit = 151,
  }) async {
    _errorMessage = null;
    try {
      final newGame = GameEngine.createNewGame(
        playerNames: playerNames,
        eliminationLimit: eliminationLimit,
      );

      _activeGame = newGame;
      await _storageService.saveGame(newGame);
      await _storageService.setActiveGameId(newGame.id);

      _allGames = await _storageService.getAllGames();
      notifyListeners();
      return newGame;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Loads an existing game by ID.
  Future<void> loadGame(String gameId) async {
    _errorMessage = null;
    final game = _allGames.where((g) => g.id == gameId).firstOrNull;
    if (game != null) {
      _activeGame = game;
      if (!game.isCompleted) {
        await _storageService.setActiveGameId(game.id);
      }
      notifyListeners();
    }
  }

  /// Commits a round to the active game.
  Future<void> commitRound({
    required String winnerId,
    required Map<String, int> scoresToAdd,
  }) async {
    if (_activeGame == null) return;
    _errorMessage = null;

    try {
      final updatedGame = GameEngine.commitRound(
        game: _activeGame!,
        winnerId: winnerId,
        scoresToAdd: scoresToAdd,
      );

      _activeGame = updatedGame;
      await _storageService.saveGame(updatedGame);
      _allGames = await _storageService.getAllGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Applies Revanche to an eligible player.
  Future<void> applyRevanche(String playerId) async {
    if (_activeGame == null) return;
    _errorMessage = null;

    try {
      final updatedGame = GameEngine.applyRevanche(_activeGame!, playerId);
      _activeGame = updatedGame;
      await _storageService.saveGame(updatedGame);
      _allGames = await _storageService.getAllGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Applies definitive elimination to an eligible player.
  Future<void> applyDefinitiveElimination(String playerId) async {
    if (_activeGame == null) return;
    _errorMessage = null;

    try {
      final updatedGame = GameEngine.applyDefinitiveElimination(
        _activeGame!,
        playerId,
      );
      _activeGame = updatedGame;
      await _storageService.saveGame(updatedGame);
      _allGames = await _storageService.getAllGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Undoes the last committed round.
  Future<void> undoLastRound() async {
    if (_activeGame == null) return;
    if (!GameEngine.canUndo(_activeGame!)) return;
    _errorMessage = null;

    try {
      final revertedGame = GameEngine.undoLastRound(_activeGame!);
      _activeGame = revertedGame;
      await _storageService.saveGame(revertedGame);
      _allGames = await _storageService.getAllGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Deletes a game permanently.
  Future<void> deleteGame(String gameId) async {
    _errorMessage = null;
    try {
      await _storageService.deleteGame(gameId);
      if (_activeGame?.id == gameId) {
        _activeGame = null;
      }
      _allGames = await _storageService.getAllGames();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  /// Clears the active game reference.
  void clearActiveGame() {
    _activeGame = null;
    notifyListeners();
  }
}
