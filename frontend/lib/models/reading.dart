class Reading {
  final String id;
  final DateTime timestamp;
  final double power;

  Reading({required this.id, required this.timestamp, required this.power});

  factory Reading.fromJson(Map<String, dynamic> json) {
    return Reading(
      id: json['_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      power: (json['power'] ?? 0).toDouble(),
    );
  }
}
