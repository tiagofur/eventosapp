package com.creapolis.solennix.core.network

object UrlResolver {
    // Base URL without /api/v1/ suffix, since backend paths already include /api/v1/
    private val BASE_URL: String = BuildConfig.API_BASE_URL.removeSuffix("api/v1/").removeSuffix("/")

    fun resolve(path: String?): String? {
        if (path == null) return null
        if (path.startsWith("http://") || path.startsWith("https://") || path.startsWith("data:")) {
            return path
        }
        return "$BASE_URL$path"
    }
}
