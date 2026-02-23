import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/alert.dart';

class StatusHeroCard extends StatelessWidget {
  final Alert? latestAlert;
  final DateTime? lastUpdated;

  const StatusHeroCard({
    super.key,
    required this.latestAlert,
    required this.lastUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final bool isCritical =
        latestAlert != null &&
        DateTime.now().difference(latestAlert!.timestamp).inMinutes < 5;

    final color = isCritical ? Colors.redAccent : Colors.greenAccent;
    final icon = isCritical
        ? LucideIcons.alertTriangle
        : LucideIcons.checkCircle;
    final title = isCritical ? 'Spike Detected!' : 'All Systems Safe';
    final desc = isCritical
        ? latestAlert!.message
        : 'Power consumption is within expected range.';

    return Card(
      color: const Color(0xFF1E293B), // Slate 800
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  LucideIcons.activity,
                  color: Colors.white70,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 48),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Last updated: ${lastUpdated?.toLocal().toString().split('.')[0] ?? 'N/A'}',
              style: const TextStyle(fontSize: 12, color: Colors.white54),
            ),
          ],
        ),
      ),
    );
  }
}
