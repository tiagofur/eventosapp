import 'package:eventosapp/features/inventory/domain/entities/inventory_entity.dart';

class InventoryItemModel {
  final String id;
  final String ingredientName;
  final double currentStock;
  final double minimumStock;
  final String unit;
  final double unitCost;
  final String type;
  final String lastUpdated;

  InventoryItemModel({
    required this.id,
    required this.ingredientName,
    required this.currentStock,
    required this.minimumStock,
    required this.unit,
    required this.unitCost,
    required this.type,
    required this.lastUpdated,
  });

  factory InventoryItemModel.fromJson(Map<String, dynamic> json) {
    return InventoryItemModel(
      id: json['id'] as String,
      ingredientName: json['ingredient_name'] as String,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0,
      minimumStock: (json['minimum_stock'] as num?)?.toDouble() ?? 0,
      unit: json['unit'] as String? ?? '',
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0,
      type: json['type'] as String? ?? 'ingredient',
      lastUpdated: json['last_updated'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ingredient_name': ingredientName,
      'current_stock': currentStock,
      'minimum_stock': minimumStock,
      'unit': unit,
      'unit_cost': unitCost,
      'type': type,
      'last_updated': lastUpdated,
    };
  }

  InventoryItemEntity toEntity() {
    return InventoryItemEntity(
      id: id,
      ingredientName: ingredientName,
      currentStock: currentStock,
      minimumStock: minimumStock,
      unit: unit,
      unitCost: unitCost,
      type: type,
      lastUpdated: DateTime.tryParse(lastUpdated) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static InventoryItemModel fromEntity(InventoryItemEntity entity) {
    return InventoryItemModel(
      id: entity.id,
      ingredientName: entity.ingredientName,
      currentStock: entity.currentStock,
      minimumStock: entity.minimumStock,
      unit: entity.unit,
      unitCost: entity.unitCost,
      type: entity.type,
      lastUpdated: entity.lastUpdated.toIso8601String(),
    );
  }
}
