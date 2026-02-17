class EventModel {
  final String id;
  final String clientId;
  final String clientName;
  final DateTime eventDate;
  final String startTime;
  final String endTime;
  final String serviceType;
  final int numPeople;
  final String status;
  final double discount;
  final bool requiresInvoice;
  final double taxRate;
  final double taxAmount;
  final double totalAmount;
  final String location;
  final String? city;
  final double depositPercent;
  final double cancellationDays;
  final double refundPercent;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<PaymentModel> payments;

  EventModel({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.eventDate,
    required this.startTime,
    required this.endTime,
    required this.serviceType,
    required this.numPeople,
    required this.status,
    required this.discount,
    required this.requiresInvoice,
    required this.taxRate,
    required this.taxAmount,
    required this.totalAmount,
    required this.location,
    this.city,
    required this.depositPercent,
    required this.cancellationDays,
    required this.refundPercent,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.payments = const [],
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    final clientJson = json['clients'] as Map<String, dynamic>?;
    final paymentsJson = (json['payments'] as List<dynamic>?) ?? const [];

    return EventModel(
      id: json['id'] as String,
      clientId: json['client_id'] as String,
      clientName: clientJson?['name'] as String? ?? '',
      eventDate: DateTime.parse(json['event_date'] as String),
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      serviceType: json['service_type'] as String? ?? '',
      numPeople: (json['num_people'] as num?)?.toInt() ?? 0,
      status: json['status'] as String,
      discount: (json['discount'] as num?)?.toDouble() ?? 0,
      requiresInvoice: json['requires_invoice'] as bool? ?? false,
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0,
      location: json['location'] as String? ?? '',
      city: json['city'] as String?,
      depositPercent: (json['deposit_percent'] as num?)?.toDouble() ?? 0,
      cancellationDays: (json['cancellation_days'] as num?)?.toDouble() ?? 0,
      refundPercent: (json['refund_percent'] as num?)?.toDouble() ?? 0,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      payments: paymentsJson
          .map((e) => PaymentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class PaymentModel {
  final String id;
  final String eventId;
  final DateTime paymentDate;
  final double amount;
  final String? paymentMethod;
  final String? notes;

  const PaymentModel({
    required this.id,
    required this.eventId,
    required this.paymentDate,
    required this.amount,
    this.paymentMethod,
    this.notes,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      eventId: json['event_id'] as String,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      amount: (json['amount'] as num).toDouble(),
      paymentMethod: json['payment_method'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

class EventResponseModel {
  final EventModel event;

  EventResponseModel({required this.event});

  factory EventResponseModel.fromJson(Map<String, dynamic> json) {
    return EventResponseModel(
      event: EventModel.fromJson(json['event'] as Map<String, dynamic>? ?? json),
    );
  }
}

class EventsListResponseModel {
  final List<EventModel> events;

  const EventsListResponseModel({required this.events});

  factory EventsListResponseModel.fromJson(dynamic json) {
    if (json is List) {
      return EventsListResponseModel(
        events: json
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    if (json is Map<String, dynamic> && json['events'] is List) {
      final eventsJson = json['events'] as List<dynamic>;
      return EventsListResponseModel(
        events: eventsJson
            .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
    }
    return const EventsListResponseModel(events: []);
  }
}
