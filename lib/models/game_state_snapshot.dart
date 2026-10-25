import 'player.dart';
import 'round.dart';

enum GameStatus { inProgress, completed }

/// A point-in-time snapshot of the game used to support reliable, exact undo.
class GameStateSnapshot {
  final List<Player> players;
  final List<Round> rounds;
  final GameStatus status;
  final String? winnerId;
  final DateTime? completedAt;

  const GameStateSnapshot({
    required this.players,
    required this.rounds,
    required this.status,
    this.winnerId,
    this.completedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'players': players.map((p) => p.toJson()).toList(),
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'status': status.name,
      'winnerId': winnerId,
      'completedAt': completedAt?.toIso8601String(),
    };
  }

  factory GameStateSnapshot.fromJson(Map<String, dynamic> json) {
    return GameStateSnapshot(
      players: (json['players'] as List<dynamic>)
          .map((p) => Player.fromJson(p as Map<String, dynamic>))
          .toList(),
      rounds: (json['rounds'] as List<dynamic>)
          .map((r) => Round.fromJson(r as Map<String, dynamic>))
          .toList(),
      status: GameStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => GameStatus.inProgress,
      ),
      winnerId: json['winnerId'] as String?,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}
