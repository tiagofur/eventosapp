import 'package:flutter/material.dart';
import 'package:eventosapp/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:eventosapp/shared/widgets/status_badge.dart';

class InventoryAlertsList extends StatelessWidget {
  final List<InventoryAlert> alerts;
  final int maxItems;

  const InventoryAlertsList({
    required this.alerts,
    this.maxItems = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final displayAlerts = alerts.take(maxItems).toList();

    if (displayAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      color: Colors.red[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Alertas de Inventario',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                StatusBadge(
                  label: '${alerts.length} items',
                  color: alerts.isEmpty ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (context, index) => Divider(
                height: 1,
                color: Colors.red.withOpacity(0.2),
              ),
              itemCount: displayAlerts.length,
              itemBuilder: (context, index) {
                final alert = displayAlerts[index];
                return _InventoryAlertItem(alert: alert);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _InventoryAlertItem extends StatelessWidget {
  final InventoryAlert alert;

  const _InventoryAlertItem({required this.alert});

  @override
  Widget build(BuildContext context) {
    final isCritical = alert.isCritical;
    final stockLevel = alert.stockLevel;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isCritical ? Colors.red : Colors.orange,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.itemName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${alert.currentStock.toInt()} / ${alert.minStock.toInt()} ${alert.unit}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                LinearProgressIndicator(
                  value: stockLevel / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isCritical ? Colors.red : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: isCritical ? 'Crítico' : 'Bajo',
                color: isCritical ? Colors.red : Colors.orange,
              ),
              const SizedBox(height: 4),
              Text(
                '${alert.eventsAffected} eventos',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
