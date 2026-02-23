import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../services/api_service.dart';
import '../models/alert.dart';
import '../models/reading.dart';
import '../models/forecast.dart';
import '../widgets/status_hero_card.dart';
import '../widgets/power_chart_card.dart';
import '../widgets/recent_alerts_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _apiService = ApiService();
  List<Alert> _alerts = [];
  List<Reading> _readings = [];
  List<Forecast> _forecasts = [];
  bool _isLoading = true;
  DateTime? _lastUpdated;
  Timer? _timer;
  String _currentFilter = '60m'; // Default filter

  @override
  void initState() {
    super.initState();
    _fetchData();
    // Auto-refresh every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _fetchData();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final alerts = await _apiService.getRecentAlerts();
      final readings = await _apiService.getRecentReadings(
        filter: _currentFilter,
      );
      final forecasts = await _apiService.getForecasts();

      if (mounted) {
        setState(() {
          _alerts = alerts;
          _readings = readings;
          _forecasts = forecasts;
          _lastUpdated = DateTime.now();
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final latestAlert = _alerts.isNotEmpty ? _alerts.first : null;
    final bool isCritical =
        latestAlert != null &&
        DateTime.now().difference(latestAlert.timestamp).inMinutes < 5;

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Slate 900
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData,
          color: Colors.amber,
          backgroundColor: const Color(0xFF1E293B),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.amber.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            LucideIcons.zap,
                            color: Colors.amber,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Energy Monitor',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Filters SegmentedButton
                SegmentedButton<String>(
                  style: ButtonStyle(
                    backgroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.amber.withOpacity(0.2);
                      }
                      return Colors.transparent;
                    }),
                    foregroundColor: WidgetStateProperty.resolveWith<Color>((
                      Set<WidgetState> states,
                    ) {
                      if (states.contains(WidgetState.selected)) {
                        return Colors.amber;
                      }
                      return Colors.white70;
                    }),
                  ),
                  segments: const <ButtonSegment<String>>[
                    ButtonSegment<String>(
                      value: '60m',
                      label: Text('1h', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.timer, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'hourly',
                      label: Text('24h', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.view_day, size: 16),
                    ),
                    ButtonSegment<String>(
                      value: 'daily',
                      label: Text('30d', style: TextStyle(fontSize: 12)),
                      icon: Icon(Icons.calendar_month, size: 16),
                    ),
                  ],
                  selected: <String>{_currentFilter},
                  onSelectionChanged: (Set<String> newSelection) {
                    setState(() {
                      _currentFilter = newSelection.first;
                    });
                    _fetchData();
                  },
                ),
                const SizedBox(height: 24),

                // Dashboard Grid (Simplified for flutter - stacking vertically for mobile-first)
                // Wrap with LayoutBuilder for responsive if needed, but going vertical is safe for now
                StatusHeroCard(
                  latestAlert: latestAlert,
                  lastUpdated: _lastUpdated,
                ),
                const SizedBox(height: 24),

                PowerChartCard(
                  readings: _readings,
                  filter: _currentFilter,
                  forecasts: _forecasts,
                ),
                const SizedBox(height: 24),

                RecentAlertsList(
                  alerts: _alerts,
                  onRefresh: _fetchData,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
