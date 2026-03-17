package com.creapolis.solennix.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class EquipmentSuggestion(
    val id: String,
    @SerialName("ingredient_name") val ingredientName: String,
    @SerialName("current_stock") val currentStock: Double,
    val unit: String,
    val type: String,
    @SerialName("suggested_quantity") val suggestedQuantity: Double
)
