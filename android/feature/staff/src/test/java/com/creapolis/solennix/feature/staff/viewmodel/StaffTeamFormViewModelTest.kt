package com.creapolis.solennix.feature.staff.viewmodel

import androidx.lifecycle.SavedStateHandle
import com.creapolis.solennix.core.data.repository.StaffRepository
import com.creapolis.solennix.core.data.repository.StaffTeamRepository
import com.creapolis.solennix.core.model.StaffTeam
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
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
class StaffTeamFormViewModelTest {

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
    fun `save creates team and clears removed members`() = runTest {
        val teamRepository = mockk<StaffTeamRepository>()
        val staffRepository = mockk<StaffRepository>()
        coEvery { teamRepository.createTeam(any()) } answers { firstArg() }
        coEvery { staffRepository.getStaff() } returns MutableStateFlow(emptyList())
        coEvery { staffRepository.syncStaff() } returns Unit

        val viewModel = StaffTeamFormViewModel(teamRepository, staffRepository, SavedStateHandle())
        viewModel.name = "  Producción  "
        viewModel.roleLabel = "  Backstage y coordinación  "
        viewModel.notes = "  Equipo base  "
        viewModel.addMember(com.creapolis.solennix.core.model.Staff(id = "s1", name = "Ana"))
        viewModel.addMember(com.creapolis.solennix.core.model.Staff(id = "s2", name = "Luis"))

        viewModel.saveTeam()
        advanceUntilIdle()

        coVerify(exactly = 1) {
            teamRepository.createTeam(
                match {
                    it.name == "Producción" &&
                        it.roleLabel == "Backstage y coordinación" &&
                        it.notes == "Equipo base" &&
                        it.members?.map { member -> member.staffId } == listOf("s1", "s2")
                }
            )
        }
        assertTrue(viewModel.saveSuccess)
        assertFalse(viewModel.isSaving)
    }

    @Test
    fun `edit mode loads team and updates members`() = runTest {
        val teamRepository = mockk<StaffTeamRepository>()
        val staffRepository = mockk<StaffRepository>()
        coEvery { staffRepository.getStaff() } returns MutableStateFlow(emptyList())
        coEvery { staffRepository.syncStaff() } returns Unit
        coEvery { teamRepository.getTeam("t1") } returns StaffTeam(
            id = "t1",
            name = "Operaciones",
            roleLabel = "Equipo operativo",
            notes = "Coordina eventos",
            memberCount = 2,
            members = listOf(
                com.creapolis.solennix.core.model.StaffTeamMember(staffId = "s1", staffName = "Ana", isLead = false, position = 0),
                com.creapolis.solennix.core.model.StaffTeamMember(staffId = "s3", staffName = "Luis", isLead = true, position = 1)
            )
        )
        coEvery { teamRepository.updateTeam(any()) } answers { firstArg() }

        val viewModel = StaffTeamFormViewModel(teamRepository, staffRepository, SavedStateHandle(mapOf("teamId" to "t1")))
        advanceUntilIdle()

        assertTrue(viewModel.isEditMode)
        assertEquals("Operaciones", viewModel.name)
        assertEquals(2, viewModel.members.size)

        viewModel.toggleLead("s1")
        viewModel.saveTeam()
        advanceUntilIdle()

        coVerify(exactly = 1) {
            teamRepository.updateTeam(
                match {
                    it.id == "t1" &&
                        it.members?.firstOrNull { member -> member.staffId == "s1" }?.isLead == true
                }
            )
        }
        assertTrue(viewModel.saveSuccess)
    }
}
