package com.creapolis.solennix.core.database.converter

import androidx.room.TypeConverter
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonElement

class JsonConverters {
    @TypeConverter
    fun stringToJsonElement(value: String?): JsonElement? {
        return value?.let { Json.parseToJsonElement(it) }
    }

    @TypeConverter
    fun jsonElementToString(element: JsonElement?): String? {
        return element?.toString()
    }
}
