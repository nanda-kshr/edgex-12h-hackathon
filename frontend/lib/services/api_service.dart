import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/alert.dart';
import '../models/reading.dart';
import '../models/forecast.dart';

class ApiService {
  static String get baseUrl {
    // We bind directly to the machine's local network IP so physical devices
    // and emulators alike can hit the backend properly:
    return 'http://10.209.214.68:8000';
  }

  Future<List<Alert>> getRecentAlerts() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/alerts/recent'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> alertsJson = data['alerts'];
        return alertsJson.map((json) => Alert.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load alerts');
      }
    } catch (e) {
      print('Error fetching alerts: $e');
      return [];
    }
  }

  Future<List<Reading>> getRecentReadings({String filter = '60m'}) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/readings/recent?filter=$filter'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> readingsJson = data['readings'];
        return readingsJson.map((json) {
          // Because aggregation changes ISO strings to "YYYY-MM-DD HH:MM", we have to handle the format properly to conform to reading.dart
          return Reading.fromJson({
            ...json,
            // Re-adding the T and Z to conform back to regular parsing
            'timestamp': (json['timestamp'] as String).contains('T')
                ? json['timestamp']
                : (json['timestamp'] as String).replaceFirst(' ', 'T') +
                      ':00.000Z',
          });
        }).toList();
      } else {
        throw Exception('Failed to load readings');
      }
    } catch (e) {
      print('Error fetching readings: $e');
      return [];
    }
  }

  Future<List<Forecast>> getForecasts() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast/predictions'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> forecastsJson = data['forecasts'];
        return forecastsJson.map((json) => Forecast.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load forecasts');
      }
    } catch (e) {
      print('Error fetching forecasts: $e');
      return [];
    }
  }
}
