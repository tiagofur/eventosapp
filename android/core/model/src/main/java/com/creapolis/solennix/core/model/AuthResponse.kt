package com.creapolis.solennix.core.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class AuthResponse(
    val user: User,
    val token: String? = null,         // Legacy format
    val tokens: TokenPair? = null      // New format
) {
    val accessToken: String get() = tokens?.accessToken ?: token ?: ""
    val refreshToken: String get() = tokens?.refreshToken ?: token ?: ""
}

@Serializable
data class TokenPair(
    @SerialName("access_token") val accessToken: String,
    @SerialName("refresh_token") val refreshToken: String
)
