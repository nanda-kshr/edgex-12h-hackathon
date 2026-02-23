class Alert {
  final String id;
  final DateTime timestamp;
  final String applianceId;
  final double power;
  final double threshold;
  final String message;

  Alert({
    required this.id,
    required this.timestamp,
    required this.applianceId,
    required this.power,
    required this.threshold,
    required this.message,
  });

  factory Alert.fromJson(Map<String, dynamic> json) {
    return Alert(
      id: json['_id'] ?? '',
      timestamp: DateTime.parse(json['timestamp']),
      applianceId: json['appliance_id'] ?? '',
      power: (json['power'] ?? 0).toDouble(),
      threshold: (json['threshold'] ?? 0).toDouble(),
      message: json['message'] ?? '',
    );
  }
}
