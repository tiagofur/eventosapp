import 'package:eventosapp/features/clients/domain/entities/client_entity.dart';

class ClientModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? address;
  final String? city;
  final String? notes;
  final double totalSpent;
  final int eventsCount;
  final String createdAt;
  final String updatedAt;

  ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.address,
    this.city,
    this.notes,
    this.totalSpent = 0,
    this.eventsCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClientModel.fromJson(Map<String, dynamic> json) {
    return ClientModel(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      notes: json['notes'] as String?,
      totalSpent: (json['total_spent'] as num?)?.toDouble() ?? 0,
      eventsCount: json['total_events'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'city': city,
      'notes': notes,
      'total_spent': totalSpent,
      'total_events': eventsCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ClientEntity toEntity() {
    return ClientEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      address: address,
      city: city,
      notes: notes,
      totalSpent: totalSpent,
      eventsCount: eventsCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static ClientModel fromEntity(ClientEntity entity) {
    return ClientModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      address: entity.address,
      city: entity.city,
      notes: entity.notes,
      totalSpent: entity.totalSpent,
      eventsCount: entity.eventsCount,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}
