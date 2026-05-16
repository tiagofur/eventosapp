package com.creapolis.solennix.feature.payments.viewmodel

import com.creapolis.solennix.core.model.PaymentSubmission
import com.creapolis.solennix.core.network.ApiService
import com.creapolis.solennix.core.network.get
import com.creapolis.solennix.core.network.patch
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertFalse
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class PaymentInboxViewModelTest {

    private val dispatcher = StandardTestDispatcher()
    private val apiService = mockk<ApiService>()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `loads submissions on init`() = runTest {
        val submission = pendingSubmission(id = "ps1")
        coEvery {
            apiService.get<Map<String, List<PaymentSubmission>>>("payment-submissions")
        } returns mapOf("data" to listOf(submission))

        val viewModel = PaymentInboxViewModel(apiService)

        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertFalse(state.isRefreshing)
        assertFalse(state.isPlanLocked)
        assertEquals(listOf(submission), state.submissions)
        assertEquals(null, state.error)
        coVerify(exactly = 1) {
            apiService.get<Map<String, List<PaymentSubmission>>>("payment-submissions")
        }
    }

    @Test
    fun `pro only error locks the inbox and hides generic error`() = runTest {
        coEvery {
            apiService.get<Map<String, List<PaymentSubmission>>>("payment-submissions")
        } throws IllegalStateException("pro-exclusive content")

        val viewModel = PaymentInboxViewModel(apiService)

        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertTrue(state.isPlanLocked)
        assertEquals(null, state.error)
    }

    @Test
    fun `approve failure surfaces action error`() = runTest {
        val submission = pendingSubmission(id = "ps1")
        coEvery {
            apiService.get<Map<String, List<PaymentSubmission>>>("payment-submissions")
        } returns mapOf("data" to listOf(submission))
        coEvery {
            apiService.patch<Map<String, PaymentSubmission>>("payment-submissions/ps1", any())
        } throws IllegalStateException("boom")

        val viewModel = PaymentInboxViewModel(apiService)
        advanceUntilIdle()

        viewModel.approveSubmission("ps1")
        advanceUntilIdle()

        val state = viewModel.uiState.value
        assertFalse(state.isLoading)
        assertEquals("boom", state.actionError)
        coVerify(exactly = 1) {
            apiService.patch<Map<String, PaymentSubmission>>("payment-submissions/ps1", any())
        }
    }

    private fun pendingSubmission(id: String) = PaymentSubmission(
        id = id,
        eventId = "event-1",
        clientId = "client-1",
        userId = "user-1",
        amount = 1250.0,
        transferRef = "TRX-123",
        receiptFileUrl = null,
        status = "pending",
        submittedAt = "2026-05-13T12:00:00Z",
        reviewedAt = null,
        rejectionReason = null,
        linkedPaymentId = null,
        clientName = "Ana",
        eventLabel = "Boda"
    )
}