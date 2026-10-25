/// Represents a player participating in a Rummy game.
class Player {
  final String id;
  final String name;
  final int cumulativeScore;
  final bool isEliminated;
  final bool revancheUsed;
  final int? eliminatedAtRound;
  final int? revancheAtRound;
  final int? revancheScoreTaken;

  const Player({
    required this.id,
    required this.name,
    this.cumulativeScore = 0,
    this.isEliminated = false,
    this.revancheUsed = false,
    this.eliminatedAtRound,
    this.revancheAtRound,
    this.revancheScoreTaken,
  });

  bool get isActive => !isEliminated;

  Player copyWith({
    String? id,
    String? name,
    int? cumulativeScore,
    bool? isEliminated,
    bool? revancheUsed,
    int? eliminatedAtRound,
    int? revancheAtRound,
    int? revancheScoreTaken,
  }) {
    return Player(
      id: id ?? this.id,
      name: name ?? this.name,
      cumulativeScore: cumulativeScore ?? this.cumulativeScore,
      isEliminated: isEliminated ?? this.isEliminated,
      revancheUsed: revancheUsed ?? this.revancheUsed,
      eliminatedAtRound: eliminatedAtRound ?? this.eliminatedAtRound,
      revancheAtRound: revancheAtRound ?? this.revancheAtRound,
      revancheScoreTaken: revancheScoreTaken ?? this.revancheScoreTaken,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'cumulativeScore': cumulativeScore,
      'isEliminated': isEliminated,
      'revancheUsed': revancheUsed,
      'eliminatedAtRound': eliminatedAtRound,
      'revancheAtRound': revancheAtRound,
      'revancheScoreTaken': revancheScoreTaken,
    };
  }

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      id: json['id'] as String,
      name: json['name'] as String,
      cumulativeScore: (json['cumulativeScore'] as num?)?.toInt() ?? 0,
      isEliminated: json['isEliminated'] as bool? ?? false,
      revancheUsed: json['revancheUsed'] as bool? ?? false,
      eliminatedAtRound: (json['eliminatedAtRound'] as num?)?.toInt(),
      revancheAtRound: (json['revancheAtRound'] as num?)?.toInt(),
      revancheScoreTaken: (json['revancheScoreTaken'] as num?)?.toInt(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Player &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          cumulativeScore == other.cumulativeScore &&
          isEliminated == other.isEliminated &&
          revancheUsed == other.revancheUsed;

  @override
  int get hashCode =>
      id.hashCode ^
      name.hashCode ^
      cumulativeScore.hashCode ^
      isEliminated.hashCode ^
      revancheUsed.hashCode;
}
