import 'package:intl/intl.dart';

class ClientEntity {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? notes;
  final List<dynamic> events;
  final double totalSpent;
  final int eventsCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ClientEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.notes,
    this.events = const [],
    this.totalSpent = 0,
    this.eventsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  String get displayName => name;

  String get formattedPhone {
    if (phone == null || phone!.isEmpty) return 'N/A';
    return phone!;
  }

  String get formattedLastEventDate => 'No hay eventos';

  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);
  String get formattedUpdatedAt => DateFormat('dd/MM/yyyy').format(updatedAt);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'notes': notes,
      'events': events,
      'totalSpent': totalSpent,
      'eventsCount': eventsCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ClientEntity copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? notes,
    List<dynamic>? events,
    double? totalSpent,
    int? eventsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClientEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      notes: notes ?? this.notes,
      events: events ?? this.events,
      totalSpent: totalSpent ?? this.totalSpent,
      eventsCount: eventsCount ?? this.eventsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ClientPayment {
  final String id;
  final String eventId;
  final DateTime paymentDate;
  final double amount;
  final String? method;
  final String? notes;

  const ClientPayment({
    required this.id,
    required this.eventId,
    required this.paymentDate,
    required this.amount,
    this.method,
    this.notes,
  });

  String get formattedPaymentDate => DateFormat('dd/MM/yyyy HH:mm').format(paymentDate);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'paymentDate': paymentDate.toIso8601String(),
      'amount': amount,
      'method': method,
      'notes': notes,
    };
  }
}
