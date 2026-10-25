import 'game_state_snapshot.dart';
import 'player.dart';
import 'round.dart';

/// Represents a Rummy game session.
class Game {
  final String id;
  final DateTime createdAt;
  final DateTime? completedAt;
  final int eliminationLimit;
  final int initialPlayerCount;
  final List<Player> players;
  final List<Round> rounds;
  final GameStatus status;
  final String? winnerId;
  final List<GameStateSnapshot> undoSnapshots;

  const Game({
    required this.id,
    required this.createdAt,
    this.completedAt,
    this.eliminationLimit = 151,
    required this.initialPlayerCount,
    required this.players,
    this.rounds = const [],
    this.status = GameStatus.inProgress,
    this.winnerId,
    this.undoSnapshots = const [],
  });

  bool get isCompleted => status == GameStatus.completed;

  List<Player> get activePlayers =>
      players.where((p) => !p.isEliminated).toList();

  List<Player> get eliminatedPlayers =>
      players.where((p) => p.isEliminated).toList();

  Player? get winner => winnerId != null
      ? players.where((p) => p.id == winnerId).firstOrNull
      : null;

  /// Active players whose score currently reaches or exceeds the elimination limit,
  /// requiring an elimination or revanche decision.
  List<Player> get pendingEliminationPlayers => activePlayers
      .where((p) => p.cumulativeScore >= eliminationLimit)
      .toList();

  bool get hasPendingDecisions => pendingEliminationPlayers.isNotEmpty;

  Game copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? completedAt,
    int? eliminationLimit,
    int? initialPlayerCount,
    List<Player>? players,
    List<Round>? rounds,
    GameStatus? status,
    String? winnerId,
    List<GameStateSnapshot>? undoSnapshots,
  }) {
    return Game(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      eliminationLimit: eliminationLimit ?? this.eliminationLimit,
      initialPlayerCount: initialPlayerCount ?? this.initialPlayerCount,
      players: players ?? this.players,
      rounds: rounds ?? this.rounds,
      status: status ?? this.status,
      winnerId: winnerId ?? this.winnerId,
      undoSnapshots: undoSnapshots ?? this.undoSnapshots,
    );
  }

  GameStateSnapshot createSnapshot() {
    return GameStateSnapshot(
      players: players.map((p) => p.copyWith()).toList(),
      rounds: rounds.map((r) => r.copyWith()).toList(),
      status: status,
      winnerId: winnerId,
      completedAt: completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'createdAt': createdAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'eliminationLimit': eliminationLimit,
      'initialPlayerCount': initialPlayerCount,
      'players': players.map((p) => p.toJson()).toList(),
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'status': status.name,
      'winnerId': winnerId,
      'undoSnapshots': undoSnapshots.map((s) => s.toJson()).toList(),
    };
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final playersList = (json['players'] as List<dynamic>)
        .map((p) => Player.fromJson(p as Map<String, dynamic>))
        .toList();

    return Game(
      id: json['id'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      eliminationLimit: (json['eliminationLimit'] as num?)?.toInt() ?? 151,
      initialPlayerCount:
          (json['initialPlayerCount'] as num?)?.toInt() ?? playersList.length,
      players: playersList,
      rounds:
          (json['rounds'] as List<dynamic>?)
              ?.map((r) => Round.fromJson(r as Map<String, dynamic>))
              .toList() ??
          const [],
      status: GameStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => GameStatus.inProgress,
      ),
      winnerId: json['winnerId'] as String?,
      undoSnapshots:
          (json['undoSnapshots'] as List<dynamic>?)
              ?.map(
                (s) => GameStateSnapshot.fromJson(s as Map<String, dynamic>),
              )
              .toList() ??
          const [],
    );
  }
}
