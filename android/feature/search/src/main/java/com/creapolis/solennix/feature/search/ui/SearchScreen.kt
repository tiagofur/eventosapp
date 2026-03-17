package com.creapolis.solennix.feature.search.ui

import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.feature.clients.ui.ClientListItem
import com.creapolis.solennix.feature.dashboard.ui.EventListItem
import com.creapolis.solennix.feature.search.viewmodel.SearchViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SearchScreen(
    viewModel: SearchViewModel,
    onClientClick: (String) -> Unit,
    onEventClick: (String) -> Unit
) {
    val uiState by viewModel.uiState.collectAsStateWithLifecycle()

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Buscar") }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            OutlinedTextField(
                value = uiState.query,
                onValueChange = { viewModel.onQueryChange(it) },
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                placeholder = { Text("Buscar eventos o clientes...") },
                leadingIcon = { Icon(Icons.Default.Search, contentDescription = null) },
                shape = MaterialTheme.shapes.medium,
                singleLine = true
            )

            LazyColumn(modifier = Modifier.fillMaxSize()) {
                if (uiState.clients.isNotEmpty()) {
                    item {
                        Text(
                            text = "Clientes",
                            modifier = Modifier.padding(16.dp),
                            style = MaterialTheme.typography.titleMedium,
                            color = SolennixTheme.colors.primary
                        )
                    }
                    items(uiState.clients) { client ->
                        ClientListItem(client = client, onClick = { onClientClick(client.id) })
                    }
                }

                if (uiState.events.isNotEmpty()) {
                    item {
                        Text(
                            text = "Eventos",
                            modifier = Modifier.padding(16.dp),
                            style = MaterialTheme.typography.titleMedium,
                            color = SolennixTheme.colors.primary
                        )
                    }
                    items(uiState.events) { event ->
                        Box(modifier = Modifier.padding(horizontal = 16.dp)) {
                            EventListItem(event = event)
                        }
                    }
                }

                if (uiState.query.isNotBlank() && uiState.clients.isEmpty() && uiState.events.isEmpty()) {
                    item {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = androidx.compose.ui.Alignment.Center) {
                            Text(
                                text = "No se encontraron resultados",
                                color = SolennixTheme.colors.secondaryText,
                                modifier = Modifier.padding(32.dp)
                            )
                        }
                    }
                }
            }
        }
    }
}
