package com.creapolis.solennix.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class SupplySuggestion(
    val id: String,
    @SerialName("ingredient_name") val ingredientName: String,
    @SerialName("current_stock") val currentStock: Double,
    val unit: String,
    @SerialName("unit_cost") val unitCost: Double,
    @SerialName("suggested_quantity") val suggestedQuantity: Double
)
