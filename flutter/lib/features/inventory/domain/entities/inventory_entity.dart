import 'package:intl/intl.dart';

class InventoryItemEntity {
  final String id;
  final String ingredientName;
  final double currentStock;
  final double minimumStock;
  final String unit;
  final double unitCost;
  final String type;
  final DateTime lastUpdated;

  const InventoryItemEntity({
    required this.id,
    required this.ingredientName,
    required this.currentStock,
    required this.minimumStock,
    required this.unit,
    required this.unitCost,
    required this.type,
    required this.lastUpdated,
  });

  bool get isLowStock => currentStock <= minimumStock;

  String get formattedCurrentStock => '${_formatNumber(currentStock)} $unit';
  String get formattedMinimumStock => '${_formatNumber(minimumStock)} $unit';
  String get formattedUnitCost => '\$${NumberFormat('0.00').format(unitCost)}/$unit';
  String get formattedLastUpdated => DateFormat('dd/MM/yyyy').format(lastUpdated);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient_name': ingredientName,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'unit': unit,
      'unit_cost': unitCost,
      'type': type,
      'last_updated': lastUpdated.toIso8601String(),
    };
  }

  InventoryItemEntity copyWith({
    String? id,
    String? ingredientName,
    double? currentStock,
    double? minimumStock,
    String? unit,
    double? unitCost,
    String? type,
    DateTime? lastUpdated,
  }) {
    return InventoryItemEntity(
      id: id ?? this.id,
      ingredientName: ingredientName ?? this.ingredientName,
      currentStock: currentStock ?? this.currentStock,
      minimumStock: minimumStock ?? this.minimumStock,
      unit: unit ?? this.unit,
      unitCost: unitCost ?? this.unitCost,
      type: type ?? this.type,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  String _formatNumber(double value) {
    return NumberFormat('0.##').format(value);
  }
}
