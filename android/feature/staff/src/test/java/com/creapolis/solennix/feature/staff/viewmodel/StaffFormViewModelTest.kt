package com.creapolis.solennix.feature.staff.viewmodel

import androidx.lifecycle.SavedStateHandle
import com.creapolis.solennix.core.data.repository.StaffRepository
import com.creapolis.solennix.core.model.Staff
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
class StaffFormViewModelTest {

    private val dispatcher = StandardTestDispatcher()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(dispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `save creates staff when form is valid`() = runTest {
        val repository = mockk<StaffRepository>()
        coEvery { repository.createStaff(any()) } answers { firstArg() }

        val viewModel = StaffFormViewModel(repository, SavedStateHandle())
        viewModel.name = "  Ana Ruiz  "
        viewModel.roleLabel = "  Coordinación  "
        viewModel.phone = ""
        viewModel.email = ""
        viewModel.notes = "  Equipo base  "

        viewModel.saveStaff()
        advanceUntilIdle()

        coVerify(exactly = 1) {
            repository.createStaff(
                match {
                    it.name == "Ana Ruiz" &&
                        it.roleLabel == "Coordinación" &&
                        it.phone == null &&
                        it.email == null &&
                        it.notes == "Equipo base"
                }
            )
        }
        assertTrue(viewModel.saveSuccess)
        assertFalse(viewModel.isSaving)
    }

    @Test
    fun `edit mode loads existing staff and updates`() = runTest {
        val repository = mockk<StaffRepository>()
        coEvery { repository.getStaffMember("s1") } returns Staff(
            id = "s1",
            name = "Ana",
            roleLabel = "Coordinación",
            email = "ana@example.com",
            notificationEmailOptIn = true
        )
        coEvery { repository.updateStaff(any()) } answers { firstArg() }

        val viewModel = StaffFormViewModel(repository, SavedStateHandle(mapOf("staffId" to "s1")))
        advanceUntilIdle()

        assertTrue(viewModel.isEditMode)
        assertEquals("Ana", viewModel.name)
        assertEquals("Coordinación", viewModel.roleLabel)
        assertEquals("ana@example.com", viewModel.email)

        viewModel.name = "Ana Ruiz"
        viewModel.email = ""
        viewModel.saveStaff()
        advanceUntilIdle()

        coVerify(exactly = 1) {
            repository.updateStaff(
                match {
                    it.id == "s1" && it.name == "Ana Ruiz" && it.email == null
                }
            )
        }
        assertTrue(viewModel.saveSuccess)
    }
}
