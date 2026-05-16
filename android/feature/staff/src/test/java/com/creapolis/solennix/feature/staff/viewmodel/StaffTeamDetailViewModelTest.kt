package com.creapolis.solennix.feature.staff.viewmodel

import androidx.lifecycle.SavedStateHandle
import com.creapolis.solennix.core.data.repository.StaffTeamRepository
import com.creapolis.solennix.core.model.StaffTeam
import io.mockk.coEvery
import io.mockk.coVerify
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.launch
import kotlinx.coroutines.test.StandardTestDispatcher
import kotlinx.coroutines.test.advanceUntilIdle
import kotlinx.coroutines.test.resetMain
import kotlinx.coroutines.test.runTest
import kotlinx.coroutines.test.setMain
import org.junit.jupiter.api.AfterEach
import org.junit.jupiter.api.Assertions.assertEquals
import org.junit.jupiter.api.Assertions.assertTrue
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class StaffTeamDetailViewModelTest {

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
    fun `load fills team state and delete marks success`() = runTest {
        val repository = mockk<StaffTeamRepository>()
        coEvery { repository.getTeam("t1") } returns StaffTeam(
            id = "t1",
            name = "Operaciones",
            roleLabel = "Equipo operativo",
            memberCount = 3,
            members = listOf(
                com.creapolis.solennix.core.model.StaffTeamMember(staffId = "s1", staffName = "Ana", position = 0),
                com.creapolis.solennix.core.model.StaffTeamMember(staffId = "s2", staffName = "Luis", position = 1),
                com.creapolis.solennix.core.model.StaffTeamMember(staffId = "s3", staffName = "Marta", position = 2)
            )
        )
        coEvery { repository.deleteTeam("t1") } returns Unit

        val viewModel = StaffTeamDetailViewModel(repository, SavedStateHandle(mapOf("teamId" to "t1")))
        val collector = backgroundScope.launch { viewModel.uiState.collect { } }
        advanceUntilIdle()

        assertEquals("Operaciones", viewModel.uiState.value.team?.name)
        viewModel.deleteTeam()
        advanceUntilIdle()

        assertTrue(viewModel.deleteSuccess)
        coVerify(exactly = 1) { repository.deleteTeam("t1") }
        collector.cancel()
    }
}
