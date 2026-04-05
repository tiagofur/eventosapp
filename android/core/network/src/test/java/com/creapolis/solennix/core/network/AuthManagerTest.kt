package com.creapolis.solennix.core.network

import android.content.Context
import android.content.SharedPreferences
import androidx.biometric.BiometricManager
import app.cash.turbine.test
import io.mockk.every
import io.mockk.mockk
import io.mockk.mockkStatic
import io.mockk.unmockkAll
import kotlinx.coroutines.test.runTest
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

class AuthManagerTest {

    private lateinit var authManager: AuthManager
    private val mockPrefs = mockk<SharedPreferences>(relaxed = true)
    private val mockContext = mockk<Context>(relaxed = true)
    private val mockEditor = mockk<SharedPreferences.Editor>(relaxed = true)

    @BeforeEach
    fun setUp() {
        every { mockPrefs.edit() } returns mockEditor
        every { mockEditor.putString(any(), any()) } returns mockEditor
        every { mockEditor.remove(any()) } returns mockEditor
        every { mockEditor.putBoolean(any(), any()) } returns mockEditor
        
        authManager = AuthManager(mockPrefs, mockContext)
    }

    @AfterEach
    fun tearDown() {
        unmockkAll()
    }

    @Test
    fun `initial state is Unknown`() = runTest {
        assertEquals(AuthManager.AuthState.Unknown, authManager.authState.value)
    }

    @Test
    fun `restoreSession with no tokens sets state to Unauthenticated`() = runTest {
        every { mockPrefs.getString("access_token", null) } returns null
        every { mockPrefs.getString("refresh_token", null) } returns null

        authManager.restoreSession()

        assertEquals(AuthManager.AuthState.Unauthenticated, authManager.authState.value)
    }

    @Test
    fun `restoreSession with tokens sets state to Authenticated`() = runTest {
        every { mockPrefs.getString("access_token", null) } returns "valid_access"
        every { mockPrefs.getString("refresh_token", null) } returns "valid_refresh"
        every { mockPrefs.getBoolean("biometric_enabled", false) } returns false

        authManager.restoreSession()

        assertEquals(AuthManager.AuthState.Authenticated, authManager.authState.value)
    }

    @Test
    fun `restoreSession with tokens and biometric enabled sets state to BiometricLocked`() = runTest {
        // Mock static BiometricManager.from(context)
        mockkStatic(BiometricManager::class)
        val mockBioManager = mockk<BiometricManager>()
        every { BiometricManager.from(any()) } returns mockBioManager
        every { mockBioManager.canAuthenticate(any()) } returns BiometricManager.BIOMETRIC_SUCCESS

        every { mockPrefs.getString("access_token", null) } returns "valid_access"
        every { mockPrefs.getString("refresh_token", null) } returns "valid_refresh"
        every { mockPrefs.getBoolean("biometric_enabled", false) } returns true

        authManager.restoreSession()

        assertEquals(AuthManager.AuthState.BiometricLocked, authManager.authState.value)
    }

    @Test
    fun `storeTokens updates state to Authenticated`() = runTest {
        authManager.storeTokens("new_access", "new_refresh")

        assertEquals(AuthManager.AuthState.Authenticated, authManager.authState.value)
    }

    @Test
    fun `clearTokens updates state to Unauthenticated`() = runTest {
        authManager.clearTokens()

        assertEquals(AuthManager.AuthState.Unauthenticated, authManager.authState.value)
    }
}
