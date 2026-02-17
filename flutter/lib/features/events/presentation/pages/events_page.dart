import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:eventosapp/shared/widgets/custom_app_bar.dart';
import 'package:eventosapp/shared/widgets/loading_widget.dart';
import 'package:eventosapp/shared/widgets/error_widget.dart' as app_widgets;
import 'package:eventosapp/shared/widgets/status_badge.dart';
import 'package:eventosapp/core/utils/date_formatter.dart';
import 'package:eventosapp/core/utils/formatters.dart';
import 'package:eventosapp/features/events/presentation/providers/events_provider.dart';
import 'package:eventosapp/features/events/presentation/providers/events_state.dart';
import 'package:eventosapp/features/events/domain/entities/event_entity.dart';

class EventsPage extends ConsumerStatefulWidget {
  const EventsPage({super.key});

  @override
  ConsumerState<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends ConsumerState<EventsPage> {
  final TextEditingController _searchController = TextEditingController();
  String? _selectedStatus;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Eventos',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => context.push('/events/new'),
            tooltip: 'Crear evento',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: eventsAsync.when(
              loading: () => const LoadingWidget(message: 'Cargando eventos...'),
              error: (error, stack) => app_widgets.ErrorWidget(
                message: error.toString(),
                onRetry: () => ref.read(eventsProvider.notifier).refresh(),
              ),
              data: (state) => _buildEventsList(state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por cliente o evento',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {});
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
        onChanged: (value) => setState(() {}),
      ),
    );
  }

  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildStatusChip('Todos', null),
            const SizedBox(width: 8),
            _buildStatusChip('Cotizado', 'quoted'),
            const SizedBox(width: 8),
            _buildStatusChip('Confirmado', 'confirmed'),
            const SizedBox(width: 8),
            _buildStatusChip('Completado', 'completed'),
            const SizedBox(width: 8),
            _buildStatusChip('Cancelado', 'cancelled'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label, String? status) {
    final selected = _selectedStatus == status;
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: (isSelected) {
        setState(() {
          _selectedStatus = isSelected ? status : null;
        });
        if (isSelected && status != null) {
          ref.read(eventsProvider.notifier).filterByStatus(status);
        } else {
          ref.read(eventsProvider.notifier).loadEvents();
        }
      },
    );
  }

  Widget _buildEventsList(EventsState state) {
    final query = _searchController.text.trim().toLowerCase();
    final filtered = state.events.where((event) {
      if (query.isEmpty) return true;
      return event.clientName.toLowerCase().contains(query) ||
          event.serviceType.toLowerCase().contains(query);
    }).toList();

    if (filtered.isEmpty) {
      return const Center(child: Text('No hay eventos disponibles'));
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(eventsProvider.notifier).refresh(),
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: filtered.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final event = filtered[index];
          return _EventCard(event: event);
        },
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventEntity event;

  const _EventCard({required this.event});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push('/events/${event.id}'),
      borderRadius: BorderRadius.circular(16),
      child: Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      event.serviceType,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  StatusBadge(
                    label: _statusLabel(event.status),
                    color: _statusColor(event.status),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                event.clientName,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text(DateFormatter.format(event.eventDate)),
                  const SizedBox(width: 12),
                  const Icon(Icons.schedule, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${event.startTime} - ${event.endTime}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  Expanded(child: Text(event.location)),
                  const SizedBox(width: 8),
                  Text(
                    CurrencyFormatter.format(event.totalAmount),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'confirmed':
        return 'Confirmado';
      case 'completed':
        return 'Completado';
      case 'cancelled':
        return 'Cancelado';
      case 'quoted':
        return 'Cotizado';
      default:
        return 'Cotizado';
    }
  }

  static Color _statusColor(String status) {
    switch (status) {
      case 'confirmed':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      case 'quoted':
        return Colors.orange;
      default:
        return Colors.orange;
    }
  }
}

class EventDetailPage extends ConsumerStatefulWidget {
  final String eventId;
  const EventDetailPage({super.key, required this.eventId});

  @override
  ConsumerState<EventDetailPage> createState() => _EventDetailPageState();
}

class _EventDetailPageState extends ConsumerState<EventDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(eventDetailProvider.notifier).loadEventDetail(widget.eventId));
  }

  @override
  Widget build(BuildContext context) {
    final detailAsync = ref.watch(eventDetailProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Detalle del Evento'),
      body: detailAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando evento...'),
        error: (error, stack) => app_widgets.ErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(eventDetailProvider.notifier).loadEventDetail(widget.eventId),
        ),
        data: (state) {
          final event = state.event;
          if (event == null) {
            return const Center(child: Text('Evento no encontrado'));
          }
          return RefreshIndicator(
            onRefresh: () => ref.read(eventDetailProvider.notifier).loadEventDetail(widget.eventId),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildHeader(event),
                const SizedBox(height: 16),
                _buildInfoCard(event),
                const SizedBox(height: 16),
                _buildPaymentsSection(event),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(EventEntity event) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    event.serviceType,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                  ),
                ),
                StatusBadge(
                  label: _EventCard._statusLabel(event.status),
                  color: _EventCard._statusColor(event.status),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(event.clientName, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(DateFormatter.format(event.eventDate)),
                const SizedBox(width: 12),
                const Icon(Icons.schedule, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text('${event.startTime} - ${event.endTime}'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Expanded(child: Text(event.location)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(EventEntity event) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _InfoRow(label: 'Total', value: CurrencyFormatter.format(event.totalAmount)),
            const SizedBox(height: 8),
            _InfoRow(label: 'Depósito', value: CurrencyFormatter.format(event.depositAmount)),
            const SizedBox(height: 8),
            _InfoRow(label: 'Saldo pendiente', value: CurrencyFormatter.format(event.pendingAmount)),
            const SizedBox(height: 8),
            _InfoRow(label: 'Notas', value: event.notes ?? 'Sin notas'),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentsSection(EventEntity event) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Pagos',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showAddPaymentDialog(event.id),
                  icon: const Icon(Icons.add),
                  label: const Text('Agregar'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (event.payments.isEmpty)
              const Text('Sin pagos registrados')
            else
              ...event.payments.map((payment) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(CurrencyFormatter.format(payment.amount)),
                  subtitle: Text(DateFormatter.format(payment.paymentDate)),
                  trailing: payment.method == 'deposit'
                      ? const StatusBadge(label: 'Depósito', color: Colors.blue)
                      : null,
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  Future<void> _showAddPaymentDialog(String eventId) async {
    final amountController = TextEditingController();
    final methodController = TextEditingController();
    bool isDeposit = false;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Agregar pago'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Monto'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: methodController,
                decoration: const InputDecoration(labelText: 'Método'),
              ),
              const SizedBox(height: 8),
              SwitchListTile(
                value: isDeposit,
                onChanged: (value) => setState(() => isDeposit = value),
                title: const Text('Es depósito'),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountController.text.trim()) ?? 0;
                await ref.read(eventDetailProvider.notifier).addPayment(eventId, {
                  'event_id': eventId,
                  'amount': amount,
                  'payment_date': DateTime.now().toIso8601String(),
                  'payment_method': isDeposit ? 'deposit' : methodController.text.trim(),
                  'notes': isDeposit ? 'Deposito' : null,
                });
                if (context.mounted) Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: TextStyle(color: Colors.grey[600]))),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class EventFormPage extends ConsumerStatefulWidget {
  const EventFormPage({super.key});

  @override
  ConsumerState<EventFormPage> createState() => _EventFormPageState();
}

class _EventFormPageState extends ConsumerState<EventFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _clientIdController = TextEditingController();
  final _serviceTypeController = TextEditingController();
  final _locationController = TextEditingController();
  final _notesController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _depositAmountController = TextEditingController();
  DateTime _eventDate = DateTime.now();
  TimeOfDay _startTime = const TimeOfDay(hour: 12, minute: 0);
  TimeOfDay _endTime = const TimeOfDay(hour: 18, minute: 0);
  String _status = 'pending';

  @override
  void dispose() {
    _clientIdController.dispose();
    _serviceTypeController.dispose();
    _locationController.dispose();
    _notesController.dispose();
    _totalAmountController.dispose();
    _depositAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Nuevo Evento'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _serviceTypeController,
              decoration: const InputDecoration(labelText: 'Tipo de servicio'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _clientIdController,
              decoration: const InputDecoration(labelText: 'Cliente (ID)'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _locationController,
              decoration: const InputDecoration(labelText: 'Lugar'),
              validator: (value) => value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(DateFormatter.format(_eventDate)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickStartTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_formatTime(_startTime)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickEndTime,
                    icon: const Icon(Icons.schedule),
                    label: Text(_formatTime(_endTime)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _totalAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Total'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _depositAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Depósito'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _status,
              items: const [
                DropdownMenuItem(value: 'quoted', child: Text('Cotizado')),
                DropdownMenuItem(value: 'confirmed', child: Text('Confirmado')),
                DropdownMenuItem(value: 'completed', child: Text('Completado')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelado')),
              ],
              onChanged: (value) => setState(() => _status = value ?? 'pending'),
              decoration: const InputDecoration(labelText: 'Estado'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: 'Notas'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submit,
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (selected != null) {
      setState(() => _eventDate = selected);
    }
  }

  Future<void> _pickStartTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (selected != null) {
      setState(() => _startTime = selected);
    }
  }

  Future<void> _pickEndTime() async {
    final selected = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (selected != null) {
      setState(() => _endTime = selected);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final totalAmount = double.tryParse(_totalAmountController.text.trim()) ?? 0;
    final depositPercent = double.tryParse(_depositAmountController.text.trim()) ?? 0;

    await ref.read(eventsProvider.notifier).createEvent({
      'client_id': _clientIdController.text.trim(),
      'event_date': _eventDate.toIso8601String(),
      'start_time': _formatTime(_startTime),
      'end_time': _formatTime(_endTime),
      'service_type': _serviceTypeController.text.trim(),
      'num_people': 0,
      'status': _status,
      'discount': 0,
      'requires_invoice': false,
      'tax_rate': 16,
      'tax_amount': 0,
      'total_amount': totalAmount,
      'location': _locationController.text.trim(),
      'city': null,
      'deposit_percent': depositPercent,
      'cancellation_days': 3,
      'refund_percent': 100,
      'notes': _notesController.text.trim(),
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Evento creado')),
      );
      context.pop();
    }
  }
}

class CalendarPage extends ConsumerWidget {
  const CalendarPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync = ref.watch(eventsProvider);

    return Scaffold(
      appBar: const CustomAppBar(title: 'Calendario'),
      body: eventsAsync.when(
        loading: () => const LoadingWidget(message: 'Cargando eventos...'),
        error: (error, stack) => app_widgets.ErrorWidget(
          message: error.toString(),
          onRetry: () => ref.read(eventsProvider.notifier).refresh(),
        ),
        data: (state) {
          if (state.events.isEmpty) {
            return const Center(child: Text('No hay eventos en el calendario'));
          }

          final grouped = <String, List<EventEntity>>{};
          for (final event in state.events) {
            final key = DateFormatter.format(event.eventDate);
            grouped.putIfAbsent(key, () => []).add(event);
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: grouped.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ...entry.value.map((event) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(event.serviceType),
                        subtitle: Text(event.clientName),
                        trailing: Text(event.startTime),
                        onTap: () => context.push('/events/${event.id}'),
                      )),
                  const SizedBox(height: 16),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
