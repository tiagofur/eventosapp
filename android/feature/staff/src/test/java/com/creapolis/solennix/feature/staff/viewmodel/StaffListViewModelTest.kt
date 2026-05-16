package com.creapolis.solennix.feature.staff.viewmodel

import com.creapolis.solennix.core.data.repository.StaffRepository
import com.creapolis.solennix.core.model.Staff
import io.mockk.coEvery
import io.mockk.mockk
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
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
class StaffListViewModelTest {

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
    fun `search and sort update visible staff`() = runTest {
        val staffFlow = MutableStateFlow(
            listOf(
                Staff(id = "s1", name = "Ana", roleLabel = "Diseño"),
                Staff(id = "s2", name = "Luis", roleLabel = "Logística"),
                Staff(id = "s3", name = "Daniel", roleLabel = "Diseño")
            )
        )
        val repository = mockk<StaffRepository>()
        coEvery { repository.syncStaff() } returns Unit
        coEvery { repository.getStaff() } returns staffFlow

        val viewModel = StaffListViewModel(repository)
        val collector = backgroundScope.launch { viewModel.uiState.collect { } }
        advanceUntilIdle()

        viewModel.onSearchQueryChange("di")
        advanceUntilIdle()
        assertEquals(listOf("Ana", "Daniel"), viewModel.uiState.value.staff.map { it.name })

        viewModel.onSortOptionChange(StaffSortOption.NAME_DESC)
        advanceUntilIdle()
        assertEquals(listOf("Daniel", "Ana"), viewModel.uiState.value.staff.map { it.name })

        collector.cancel()
    }

    @Test
    fun `refresh keeps cache when sync fails`() = runTest {
        val staffFlow = MutableStateFlow(listOf(Staff(id = "s1", name = "Ana")))
        val repository = mockk<StaffRepository>()
        coEvery { repository.getStaff() } returns staffFlow
        coEvery { repository.syncStaff() } throws IllegalStateException("boom")

        val viewModel = StaffListViewModel(repository)
        val collector = backgroundScope.launch { viewModel.uiState.collect { } }
        advanceUntilIdle()

        assertEquals(listOf("Ana"), viewModel.uiState.value.staff.map { it.name })
        collector.cancel()
    }
}
