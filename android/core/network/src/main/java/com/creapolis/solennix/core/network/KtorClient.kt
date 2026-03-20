package com.creapolis.solennix.core.network

import io.ktor.client.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.api.*
import io.ktor.client.plugins.contentnegotiation.*
import io.ktor.client.plugins.logging.*
import io.ktor.client.request.*
import io.ktor.http.*
import io.ktor.serialization.kotlinx.json.*
import kotlinx.serialization.json.Json
import java.util.concurrent.TimeUnit
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class KtorClient @Inject constructor(
    private val authManager: AuthManager
) {
    val httpClient = HttpClient(OkHttp) {
        install(ContentNegotiation) {
            json(Json {
                ignoreUnknownKeys = true
                isLenient = true
                encodeDefaults = false
                coerceInputValues = true
            })
        }
        // Manual bearer auth: reads token fresh from storage on every request.
        // This avoids the caching issue in Ktor's Auth plugin where tokens
        // stored after login are not picked up for subsequent API calls.
        install(createClientPlugin("BearerAuth") {
            onRequest { request, _ ->
                val tokens = authManager.getBearerTokens()
                if (tokens != null) {
                    request.bearerAuth(tokens.accessToken)
                }
            }
        })
        install(Logging) {
            level = LogLevel.HEADERS
            logger = Logger.DEFAULT
        }
        defaultRequest {
            url(BuildConfig.API_BASE_URL)
            contentType(ContentType.Application.Json)
        }
        expectSuccess = true
        engine {
            config {
                connectTimeout(30, TimeUnit.SECONDS)
                readTimeout(30, TimeUnit.SECONDS)
                writeTimeout(30, TimeUnit.SECONDS)
            }
        }
    }
}
