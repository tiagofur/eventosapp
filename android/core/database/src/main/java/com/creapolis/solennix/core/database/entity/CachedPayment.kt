package com.creapolis.solennix.core.database.entity

import androidx.room.Entity
import androidx.room.PrimaryKey
import com.creapolis.solennix.core.model.Payment

@Entity(tableName = "payments")
data class CachedPayment(
    @PrimaryKey val id: String,
    val eventId: String,
    val userId: String,
    val amount: Double,
    val paymentDate: String,
    val paymentMethod: String,
    val notes: String?,
    val createdAt: String
)

fun Payment.asEntity() = CachedPayment(
    id = id,
    eventId = eventId,
    userId = userId,
    amount = amount,
    paymentDate = paymentDate,
    paymentMethod = paymentMethod,
    notes = notes,
    createdAt = createdAt
)

fun CachedPayment.asExternalModel() = Payment(
    id = id,
    eventId = eventId,
    userId = userId,
    amount = amount,
    paymentDate = paymentDate,
    paymentMethod = paymentMethod,
    notes = notes,
    createdAt = createdAt
)
