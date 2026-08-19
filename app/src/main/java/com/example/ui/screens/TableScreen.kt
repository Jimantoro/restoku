package com.example.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Chair
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.ReceiptLong
import androidx.compose.material.icons.filled.TableBar
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.OrderWithItems
import com.example.data.model.TableEntity
import com.example.data.model.TableStatus
import com.example.data.repository.RestaurantRepository
import com.example.ui.theme.AmberPrimary
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.SuccessGreen
import com.example.ui.theme.WarningOrange
import com.example.ui.viewmodel.AppNavTab
import com.example.ui.viewmodel.RestaurantViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun TableScreen(
    tables: List<TableEntity>,
    orders: List<OrderWithItems>,
    viewModel: RestaurantViewModel,
    modifier: Modifier = Modifier
) {
    var selectedTableForDetail by remember { mutableStateOf<TableEntity?>(null) }
    var showAddTableDialog by remember { mutableStateOf(false) }

    val sections = tables.map { it.section }.distinct()

    Scaffold(
        modifier = modifier.fillMaxSize(),
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddTableDialog = true },
                containerColor = AmberPrimary,
                contentColor = Color.White,
                shape = RoundedCornerShape(16.dp),
                modifier = Modifier.testTag("add_table_fab")
            ) {
                Icon(imageVector = Icons.Default.Add, contentDescription = "Tambah Meja")
            }
        }
    ) { innerPadding ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // Header
            Surface(
                modifier = Modifier.fillMaxWidth(),
                color = MaterialTheme.colorScheme.surface,
                tonalElevation = 2.dp
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    Text(
                        text = "Manajemen Meja & Denah",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "Pantau status meja pelanggan secara real-time",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )

                    Spacer(modifier = Modifier.height(12.dp))

                    // Status Legend Row
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        val availableCount = tables.count { it.status == TableStatus.AVAILABLE }
                        val occupiedCount = tables.count { it.status == TableStatus.OCCUPIED }
                        val reservedCount = tables.count { it.status == TableStatus.RESERVED }

                        StatusBadge(label = "Kosong ($availableCount)", color = SuccessGreen)
                        StatusBadge(label = "Terisi ($occupiedCount)", color = ErrorRed)
                        StatusBadge(label = "Reservasi ($reservedCount)", color = WarningOrange)
                    }
                }
            }

            // Tables Grouped by Section
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 16.dp),
                contentPadding = PaddingValues(top = 16.dp, bottom = 80.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                sections.forEach { sectionName ->
                    val sectionTables = tables.filter { it.section == sectionName }

                    item {
                        Text(
                            text = "Area $sectionName (${sectionTables.size} Meja)",
                            fontSize = 15.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.height(8.dp))

                        LazyVerticalGrid(
                            columns = GridCells.Fixed(2),
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(((sectionTables.size + 1) / 2 * 125).dp),
                            userScrollEnabled = false,
                            horizontalArrangement = Arrangement.spacedBy(10.dp),
                            verticalArrangement = Arrangement.spacedBy(10.dp)
                        ) {
                            items(sectionTables, key = { it.id }) { table ->
                                val activeOrder = orders.find { it.order.id == table.activeOrderId }

                                TableCard(
                                    table = table,
                                    activeOrder = activeOrder,
                                    onClick = {
                                        if (table.status == TableStatus.AVAILABLE) {
                                            viewModel.selectTable(table)
                                            viewModel.setTab(AppNavTab.POS_CASHIER)
                                        } else {
                                            selectedTableForDetail = table
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    // Detail / Settle Sheet for Occupied Table
    selectedTableForDetail?.let { table ->
        val activeOrder = orders.find { it.order.id == table.activeOrderId }
        TableDetailSheet(
            table = table,
            activeOrder = activeOrder,
            onDismiss = { selectedTableForDetail = null },
            onSettleBill = { order ->
                selectedTableForDetail = null
                viewModel.openSettleDialog(order)
            },
            onAddMoreMenu = {
                viewModel.selectTable(table)
                viewModel.setTab(AppNavTab.POS_CASHIER)
                selectedTableForDetail = null
            },
            onChangeStatus = { newStatus ->
                viewModel.updateTableStatus(table.id, newStatus)
                selectedTableForDetail = null
            }
        )
    }

    // Add Table Dialog
    if (showAddTableDialog) {
        AddTableDialog(
            onDismiss = { showAddTableDialog = false },
            onAdd = { number, section, capacity ->
                viewModel.addTable(number, section, capacity)
                showAddTableDialog = false
            }
        )
    }
}

@Composable
private fun StatusBadge(label: String, color: Color) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Box(
            modifier = Modifier
                .size(10.dp)
                .clip(CircleShape)
                .background(color)
        )
        Spacer(modifier = Modifier.width(6.dp))
        Text(
            text = label,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onSurface
        )
    }
}

@Composable
private fun TableCard(
    table: TableEntity,
    activeOrder: OrderWithItems?,
    onClick: () -> Unit
) {
    val (statusColor, statusText) = when (table.status) {
        TableStatus.AVAILABLE -> Pair(SuccessGreen, "Kosong")
        TableStatus.OCCUPIED -> Pair(ErrorRed, "Terisi")
        TableStatus.RESERVED -> Pair(WarningOrange, "Reservasi")
        TableStatus.BILLING -> Pair(AmberPrimary, "Minta Bill")
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .testTag("table_card_${table.tableNumber}"),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp),
        border = androidx.compose.foundation.BorderStroke(1.5.dp, statusColor.copy(alpha = 0.5f))
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(12.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Text(
                    text = "Meja ${table.tableNumber}",
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = statusColor.copy(alpha = 0.15f)
                ) {
                    Text(
                        text = statusText,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = statusColor,
                        modifier = Modifier.padding(horizontal = 6.dp, vertical = 2.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Chair,
                    contentDescription = null,
                    tint = MaterialTheme.colorScheme.onSurfaceVariant,
                    modifier = Modifier.size(13.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "Kapasitas ${table.capacity} Orang",
                    fontSize = 11.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            if (table.status == TableStatus.OCCUPIED && activeOrder != null) {
                Surface(
                    shape = RoundedCornerShape(8.dp),
                    color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.5f),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(modifier = Modifier.padding(6.dp)) {
                        Text(
                            text = activeOrder.order.customerName,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.SemiBold,
                            maxLines = 1
                        )
                        Text(
                            text = RestaurantRepository.formatRupiah(activeOrder.order.grandTotal),
                            fontSize = 12.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = AmberPrimary
                        )
                    }
                }
            } else if (table.status == TableStatus.AVAILABLE) {
                Text(
                    text = "+ Pesan Menu",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    color = SuccessGreen
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun TableDetailSheet(
    table: TableEntity,
    activeOrder: OrderWithItems?,
    onDismiss: () -> Unit,
    onSettleBill: (OrderWithItems) -> Unit,
    onAddMoreMenu: () -> Unit,
    onChangeStatus: (TableStatus) -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = MaterialTheme.colorScheme.surface
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp, vertical = 16.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Detail Meja ${table.tableNumber}",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold
                    )
                    Text(
                        text = "Area ${table.section} • Kapasitas ${table.capacity} Orang",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                IconButton(onClick = onDismiss) {
                    Icon(Icons.Default.Close, contentDescription = null)
                }
            }

            HorizontalDivider(modifier = Modifier.padding(vertical = 12.dp))

            if (activeOrder != null) {
                Text(
                    text = "Pesanan Aktif: ${activeOrder.order.invoiceNumber}",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = AmberPrimary
                )
                Text(
                    text = "Pelanggan: ${activeOrder.order.customerName} • Waktu: ${RestaurantRepository.formatTimestamp(activeOrder.order.createdAt)}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(10.dp))

                // List Items
                LazyColumn(
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(160.dp)
                ) {
                    items(activeOrder.items) { item ->
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 4.dp),
                            horizontalArrangement = Arrangement.SpaceBetween
                        ) {
                            Text(
                                text = "${item.quantity}x ${item.menuName}",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Medium
                            )
                            Text(
                                text = RestaurantRepository.formatRupiah(item.subtotal),
                                fontSize = 13.sp,
                                fontWeight = FontWeight.Bold
                            )
                        }
                    }
                }

                HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text("Total Tagihan", fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    Text(
                        text = RestaurantRepository.formatRupiah(activeOrder.order.grandTotal),
                        fontSize = 18.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = AmberPrimary
                    )
                }

                Spacer(modifier = Modifier.height(16.dp))

                // Action Buttons
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    OutlinedButton(
                        onClick = onAddMoreMenu,
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp)
                    ) {
                        Text("Tambah Menu")
                    }

                    Button(
                        onClick = { onSettleBill(activeOrder) },
                        modifier = Modifier.weight(1f),
                        shape = RoundedCornerShape(12.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = AmberPrimary)
                    ) {
                        Icon(Icons.Default.Payments, contentDescription = null, modifier = Modifier.size(16.dp))
                        Spacer(modifier = Modifier.width(4.dp))
                        Text("Bayar Bill", fontWeight = FontWeight.Bold)
                    }
                }
            } else {
                Text(
                    text = "Ubah Status Meja Secara Manual:",
                    fontSize = 13.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    Button(
                        onClick = { onChangeStatus(TableStatus.AVAILABLE) },
                        colors = ButtonDefaults.buttonColors(containerColor = SuccessGreen),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Kosong")
                    }
                    Button(
                        onClick = { onChangeStatus(TableStatus.RESERVED) },
                        colors = ButtonDefaults.buttonColors(containerColor = WarningOrange),
                        shape = RoundedCornerShape(10.dp),
                        modifier = Modifier.weight(1f)
                    ) {
                        Text("Reservasi")
                    }
                }
            }
        }
    }
}

@Composable
private fun AddTableDialog(
    onDismiss: () -> Unit,
    onAdd: (String, String, Int) -> Unit
) {
    var tableNumber by remember { mutableStateOf("") }
    var section by remember { mutableStateOf("Utama") }
    var capacity by remember { mutableStateOf("4") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Tambah Meja Baru", fontWeight = FontWeight.Bold) },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = tableNumber,
                    onValueChange = { tableNumber = it },
                    label = { Text("Nomor / Nama Meja (Contoh: 11, VIP-3)") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                    value = section,
                    onValueChange = { section = it },
                    label = { Text("Area / Bagian (Utama, VIP, Outdoor)") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )
                OutlinedTextField(
                    value = capacity,
                    onValueChange = { capacity = it.filter { ch -> ch.isDigit() } },
                    label = { Text("Kapasitas Kursi (Orang)") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (tableNumber.isNotBlank()) {
                        onAdd(tableNumber.trim(), section.trim(), capacity.toIntOrNull() ?: 4)
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = AmberPrimary),
                shape = RoundedCornerShape(10.dp)
            ) {
                Text("Tambah Meja")
            }
        },
        dismissButton = {
            OutlinedButton(onClick = onDismiss, shape = RoundedCornerShape(10.dp)) {
                Text("Batal")
            }
        },
        shape = RoundedCornerShape(18.dp)
    )
}
