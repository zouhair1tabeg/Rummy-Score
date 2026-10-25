/// Represents a completed round in a Rummy game.
class Round {
  final int roundNumber;
  final String winnerId;
  final Map<String, int> scoresAdded;
  final Map<String, int> cumulativeScoresAfter;
  final DateTime timestamp;
  final Map<String, int> revancheEvents;
  final List<String> eliminationEvents;

  const Round({
    required this.roundNumber,
    required this.winnerId,
    required this.scoresAdded,
    required this.cumulativeScoresAfter,
    required this.timestamp,
    this.revancheEvents = const {},
    this.eliminationEvents = const [],
  });

  Round copyWith({
    int? roundNumber,
    String? winnerId,
    Map<String, int>? scoresAdded,
    Map<String, int>? cumulativeScoresAfter,
    DateTime? timestamp,
    Map<String, int>? revancheEvents,
    List<String>? eliminationEvents,
  }) {
    return Round(
      roundNumber: roundNumber ?? this.roundNumber,
      winnerId: winnerId ?? this.winnerId,
      scoresAdded: scoresAdded ?? this.scoresAdded,
      cumulativeScoresAfter:
          cumulativeScoresAfter ?? this.cumulativeScoresAfter,
      timestamp: timestamp ?? this.timestamp,
      revancheEvents: revancheEvents ?? this.revancheEvents,
      eliminationEvents: eliminationEvents ?? this.eliminationEvents,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'winnerId': winnerId,
      'scoresAdded': scoresAdded,
      'cumulativeScoresAfter': cumulativeScoresAfter,
      'timestamp': timestamp.toIso8601String(),
      'revancheEvents': revancheEvents,
      'eliminationEvents': eliminationEvents,
    };
  }

  factory Round.fromJson(Map<String, dynamic> json) {
    return Round(
      roundNumber: (json['roundNumber'] as num).toInt(),
      winnerId: json['winnerId'] as String,
      scoresAdded: (json['scoresAdded'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as num).toInt()),
      ),
      cumulativeScoresAfter:
          (json['cumulativeScoresAfter'] as Map<String, dynamic>).map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      revancheEvents:
          (json['revancheEvents'] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, (value as num).toInt()),
          ) ??
          const {},
      eliminationEvents:
          (json['eliminationEvents'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
