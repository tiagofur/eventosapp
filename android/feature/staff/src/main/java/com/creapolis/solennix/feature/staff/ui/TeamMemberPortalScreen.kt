package com.creapolis.solennix.feature.staff.ui

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ChevronLeft
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.CalendarMonth
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.AssistChip
import androidx.compose.material3.AssistChipDefaults
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Tab
import androidx.compose.material3.TabRow
import androidx.compose.material3.Text
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableLongStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import com.creapolis.solennix.core.designsystem.component.SolennixTopAppBar
import com.creapolis.solennix.core.designsystem.theme.SolennixTheme
import com.creapolis.solennix.core.model.AssignmentPortalResponse
import com.creapolis.solennix.core.model.AssignmentStatus
import com.creapolis.solennix.core.model.TeamMemberAssignment
import com.creapolis.solennix.core.network.AuthManager
import com.creapolis.solennix.feature.staff.viewmodel.TeamMemberPortalViewModel
import kotlinx.coroutines.launch
import java.text.NumberFormat
import java.time.DayOfWeek
import java.time.LocalDate
import java.time.YearMonth
import java.time.format.TextStyle
import java.time.temporal.WeekFields
import java.util.Locale

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TeamMemberPortalScreen(
    viewModel: TeamMemberPortalViewModel,
    authManager: AuthManager
) {
    val uiState = viewModel.uiState.collectAsStateWithLifecycle().value
    val snackbarHostState = remember { SnackbarHostState() }
    val coroutineScope = rememberCoroutineScope()
    var selectedTab by remember { mutableIntStateOf(0) }
    var selectedDate by remember { androidx.compose.runtime.mutableStateOf(LocalDate.now()) }
    var displayedMonth by remember { androidx.compose.runtime.mutableStateOf(YearMonth.now()) }

    val pendingAssignments = remember(uiState.assignments) {
        uiState.assignments.filter { AssignmentStatus.fromString(it.status) == AssignmentStatus.PENDING }
    }

    val selectedDayAssignments = remember(uiState.assignments, selectedDate) {
        uiState.assignments.filter { assignment ->
            assignment.eventDate.toLocalDateOrNull() == selectedDate
        }
    }

    LaunchedEffect(selectedDate) {
        if (YearMonth.from(selectedDate) != displayedMonth) {
            displayedMonth = YearMonth.from(selectedDate)
        }
    }

    LaunchedEffect(uiState.errorMessage) {
        uiState.errorMessage?.let {
            snackbarHostState.showSnackbar(it)
            viewModel.clearError()
        }
    }

    Scaffold(
        topBar = {
            SolennixTopAppBar(
                title = { Text("Mi jornada") },
                actions = {
                    IconButton(onClick = { viewModel.refresh() }) {
                        Icon(Icons.Default.Refresh, contentDescription = "Recargar")
                    }
                },
                navigationIcon = {
                    IconButton(onClick = {
                        coroutineScope.launch {
                            authManager.logout()
                        }
                    }) {
                        Icon(Icons.Default.Close, contentDescription = "Salir")
                    }
                }
            )
        },
        snackbarHost = { SnackbarHost(snackbarHostState) }
    ) { padding ->
        PullToRefreshBox(
            isRefreshing = uiState.isRefreshing,
            onRefresh = { viewModel.refresh() },
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
        ) {
            when {
                uiState.isLoading && uiState.assignments.isEmpty() -> {
                    Box(Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator(color = SolennixTheme.colors.primary)
                    }
                }

                uiState.assignments.isEmpty() -> {
                    Box(Modifier.fillMaxSize().padding(24.dp), contentAlignment = Alignment.Center) {
                        Column(horizontalAlignment = Alignment.CenterHorizontally) {
                            Icon(
                                Icons.Default.CalendarMonth,
                                contentDescription = null,
                                tint = SolennixTheme.colors.secondaryText
                            )
                            Spacer(modifier = Modifier.height(12.dp))
                            Text(
                                "Todavia no tenes asignaciones",
                                style = MaterialTheme.typography.titleMedium,
                                color = SolennixTheme.colors.primaryText
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Text(
                                "Cuando te asignen a un evento, va a aparecer aca.",
                                style = MaterialTheme.typography.bodyMedium,
                                color = SolennixTheme.colors.secondaryText
                            )
                        }
                    }
                }

                else -> {
                    LazyColumn(
                        contentPadding = PaddingValues(16.dp),
                        verticalArrangement = Arrangement.spacedBy(12.dp)
                    ) {
                        item {
                            TabRow(selectedTabIndex = selectedTab) {
                                Tab(selected = selectedTab == 0, onClick = { selectedTab = 0 }, text = { Text("Mi jornada") })
                                Tab(selected = selectedTab == 1, onClick = { selectedTab = 1 }, text = { Text("Calendario") })
                            }
                        }

                        if (selectedTab == 0) {
                            item {
                                Text(
                                    text = "Pendientes por responder",
                                    style = MaterialTheme.typography.titleSmall,
                                    color = SolennixTheme.colors.secondaryText,
                                    fontWeight = FontWeight.SemiBold
                                )
                            }

                            if (pendingAssignments.isEmpty()) {
                                item {
                                    InfoCard("No tenes invitaciones pendientes.")
                                }
                            } else {
                                items(pendingAssignments, key = { it.eventStaffId }) { assignment ->
                                    TeamMemberAssignmentCard(
                                        assignment = assignment,
                                        isResponding = uiState.respondingAssignmentIds.contains(assignment.eventStaffId),
                                        onAccept = { viewModel.respond(assignment, AssignmentPortalResponse.ACCEPT) },
                                        onDecline = { viewModel.respond(assignment, AssignmentPortalResponse.DECLINE) }
                                    )
                                }
                            }

                            item {
                                Text(
                                    text = "Mi agenda",
                                    style = MaterialTheme.typography.titleSmall,
                                    color = SolennixTheme.colors.secondaryText,
                                    fontWeight = FontWeight.SemiBold,
                                    modifier = Modifier.padding(top = 4.dp)
                                )
                            }

                            items(uiState.assignments, key = { it.eventStaffId }) { assignment ->
                                TeamMemberAssignmentCard(
                                    assignment = assignment,
                                    isResponding = uiState.respondingAssignmentIds.contains(assignment.eventStaffId),
                                    onAccept = { viewModel.respond(assignment, AssignmentPortalResponse.ACCEPT) },
                                    onDecline = { viewModel.respond(assignment, AssignmentPortalResponse.DECLINE) }
                                )
                            }
                        } else {
                            item {
                                TeamMemberPortalCalendar(
                                    assignments = uiState.assignments,
                                    selectedDate = selectedDate,
                                    displayedMonth = displayedMonth,
                                    onSelectDate = { selectedDate = it },
                                    onMonthChange = { displayedMonth = it }
                                )
                            }

                            item {
                                Text(
                                    text = "Eventos del dia",
                                    style = MaterialTheme.typography.titleSmall,
                                    color = SolennixTheme.colors.secondaryText,
                                    fontWeight = FontWeight.SemiBold
                                )
                            }

                            if (selectedDayAssignments.isEmpty()) {
                                item {
                                    InfoCard("No hay asignaciones para esta fecha.")
                                }
                            } else {
                                items(selectedDayAssignments, key = { it.eventStaffId }) { assignment ->
                                    TeamMemberAssignmentCard(
                                        assignment = assignment,
                                        isResponding = uiState.respondingAssignmentIds.contains(assignment.eventStaffId),
                                        onAccept = { viewModel.respond(assignment, AssignmentPortalResponse.ACCEPT) },
                                        onDecline = { viewModel.respond(assignment, AssignmentPortalResponse.DECLINE) }
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
private fun InfoCard(message: String) {
    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
    ) {
        Text(
            text = message,
            color = SolennixTheme.colors.secondaryText,
            style = MaterialTheme.typography.bodyMedium,
            modifier = Modifier.padding(16.dp)
        )
    }
}

private fun String.toLocalDateOrNull(): LocalDate? {
    return runCatching { LocalDate.parse(this) }.getOrNull()
}

@Composable
private fun TeamMemberPortalCalendar(
    assignments: List<TeamMemberAssignment>,
    selectedDate: LocalDate,
    displayedMonth: YearMonth,
    onSelectDate: (LocalDate) -> Unit,
    onMonthChange: (YearMonth) -> Unit
) {
    val locale = Locale.forLanguageTag("es-MX")
    val firstDayOfWeek = WeekFields.of(locale).firstDayOfWeek
    val monthDays = remember(displayedMonth, firstDayOfWeek) {
        buildMonthDays(displayedMonth, firstDayOfWeek)
    }
    val statusDotsByDate = remember(assignments) {
        assignments
            .mapNotNull { assignment -> assignment.eventDate.toLocalDateOrNull()?.let { it to AssignmentStatus.fromString(assignment.status) } }
            .groupBy({ it.first }, { it.second })
            .mapValues { (_, statuses) ->
                val ordered = listOf(AssignmentStatus.PENDING, AssignmentStatus.CONFIRMED, AssignmentStatus.DECLINED, AssignmentStatus.CANCELLED)
                    .filter { statuses.contains(it) }
                ordered.take(3)
            }
    }
    val weekdayHeaders = remember(firstDayOfWeek, locale) {
        (0..6).map { index ->
            firstDayOfWeek.plus(index.toLong()).getDisplayName(TextStyle.NARROW_STANDALONE, locale)
        }
    }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
    ) {
        Column(modifier = Modifier.padding(12.dp)) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                IconButton(onClick = { onMonthChange(displayedMonth.minusMonths(1)) }) {
                    Icon(Icons.Default.ChevronLeft, contentDescription = "Mes anterior")
                }

                Text(
                    text = displayedMonth.month.getDisplayName(TextStyle.FULL, locale).replaceFirstChar { it.uppercase() } + " ${displayedMonth.year}",
                    style = MaterialTheme.typography.titleSmall,
                    color = SolennixTheme.colors.primaryText,
                    modifier = Modifier.weight(1f)
                )

                AssistChip(
                    onClick = {
                        val today = LocalDate.now()
                        onMonthChange(YearMonth.from(today))
                        onSelectDate(today)
                    },
                    label = { Text("Hoy") },
                    colors = AssistChipDefaults.assistChipColors(
                        containerColor = SolennixTheme.colors.surface,
                        labelColor = SolennixTheme.colors.secondaryText
                    )
                )

                IconButton(onClick = { onMonthChange(displayedMonth.plusMonths(1)) }) {
                    Icon(Icons.Default.ChevronRight, contentDescription = "Mes siguiente")
                }
            }

            Row(modifier = Modifier.fillMaxWidth()) {
                weekdayHeaders.forEach { header ->
                    Text(
                        text = header,
                        style = MaterialTheme.typography.labelSmall,
                        color = SolennixTheme.colors.secondaryText,
                        fontWeight = FontWeight.SemiBold,
                        modifier = Modifier.weight(1f),
                        maxLines = 1
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            LazyVerticalGrid(
                columns = GridCells.Fixed(7),
                userScrollEnabled = false,
                horizontalArrangement = Arrangement.spacedBy(6.dp),
                verticalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.fillMaxWidth()
            ) {
                items(monthDays) { day ->
                    if (day == null) {
                        Spacer(modifier = Modifier.height(44.dp))
                    } else {
                        TeamPortalDayCell(
                            date = day,
                            isSelected = day == selectedDate,
                            isToday = day == LocalDate.now(),
                            isCurrentMonth = YearMonth.from(day) == displayedMonth,
                            dots = statusDotsByDate[day].orEmpty(),
                            onClick = { onSelectDate(day) }
                        )
                    }
                }
            }
        }
    }
}

@Composable
private fun TeamPortalDayCell(
    date: LocalDate,
    isSelected: Boolean,
    isToday: Boolean,
    isCurrentMonth: Boolean,
    dots: List<AssignmentStatus>,
    onClick: () -> Unit
) {
    val dayTextColor = when {
        isSelected -> Color.White
        !isCurrentMonth -> SolennixTheme.colors.secondaryText
        isToday -> SolennixTheme.colors.primary
        else -> SolennixTheme.colors.primaryText
    }

    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier
            .fillMaxWidth()
            .height(44.dp)
            .clip(RoundedCornerShape(8.dp))
            .clickable(onClick = onClick)
            .padding(vertical = 2.dp)
            .background(Color.Transparent)
    ) {
        Box(
            modifier = Modifier
                .clip(CircleShape)
                .background(if (isSelected) SolennixTheme.colors.primary else Color.Transparent)
                .then(
                    if (!isSelected && isToday) Modifier.border(BorderStroke(1.5.dp, SolennixTheme.colors.primary), CircleShape)
                    else Modifier
                )
                .height(28.dp)
                .width(28.dp),
            contentAlignment = Alignment.Center
        ) {
            Text(
                text = date.dayOfMonth.toString(),
                style = MaterialTheme.typography.bodySmall,
                fontWeight = if (isSelected || isToday) FontWeight.SemiBold else FontWeight.Normal,
                color = dayTextColor
            )
        }

        Row(horizontalArrangement = Arrangement.spacedBy(3.dp), modifier = Modifier.height(8.dp)) {
            dots.forEach { status ->
                Box(
                    modifier = Modifier
                        .width(5.dp)
                        .height(5.dp)
                        .clip(CircleShape)
                        .background(dotColorForStatus(status))
                )
            }
        }
    }
}

@Composable
private fun dotColorForStatus(status: AssignmentStatus): Color {
    return when (status) {
        AssignmentStatus.PENDING -> SolennixTheme.colors.warning
        AssignmentStatus.CONFIRMED -> SolennixTheme.colors.success
        AssignmentStatus.DECLINED -> SolennixTheme.colors.error
        AssignmentStatus.CANCELLED -> SolennixTheme.colors.secondaryText
    }
}

private fun buildMonthDays(month: YearMonth, firstDayOfWeek: DayOfWeek): List<LocalDate?> {
    val first = month.atDay(1)
    val offset = (first.dayOfWeek.value - firstDayOfWeek.value + 7) % 7
    val days = mutableListOf<LocalDate?>()
    repeat(offset) { days += null }
    repeat(month.lengthOfMonth()) { dayIndex -> days += month.atDay(dayIndex + 1) }
    while (days.size % 7 != 0) {
        days += null
    }
    return days
}

@Composable
private fun TeamMemberAssignmentCard(
    assignment: TeamMemberAssignment,
    isResponding: Boolean,
    onAccept: () -> Unit,
    onDecline: () -> Unit
) {
    val status = AssignmentStatus.fromString(assignment.status)
    val isPending = status == AssignmentStatus.PENDING
    val moneyFormatter = remember { NumberFormat.getCurrencyInstance(Locale.forLanguageTag("es-MX")) }

    Card(
        modifier = Modifier.fillMaxWidth(),
        colors = CardDefaults.cardColors(containerColor = SolennixTheme.colors.card)
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(
                text = assignment.eventName,
                style = MaterialTheme.typography.titleMedium,
                color = SolennixTheme.colors.primaryText,
                fontWeight = FontWeight.SemiBold
            )
            Spacer(modifier = Modifier.height(4.dp))
            Text(
                text = assignment.eventDate,
                style = MaterialTheme.typography.bodySmall,
                color = SolennixTheme.colors.secondaryText
            )

            if (!assignment.roleOverride.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = "Rol: ${assignment.roleOverride}",
                    style = MaterialTheme.typography.bodySmall,
                    color = SolennixTheme.colors.secondaryText
                )
            }

            if (assignment.feeAmount != null) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = "Pago: ${moneyFormatter.format(assignment.feeAmount)}",
                    style = MaterialTheme.typography.bodySmall,
                    color = SolennixTheme.colors.primary
                )
            }

            if (!assignment.notes.isNullOrBlank()) {
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = assignment.notes.orEmpty(),
                    style = MaterialTheme.typography.bodySmall,
                    color = SolennixTheme.colors.secondaryText
                )
            }

            Spacer(modifier = Modifier.height(12.dp))

            if (isPending) {
                androidx.compose.foundation.layout.Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    OutlinedButton(
                        onClick = onDecline,
                        enabled = !isResponding,
                        modifier = Modifier.weight(1f)
                    ) {
                        Icon(Icons.Default.Close, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Rechazar")
                    }
                    Button(
                        onClick = onAccept,
                        enabled = !isResponding,
                        modifier = Modifier.weight(1f)
                    ) {
                        Icon(Icons.Default.Check, contentDescription = null)
                        Spacer(modifier = Modifier.width(8.dp))
                        Text("Aceptar")
                    }
                }
            } else {
                Text(
                    text = when (status) {
                        AssignmentStatus.CONFIRMED -> "Confirmada"
                        AssignmentStatus.DECLINED -> "Rechazada"
                        AssignmentStatus.CANCELLED -> "Cancelada"
                        AssignmentStatus.PENDING -> "Pendiente"
                    },
                    style = MaterialTheme.typography.bodySmall,
                    color = SolennixTheme.colors.secondaryText
                )
            }
        }
    }
}