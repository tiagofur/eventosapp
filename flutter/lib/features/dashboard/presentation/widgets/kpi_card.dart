import 'package:flutter/material.dart';
import 'package:eventosapp/core/utils/formatters.dart';
import 'package:eventosapp/features/dashboard/domain/entities/dashboard_entities.dart';

class KPICard extends StatelessWidget {
  final String title;
  final double value;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final String? trend;
  final bool isCurrency;
  final bool isPercentage;

  const KPICard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
    this.subtitle,
    this.trend,
    this.isCurrency = false,
    this.isPercentage = false,
    super.key,
  });

  String get formattedValue {
    if (isCurrency) {
      return CurrencyFormatter.format(value);
    } else if (isPercentage) {
      return CurrencyFormatter.formatPercent(value / 100);
    } else {
      return value.toInt().toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const Spacer(),
                if (trend != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (trend!.startsWith('+') ? Colors.green : Colors.red).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      trend!,
                      style: TextStyle(
                        color: trend!.startsWith('+') ? Colors.green : Colors.red,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              formattedValue,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
