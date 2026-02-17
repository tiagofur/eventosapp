import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProductEntity {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double basePrice;
  final bool isActive;
  final List<RecipeIngredient>? recipe;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProductEntity({
    required this.id,
    required this.name,
    this.description,
    required this.category,
    required this.basePrice,
    required this.isActive,
    this.recipe,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get hasRecipe => recipe != null && recipe!.isNotEmpty;

  String get statusLabel => isActive ? 'Activo' : 'Inactivo';
  Color get statusColor => isActive ? const Color(0xFF2E7D32) : const Color(0xFF616161);

  String get formattedPrice => '\$${basePrice.toStringAsFixed(2)}';
  String get formattedCreatedAt => DateFormat('dd/MM/yyyy').format(createdAt);
  String get formattedUpdatedAt => DateFormat('dd/MM/yyyy').format(updatedAt);

  double get recipeCost {
    if (recipe == null || recipe!.isEmpty) return 0;
    return recipe!.fold(0.0, (sum, ingredient) => sum + ingredient.totalCost);
  }

  double get profitMargin => basePrice - recipeCost;
  double get profitPercentage => basePrice > 0 ? (profitMargin / basePrice) * 100 : 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'base_price': basePrice,
      'is_active': isActive,
      'recipe': recipe?.map((e) => e.toJson()).toList(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  ProductEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? basePrice,
    bool? isActive,
    List<RecipeIngredient>? recipe,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      basePrice: basePrice ?? this.basePrice,
      isActive: isActive ?? this.isActive,
      recipe: recipe ?? this.recipe,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class RecipeIngredient {
  final String id;
  final String inventoryId;
  final String ingredientName;
  final String unit;
  final double quantityRequired;
  final double unitCost;
  final DateTime createdAt;

  const RecipeIngredient({
    required this.id,
    required this.inventoryId,
    required this.ingredientName,
    required this.unit,
    required this.quantityRequired,
    required this.unitCost,
    required this.createdAt,
  });

  double get totalCost => quantityRequired * unitCost;
  String get formattedCost => '\$${totalCost.toStringAsFixed(2)}';
  String get formattedQuantity => '${_formatNumber(quantityRequired)} $unit';
  String get formattedUnitCost => '\$${unitCost.toStringAsFixed(2)}/$unit';
  String get formattedCostPerUnit => formattedUnitCost;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'ingredient_name': ingredientName,
      'unit': unit,
      'quantity_required': quantityRequired,
      'unit_cost': unitCost,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String _formatNumber(double value) {
    return NumberFormat('0.##').format(value);
  }
}
