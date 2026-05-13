package com.creapolis.solennix.feature.staff.viewmodel

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
import org.junit.jupiter.api.BeforeEach
import org.junit.jupiter.api.Test

@OptIn(ExperimentalCoroutinesApi::class)
class StaffTeamListViewModelTest {

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
    fun `refresh sorts teams alphabetically`() = runTest {
        val repository = mockk<StaffTeamRepository>()
        coEvery { repository.listTeams() } returns listOf(
            StaffTeam(id = "t1", name = "Bodas", memberCount = 4),
            StaffTeam(id = "t2", name = "Eventos", memberCount = 2),
            StaffTeam(id = "t3", name = "Decoración", memberCount = 6)
        )

        val viewModel = StaffTeamListViewModel(repository)
        val collector = backgroundScope.launch { viewModel.uiState.collect { } }
        advanceUntilIdle()

        assertEquals(listOf("Bodas", "Decoración", "Eventos"), viewModel.uiState.value.teams.map { it.name })

        collector.cancel()
    }

    @Test
    fun `delete team removes it from repository`() = runTest {
        val repository = mockk<StaffTeamRepository>()
        coEvery { repository.listTeams() } returns listOf(StaffTeam(id = "t1", name = "Bodas", memberCount = 4))
        coEvery { repository.deleteTeam("t1") } returns Unit

        val viewModel = StaffTeamListViewModel(repository)
        val collector = backgroundScope.launch { viewModel.uiState.collect { } }
        advanceUntilIdle()

        viewModel.deleteTeam("t1")
        advanceUntilIdle()

        coVerify(exactly = 1) { repository.deleteTeam("t1") }
        collector.cancel()
    }
}
