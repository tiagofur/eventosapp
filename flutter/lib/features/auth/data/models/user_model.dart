import 'package:eventosapp/features/auth/domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String email;
  final String name;
  final String? businessName;
  final double? defaultDepositPercent;
  final double? defaultCancellationDays;
  final double? defaultRefundPercent;
  final String plan;
  final String? stripeCustomerId;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.businessName,
    this.defaultDepositPercent,
    this.defaultCancellationDays,
    this.defaultRefundPercent,
    required this.plan,
    this.stripeCustomerId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      businessName: json['business_name'] as String?,
      defaultDepositPercent: (json['default_deposit_percent'] as num?)?.toDouble(),
      defaultCancellationDays: (json['default_cancellation_days'] as num?)?.toDouble(),
      defaultRefundPercent: (json['default_refund_percent'] as num?)?.toDouble(),
      plan: json['plan'] as String,
      stripeCustomerId: json['stripe_customer_id'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  bool get isPremium => plan == 'premium';

  String get displayName => businessName ?? name;

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      businessName: businessName,
      defaultDepositPercent: defaultDepositPercent,
      defaultCancellationDays: defaultCancellationDays,
      defaultRefundPercent: defaultRefundPercent,
      plan: plan,
      stripeCustomerId: stripeCustomerId,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
