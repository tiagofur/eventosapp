package com.creapolis.solennix.core.database.entity

import androidx.room.ColumnInfo
import androidx.room.Entity
import androidx.room.PrimaryKey
import com.creapolis.solennix.core.model.InventoryItem
import com.creapolis.solennix.core.model.InventoryType

@Entity(tableName = "inventory")
data class CachedInventoryItem(
    @PrimaryKey val id: String,
    @ColumnInfo(name = "user_id") val userId: String,
    @ColumnInfo(name = "ingredient_name") val ingredientName: String,
    @ColumnInfo(name = "current_stock") val currentStock: Double,
    @ColumnInfo(name = "minimum_stock") val minimumStock: Double,
    val unit: String,
    @ColumnInfo(name = "unit_cost") val unitCost: Double?,
    @ColumnInfo(name = "last_updated") val lastUpdated: String,
    val type: InventoryType
)

fun CachedInventoryItem.asExternalModel() = InventoryItem(
    id = id,
    userId = userId,
    ingredientName = ingredientName,
    currentStock = currentStock,
    minimumStock = minimumStock,
    unit = unit,
    unitCost = unitCost,
    lastUpdated = lastUpdated,
    type = type
)

fun InventoryItem.asEntity() = CachedInventoryItem(
    id = id,
    userId = userId,
    ingredientName = ingredientName,
    currentStock = currentStock,
    minimumStock = minimumStock,
    unit = unit,
    unitCost = unitCost,
    lastUpdated = lastUpdated,
    type = type
)
