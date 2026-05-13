package com.creapolis.solennix.core.database.converter

import kotlinx.serialization.SerializationException
import kotlinx.serialization.json.JsonPrimitive
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Assertions.assertThrows
import org.junit.jupiter.api.Test

class JsonConvertersTest {

    private val converters = JsonConverters()

    @Test
    fun `stringToJsonElement returns null for null input`() {
        assertNull(converters.stringToJsonElement(null))
    }

    @Test
    fun `jsonElementToString returns null for null input`() {
        assertNull(converters.jsonElementToString(null))
    }

    @Test
    fun `converters preserve JSON content in roundtrip`() {
        val input = "{\"name\":\"Solennix\",\"active\":true}"

        val element = converters.stringToJsonElement(input)
        val output = converters.jsonElementToString(element)

        assertEquals(input, output)
    }

    @Test
    fun `jsonElementToString serializes primitive values`() {
        val output = converters.jsonElementToString(JsonPrimitive("hola"))

        assertEquals("\"hola\"", output)
    }

    @Test
    fun `stringToJsonElement throws for malformed JSON`() {
        assertThrows(SerializationException::class.java) {
            converters.stringToJsonElement("{invalid-json")
        }
    }
}