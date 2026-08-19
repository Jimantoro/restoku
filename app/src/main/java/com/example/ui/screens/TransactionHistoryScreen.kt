package com.example.ui.screens

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
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Cancel
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.ReceiptLong
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.OrderStatus
import com.example.data.model.OrderWithItems
import com.example.data.repository.RestaurantRepository
import com.example.ui.theme.AmberPrimary
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.SuccessGreen
import com.example.ui.theme.WarningOrange
import com.example.ui.viewmodel.RestaurantViewModel

@Composable
fun TransactionHistoryScreen(
    orders: List<OrderWithItems>,
    viewModel: RestaurantViewModel,
    modifier: Modifier = Modifier
) {
    var searchQuery by remember { mutableStateOf("") }
    var selectedStatusFilter by remember { mutableStateOf<OrderStatus?>(null) }
    var orderToCancel by remember { mutableStateOf<OrderWithItems?>(null) }

    val filteredOrders = orders.filter { item ->
        val matchesStatus = selectedStatusFilter == null || item.order.status == selectedStatusFilter
        val matchesSearch = searchQuery.isBlank() ||
                item.order.invoiceNumber.contains(searchQuery, ignoreCase = true) ||
                item.order.customerName.contains(searchQuery, ignoreCase = true) ||
                item.order.tableName.contains(searchQuery, ignoreCase = true)
        matchesStatus && matchesSearch
    }

    Column(modifier = modifier.fillMaxSize()) {
        // Header
        Surface(
            modifier = Modifier.fillMaxWidth(),
            color = MaterialTheme.colorScheme.surface,
            tonalElevation = 2.dp
        ) {
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = "Riwayat Transaksi Offline",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Text(
                    text = "Semua transaksi tersimpan aman di penyimpanan lokal",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )

                Spacer(modifier = Modifier.height(10.dp))

                // Search field
                OutlinedTextField(
                    value = searchQuery,
                    onValueChange = { searchQuery = it },
                    placeholder = { Text("Cari nomor nota, meja, atau nama...") },
                    leadingIcon = {
                        Icon(imageVector = Icons.Default.Search, contentDescription = null, modifier = Modifier.size(18.dp))
                    },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth(),
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = AmberPrimary
                    )
                )

                Spacer(modifier = Modifier.height(8.dp))

                // Status Filter Chips
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(top = 4.dp),
                    horizontalArrangement = Arrangement.spacedBy(6.dp)
                ) {
                    FilterChip(
                        selected = selectedStatusFilter == null,
                        onClick = { selectedStatusFilter = null },
                        label = { Text("Semua (${orders.size})", fontSize = 12.sp, fontWeight = if (selectedStatusFilter == null) FontWeight.Bold else FontWeight.Medium) },
                        shape = RoundedCornerShape(24.dp),
                        border = null,
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = com.example.ui.theme.PurplePrimary,
                            selectedLabelColor = Color.White,
                            containerColor = com.example.ui.theme.SurfaceLightChip,
                            labelColor = com.example.ui.theme.TextSecondaryLight
                        )
                    )
                    FilterChip(
                        selected = selectedStatusFilter == OrderStatus.PAID,
                        onClick = { selectedStatusFilter = OrderStatus.PAID },
                        label = { Text("Lunas (${orders.count { it.order.status == OrderStatus.PAID }})", fontSize = 12.sp, fontWeight = if (selectedStatusFilter == OrderStatus.PAID) FontWeight.Bold else FontWeight.Medium) },
                        shape = RoundedCornerShape(24.dp),
                        border = null,
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = com.example.ui.theme.PurplePrimary,
                            selectedLabelColor = Color.White,
                            containerColor = com.example.ui.theme.SurfaceLightChip,
                            labelColor = com.example.ui.theme.TextSecondaryLight
                        )
                    )
                    FilterChip(
                        selected = selectedStatusFilter == OrderStatus.PENDING,
                        onClick = { selectedStatusFilter = OrderStatus.PENDING },
                        label = { Text("Pending (${orders.count { it.order.status == OrderStatus.PENDING }})", fontSize = 12.sp, fontWeight = if (selectedStatusFilter == OrderStatus.PENDING) FontWeight.Bold else FontWeight.Medium) },
                        shape = RoundedCornerShape(24.dp),
                        border = null,
                        colors = FilterChipDefaults.filterChipColors(
                            selectedContainerColor = com.example.ui.theme.PurplePrimary,
                            selectedLabelColor = Color.White,
                            containerColor = com.example.ui.theme.SurfaceLightChip,
                            labelColor = com.example.ui.theme.TextSecondaryLight
                        )
                    )
                }
            }
        }

        // List of Transactions
        if (filteredOrders.isEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(32.dp),
                contentAlignment = Alignment.Center
            ) {
                Column(horizontalAlignment = Alignment.CenterHorizontally) {
                    Icon(
                        imageVector = Icons.Default.ReceiptLong,
                        contentDescription = null,
                        tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.4f),
                        modifier = Modifier.size(56.dp)
                    )
                    Spacer(modifier = Modifier.height(12.dp))
                    Text(
                        text = "Belum Ada Riwayat Transaksi",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "Transaksi yang diproses akan otomatis muncul di sini.",
                        fontSize = 13.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }
        } else {
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 16.dp),
                contentPadding = PaddingValues(vertical = 12.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredOrders, key = { it.order.id }) { item ->
                    TransactionItemCard(
                        orderWithItems = item,
                        onViewReceipt = { viewModel.openReceiptDialog(item) },
                        onSettleBill = { viewModel.openSettleDialog(item) },
                        onCancelOrder = { orderToCancel = item }
                    )
                }
            }
        }
    }

    // Cancel Order Confirmation Dialog
    orderToCancel?.let { item ->
        AlertDialog(
            onDismissRequest = { orderToCancel = null },
            title = { Text("Batalkan Pesanan?", fontWeight = FontWeight.Bold) },
            text = {
                Text(
                    "Apakah Anda yakin ingin membatalkan pesanan ${item.order.invoiceNumber}? Stok bahan makanan akan otomatis dikembalikan."
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        viewModel.cancelOrder(item.order.id)
                        orderToCancel = null
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = ErrorRed),
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Text("Batalkan Pesanan")
                }
            },
            dismissButton = {
                OutlinedButton(
                    onClick = { orderToCancel = null },
                    shape = RoundedCornerShape(10.dp)
                ) {
                    Text("Kembali")
                }
            },
            shape = RoundedCornerShape(18.dp)
        )
    }
}

@Composable
private fun TransactionItemCard(
    orderWithItems: OrderWithItems,
    onViewReceipt: () -> Unit,
    onSettleBill: () -> Unit,
    onCancelOrder: () -> Unit
) {
    val order = orderWithItems.order
    val items = orderWithItems.items

    val (statusColor, statusText) = when (order.status) {
        OrderStatus.PAID -> Pair(SuccessGreen, "LUNAS")
        OrderStatus.PENDING -> Pair(WarningOrange, "BELUM BAYAR")
        OrderStatus.CANCELLED -> Pair(ErrorRed, "DIBATALKAN")
    }

    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onViewReceipt() }
            .testTag("transaction_card_${order.invoiceNumber}"),
        shape = RoundedCornerShape(14.dp),
        colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surface),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.5.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .padding(14.dp)
        ) {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = order.invoiceNumber,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = RestaurantRepository.formatTimestamp(order.createdAt),
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Surface(
                    shape = RoundedCornerShape(6.dp),
                    color = statusColor.copy(alpha = 0.15f)
                ) {
                    Text(
                        text = statusText,
                        fontSize = 11.sp,
                        fontWeight = FontWeight.Bold,
                        color = statusColor,
                        modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                    )
                }
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Details info
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween
            ) {
                Text(
                    text = "${order.tableName} • ${order.customerName}",
                    fontSize = 12.sp,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
                Text(
                    text = "Metode: ${order.paymentMethod.name}",
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Medium,
                    color = AmberPrimary
                )
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Item summary line
            Text(
                text = items.joinToString(", ") { "${it.quantity}x ${it.menuName}" },
                fontSize = 12.sp,
                color = MaterialTheme.colorScheme.onSurface,
                maxLines = 1
            )

            HorizontalDivider(modifier = Modifier.padding(vertical = 8.dp))

            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = "Grand Total",
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = RestaurantRepository.formatRupiah(order.grandTotal),
                        fontSize = 16.sp,
                        fontWeight = FontWeight.ExtraBold,
                        color = AmberPrimary
                    )
                }

                Row(horizontalArrangement = Arrangement.spacedBy(6.dp)) {
                    if (order.status == OrderStatus.PENDING) {
                        OutlinedButton(
                            onClick = onCancelOrder,
                            shape = RoundedCornerShape(8.dp),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Text("Batal", fontSize = 12.sp, color = ErrorRed)
                        }

                        Button(
                            onClick = onSettleBill,
                            shape = RoundedCornerShape(8.dp),
                            colors = ButtonDefaults.buttonColors(containerColor = AmberPrimary),
                            contentPadding = PaddingValues(horizontal = 10.dp, vertical = 4.dp)
                        ) {
                            Text("Bayar Bill", fontSize = 12.sp, fontWeight = FontWeight.Bold)
                        }
                    } else {
                        OutlinedButton(
                            onClick = onViewReceipt,
                            shape = RoundedCornerShape(8.dp),
                            contentPadding = PaddingValues(horizontal = 12.dp, vertical = 4.dp)
                        ) {
                            Icon(Icons.Default.ReceiptLong, contentDescription = null, modifier = Modifier.size(14.dp))
                            Spacer(modifier = Modifier.width(4.dp))
                            Text("Lihat Struk", fontSize = 12.sp)
                        }
                    }
                }
            }
        }
    }
}
