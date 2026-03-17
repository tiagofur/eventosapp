package com.creapolis.solennix.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class EquipmentConflict(
    @SerialName("inventory_id") val inventoryId: String,
    @SerialName("equipment_name") val equipmentName: String,
    @SerialName("conflicting_event_id") val conflictingEventId: String,
    @SerialName("event_date") val eventDate: String,
    @SerialName("start_time") val startTime: String? = null,
    @SerialName("end_time") val endTime: String? = null,
    @SerialName("service_type") val serviceType: String,
    @SerialName("client_name") val clientName: String? = null,
    @SerialName("conflict_type") val conflictType: ConflictType
)

@Serializable
enum class ConflictType {
    @SerialName("overlap") OVERLAP,
    @SerialName("insufficient_gap") INSUFFICIENT_GAP,
    @SerialName("full_day") FULL_DAY
}
