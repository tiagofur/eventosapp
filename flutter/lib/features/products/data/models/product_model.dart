import 'package:eventosapp/features/products/domain/entities/product_entity.dart';

class ProductModel {
  final String id;
  final String name;
  final String? description;
  final String category;
  final double basePrice;
  final bool isActive;
  final List<RecipeIngredientModel>? recipe;
  final String createdAt;
  final String updatedAt;

  ProductModel({
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

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      category: json['category'] as String,
      basePrice: (json['base_price'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      recipe: (json['recipe'] as List<dynamic>?)
              ?.map((e) => RecipeIngredientModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'base_price': basePrice,
      'is_active': isActive,
      'recipe': recipe?.map((e) => e.toJson()).toList(),
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      name: name,
      description: description,
      category: category,
      basePrice: basePrice,
      isActive: isActive,
      recipe: recipe?.map((e) => e.toEntity()).toList(),
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static ProductModel fromEntity(ProductEntity entity) {
    return ProductModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      category: entity.category,
      basePrice: entity.basePrice,
      isActive: entity.isActive,
      recipe: entity.recipe?.map((e) => RecipeIngredientModel.fromEntity(e)).toList(),
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}

class RecipeIngredientModel {
  final String id;
  final String inventoryId;
  final String ingredientName;
  final String unit;
  final double quantityRequired;
  final double unitCost;
  final String createdAt;

  RecipeIngredientModel({
    required this.id,
    required this.inventoryId,
    required this.ingredientName,
    required this.unit,
    required this.quantityRequired,
    required this.unitCost,
    required this.createdAt,
  });

  factory RecipeIngredientModel.fromJson(Map<String, dynamic> json) {
    return RecipeIngredientModel(
      id: json['id'] as String,
      inventoryId: json['inventory_id'] as String,
      ingredientName: json['ingredient_name'] as String,
      unit: json['unit'] as String? ?? '',
      quantityRequired: (json['quantity_required'] as num?)?.toDouble() ?? 0.0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'inventory_id': inventoryId,
      'ingredient_name': ingredientName,
      'unit': unit,
      'quantity_required': quantityRequired,
      'unit_cost': unitCost,
      'created_at': createdAt,
    };
  }

  RecipeIngredient toEntity() {
    return RecipeIngredient(
      id: id,
      inventoryId: inventoryId,
      ingredientName: ingredientName,
      unit: unit,
      quantityRequired: quantityRequired,
      unitCost: unitCost,
      createdAt: DateTime.tryParse(createdAt) ?? DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static RecipeIngredientModel fromEntity(RecipeIngredient entity) {
    return RecipeIngredientModel(
      id: entity.id,
      inventoryId: entity.inventoryId,
      ingredientName: entity.ingredientName,
      unit: entity.unit,
      quantityRequired: entity.quantityRequired,
      unitCost: entity.unitCost,
      createdAt: entity.createdAt.toIso8601String(),
    );
  }
}
