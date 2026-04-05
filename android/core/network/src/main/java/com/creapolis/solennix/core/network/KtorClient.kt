package com.creapolis.solennix.core.network

import io.ktor.client.*
import io.ktor.client.engine.okhttp.*
import io.ktor.client.plugins.*
import io.ktor.client.plugins.auth.*
import io.ktor.client.plugins.auth.providers.*
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
        
        install(HttpRequestRetry) {
            maxRetries = 3
            retryIf { _, response ->
                !response.status.isSuccess() && response.status.value >= 500
            }
            retryOnExceptionIf { _, cause ->
                cause is java.net.ConnectException || cause is java.net.SocketTimeoutException
            }
            exponentialDelay()
        }

        // Ktor's built-in Auth plugin handles:
        // 1. loadTokens: reads fresh tokens from EncryptedSharedPreferences
        // 2. refreshTokens: on 401, checks if tokens changed (e.g. after login)
        //    before calling the backend refresh endpoint
        // 3. On refresh failure: clears tokens → state becomes Unauthenticated
        install(Auth) {
            bearer {
                loadTokens {
                    authManager.getBearerTokens()
                }
                refreshTokens {
                    // Check if tokens changed since loadTokens cached them
                    // (e.g., user just logged in). If so, use the new tokens
                    // directly without hitting the refresh endpoint.
                    val freshTokens = authManager.getBearerTokens()
                    if (freshTokens != null && freshTokens.accessToken != oldTokens?.accessToken) {
                        freshTokens
                    } else {
                        authManager.refreshAndGetTokens()
                    }
                }
                // Send tokens on every request without waiting for a 401 first
                sendWithoutRequest { true }
            }
        }
        install(Logging) {
            level = LogLevel.HEADERS
            logger = Logger.DEFAULT
        }
        defaultRequest {
            url(BuildConfig.API_BASE_URL)
            contentType(ContentType.Application.Json)
        }
        // Allow 401 responses to reach the Auth plugin for token refresh
        // instead of throwing immediately. Non-401 errors still throw.
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
