package com.creapolis.solennix.core.network

import io.ktor.client.call.*
import io.ktor.client.request.*
import io.ktor.client.request.forms.*
import io.ktor.http.*
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ApiService @Inject constructor(
    @PublishedApi internal val client: KtorClient
) {
    suspend inline fun <reified T> get(
        endpoint: String,
        params: Map<String, String> = emptyMap()
    ): T = client.httpClient.get(endpoint) {
        params.forEach { (key, value) -> parameter(key, value) }
    }.body()

    suspend inline fun <reified T> post(
        endpoint: String,
        body: Any
    ): T = client.httpClient.post(endpoint) {
        setBody(body)
    }.body()

    suspend inline fun <reified T> put(
        endpoint: String,
        body: Any
    ): T = client.httpClient.put(endpoint) {
        setBody(body)
    }.body()

    suspend fun delete(endpoint: String) {
        client.httpClient.delete(endpoint)
    }

    suspend fun upload(
        endpoint: String,
        fileBytes: ByteArray,
        fileName: String,
        mimeType: String
    ): String = client.httpClient.post(endpoint) {
        setBody(MultiPartFormDataContent(formData {
            append("file", fileBytes, Headers.build {
                append(HttpHeaders.ContentDisposition, "filename=\"$fileName\"")
                append(HttpHeaders.ContentType, mimeType)
            })
        }))
    }.body()
}
