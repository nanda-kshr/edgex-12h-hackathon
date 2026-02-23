class Forecast {
  final DateTime time;
  final double expectedPower;
  final double spikeThreshold;

  Forecast({
    required this.time,
    required this.expectedPower,
    required this.spikeThreshold,
  });

  factory Forecast.fromJson(Map<String, dynamic> json) {
    return Forecast(
      time: DateTime.parse(json['time']).toLocal(),
      expectedPower: (json['expected_power'] ?? 0).toDouble(),
      spikeThreshold: (json['spike_threshold'] ?? 0).toDouble(),
    );
  }
}
