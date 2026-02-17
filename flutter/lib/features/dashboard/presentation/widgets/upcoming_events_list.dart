import 'package:flutter/material.dart';
import 'package:eventosapp/features/dashboard/domain/entities/dashboard_entities.dart';
import 'package:eventosapp/core/utils/date_formatter.dart';
import 'package:eventosapp/core/utils/formatters.dart';
import 'package:go_router/go_router.dart';
import 'package:eventosapp/shared/widgets/status_badge.dart';

class UpcomingEventsList extends StatelessWidget {
  final List<EventSummary> events;
  final int maxItems;

  const UpcomingEventsList({
    required this.events,
    this.maxItems = 5,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final displayEvents = events.take(maxItems).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Próximos Eventos',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (events.length > maxItems)
                  TextButton(
                    onPressed: () => context.push('/events'),
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
            if (displayEvents.isEmpty) ...[
              const SizedBox(height: 16),
              const Center(
                child: Text('No hay eventos próximos'),
              ),
            ] else ...[
              const SizedBox(height: 16),
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                separatorBuilder: (context, index) => const Divider(),
                itemCount: displayEvents.length,
                itemBuilder: (context, index) {
                  final event = displayEvents[index];
                  return _EventListItem(event: event);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EventListItem extends StatelessWidget {
  final EventSummary event;

  const _EventListItem({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/events/${event.id}'),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        event.eventName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        event.clientName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(event.totalAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (event.pendingAmount > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          'Pendiente: ${CurrencyFormatter.format(event.pendingAmount)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 4),
                Text(
                  DateFormatter.format(event.eventDate),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(width: 16),
                StatusBadge(
                  label: _getStatusLabel(event.status),
                  color: _getStatusColor(event.status),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmado';
      case 'pending':
        return 'Pendiente';
      case 'cancelled':
        return 'Cancelado';
      case 'completed':
        return 'Completado';
      default:
        return status;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
}
