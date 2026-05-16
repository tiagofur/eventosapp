package com.creapolis.solennix.feature.inventory.viewmodel

import com.creapolis.solennix.core.data.repository.InventoryRepository
import com.creapolis.solennix.core.model.InventoryItem
import com.creapolis.solennix.core.model.InventoryType
import io.mockk.coEvery
import io.mockk.every
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
class InventoryListViewModelTest {

    private val testDispatcher = StandardTestDispatcher()

    @BeforeEach
    fun setUp() {
        Dispatchers.setMain(testDispatcher)
    }

    @AfterEach
    fun tearDown() {
        Dispatchers.resetMain()
    }

    @Test
    fun `low stock filter keeps only below minimum items`() = runTest {
        val itemsFlow = MutableStateFlow(
            listOf(
                InventoryItem(id = "i1", ingredientName = "Harina", currentStock = 2.0, minimumStock = 5.0, unit = "kg", type = InventoryType.INGREDIENT),
                InventoryItem(id = "i2", ingredientName = "Leche", currentStock = 8.0, minimumStock = 5.0, unit = "l", type = InventoryType.INGREDIENT),
                InventoryItem(id = "i3", ingredientName = "Microfono", currentStock = 1.0, minimumStock = 2.0, unit = "u", type = InventoryType.EQUIPMENT)
            )
        )

        val inventoryRepository = mockk<InventoryRepository>()
        every { inventoryRepository.getInventoryItems() } returns itemsFlow
        coEvery { inventoryRepository.syncInventory() } returns Unit

        val vm = InventoryListViewModel(inventoryRepository)
        val collector = backgroundScope.launch { vm.uiState.collect { } }

        vm.onLowStockToggle(true)
        advanceUntilIdle()

        assertEquals(listOf("Harina"), vm.uiState.value.ingredientItems.map { it.ingredientName })
        assertEquals(listOf("Microfono"), vm.uiState.value.equipmentItems.map { it.ingredientName })

        collector.cancel()
    }

    @Test
    fun `sort by stock toggles ascending then descending`() = runTest {
        val itemsFlow = MutableStateFlow(
            listOf(
                InventoryItem(id = "i1", ingredientName = "A", currentStock = 9.0, minimumStock = 1.0, unit = "u", type = InventoryType.INGREDIENT),
                InventoryItem(id = "i2", ingredientName = "B", currentStock = 3.0, minimumStock = 1.0, unit = "u", type = InventoryType.INGREDIENT),
                InventoryItem(id = "i3", ingredientName = "C", currentStock = 6.0, minimumStock = 1.0, unit = "u", type = InventoryType.INGREDIENT)
            )
        )

        val inventoryRepository = mockk<InventoryRepository>()
        every { inventoryRepository.getInventoryItems() } returns itemsFlow
        coEvery { inventoryRepository.syncInventory() } returns Unit

        val vm = InventoryListViewModel(inventoryRepository)
        val collector = backgroundScope.launch { vm.uiState.collect { } }

        vm.onSortChange(InventorySortKey.CURRENT_STOCK)
        advanceUntilIdle()
        assertEquals(listOf(3.0, 6.0, 9.0), vm.uiState.value.ingredientItems.map { it.currentStock })

        vm.onSortChange(InventorySortKey.CURRENT_STOCK)
        advanceUntilIdle()
        assertEquals(listOf(9.0, 6.0, 3.0), vm.uiState.value.ingredientItems.map { it.currentStock })

        collector.cancel()
    }
}
