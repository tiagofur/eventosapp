package com.creapolis.solennix.widget

import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertNull
import org.junit.jupiter.api.Test

class WidgetAuthProviderTest {

    @Test
    fun `parse user id returns id when JSON is valid`() {
        val userJson = """{"id":"u-123","email":"ana@example.com"}"""

        assertEquals("u-123", WidgetAuthProvider.parseUserIdFromUserJson(userJson))
    }

    @Test
    fun `parse user id returns null for invalid or blank JSON`() {
        assertNull(WidgetAuthProvider.parseUserIdFromUserJson(null))
        assertNull(WidgetAuthProvider.parseUserIdFromUserJson(""))
        assertNull(WidgetAuthProvider.parseUserIdFromUserJson("not-json"))
        assertNull(WidgetAuthProvider.parseUserIdFromUserJson("{}"))
    }
}
