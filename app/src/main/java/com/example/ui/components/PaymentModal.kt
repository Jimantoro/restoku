package com.example.ui.components

import androidx.compose.foundation.Canvas
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.horizontalScroll
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxHeight
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.navigationBarsPadding
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AccountBalance
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.CreditCard
import androidx.compose.material.icons.filled.Money
import androidx.compose.material.icons.filled.Print
import androidx.compose.material.icons.filled.QrCode2
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilterChip
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedTextField
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
import androidx.compose.ui.geometry.Offset
import androidx.compose.ui.geometry.Size
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.OrderWithItems
import com.example.data.model.PaymentMethod
import com.example.data.repository.RestaurantRepository
import com.example.ui.theme.AmberPrimary
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.InfoBlue
import com.example.ui.theme.SuccessGreen
import com.example.ui.viewmodel.PosUiState
import kotlin.math.ceil

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PaymentModal(
    uiState: PosUiState,
    activeSettleOrder: OrderWithItems?,
    onDismiss: () -> Unit,
    onConfirmPayment: (PaymentMethod, Double, Boolean, String) -> Unit,
    onConfirmSettle: (Long, PaymentMethod, Double) -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    val grandTotal = activeSettleOrder?.order?.grandTotal ?: uiState.grandTotal
    var selectedMethod by remember { mutableStateOf(PaymentMethod.CASH) }
    var cashPaidInput by remember { mutableStateOf(grandTotal.toLong().toString()) }
    var selectedBank by remember { mutableStateOf("BCA") }
    var cardTraceNumber by remember { mutableStateOf("") }
    var cashierNotes by remember { mutableStateOf("") }

    val cashAmountDouble = cashPaidInput.toDoubleOrNull() ?: 0.0
    val changeAmount = cashAmountDouble - grandTotal
    val isCashSufficient = cashAmountDouble >= grandTotal

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = MaterialTheme.colorScheme.surface,
        dragHandle = null,
        shape = RoundedCornerShape(topStart = 24.dp, topEnd = 24.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.94f)
                .navigationBarsPadding()
                .padding(top = 16.dp)
        ) {
            // Header
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Column {
                    Text(
                        text = if (activeSettleOrder != null) "Pelunasan Tagihan Meja" else "Pembayaran Kasir Offline",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = activeSettleOrder?.let { "${it.order.invoiceNumber} • ${it.order.tableName}" }
                            ?: "${uiState.selectedTable?.let { "Meja ${it.tableNumber}" } ?: uiState.orderType.name} • ${uiState.totalItemCount} Item",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                IconButton(onClick = onDismiss) {
                    Icon(imageVector = Icons.Default.Close, contentDescription = "Tutup")
                }
            }

            HorizontalDivider(modifier = Modifier.padding(vertical = 10.dp))

            // Body
            Column(
                modifier = Modifier
                    .weight(1f)
                    .verticalScroll(rememberScrollState())
                    .padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(16.dp)
            ) {
                // Grand Total Banner
                Surface(
                    shape = RoundedCornerShape(16.dp),
                    color = AmberPrimary.copy(alpha = 0.1f),
                    border = androidx.compose.foundation.BorderStroke(1.dp, AmberPrimary.copy(alpha = 0.3f)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Column(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(
                            text = "TOTAL YANG HARUS DIBAYAR",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = AmberPrimary,
                            letterSpacing = 1.sp
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = RestaurantRepository.formatRupiah(grandTotal),
                            fontSize = 28.sp,
                            fontWeight = FontWeight.ExtraBold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }

                // Payment Method Selector
                Text(
                    text = "Metode Pembayaran",
                    fontSize = 14.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )

                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .horizontalScroll(rememberScrollState()),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    PaymentMethodChip(
                        name = "Tunai (Cash)",
                        icon = Icons.Default.Money,
                        isSelected = selectedMethod == PaymentMethod.CASH,
                        onClick = { selectedMethod = PaymentMethod.CASH }
                    )
                    PaymentMethodChip(
                        name = "QRIS Offline",
                        icon = Icons.Default.QrCode2,
                        isSelected = selectedMethod == PaymentMethod.QRIS_OFFLINE,
                        onClick = { selectedMethod = PaymentMethod.QRIS_OFFLINE }
                    )
                    PaymentMethodChip(
                        name = "Debit / EDC",
                        icon = Icons.Default.CreditCard,
                        isSelected = selectedMethod == PaymentMethod.DEBIT_CARD,
                        onClick = { selectedMethod = PaymentMethod.DEBIT_CARD }
                    )
                    PaymentMethodChip(
                        name = "Transfer Bank",
                        icon = Icons.Default.AccountBalance,
                        isSelected = selectedMethod == PaymentMethod.TRANSFER_BANK,
                        onClick = { selectedMethod = PaymentMethod.TRANSFER_BANK }
                    )
                }

                // Method-Specific Panels
                when (selectedMethod) {
                    PaymentMethod.CASH -> {
                        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                            Text(
                                text = "Uang Diterima",
                                fontSize = 13.sp,
                                fontWeight = FontWeight.SemiBold
                            )

                            OutlinedTextField(
                                value = cashPaidInput,
                                onValueChange = { cashPaidInput = it.filter { ch -> ch.isDigit() } },
                                label = { Text("Nominal Uang Tunai (Rp)") },
                                singleLine = true,
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("cash_amount_input")
                            )

                            // Quick preset chips
                            Text(
                                text = "Pilihan Cepat:",
                                fontSize = 12.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )

                            val exactAmount = grandTotal.toLong()
                            val nextFifty = ceil(grandTotal / 50000.0).toLong() * 50000
                            val nextHundred = ceil(grandTotal / 100000.0).toLong() * 100000

                            val presets = listOfNotNull(
                                exactAmount,
                                if (nextFifty > exactAmount) nextFifty else null,
                                if (nextHundred > exactAmount && nextHundred != nextFifty) nextHundred else null,
                                50000L,
                                100000L,
                                200000L
                            ).distinct()

                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .horizontalScroll(rememberScrollState()),
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                presets.forEach { amount ->
                                    FilterChip(
                                        selected = cashPaidInput == amount.toString(),
                                        onClick = { cashPaidInput = amount.toString() },
                                        label = {
                                            Text(
                                                if (amount == exactAmount) "Uang Pas (${RestaurantRepository.formatRupiah(amount.toDouble())})"
                                                else RestaurantRepository.formatRupiah(amount.toDouble())
                                            )
                                        }
                                    )
                                }
                            }

                            // Change calculation card
                            Surface(
                                shape = RoundedCornerShape(12.dp),
                                color = if (isCashSufficient) SuccessGreen.copy(alpha = 0.1f) else ErrorRed.copy(alpha = 0.1f),
                                border = androidx.compose.foundation.BorderStroke(
                                    1.dp,
                                    if (isCashSufficient) SuccessGreen.copy(alpha = 0.4f) else ErrorRed.copy(alpha = 0.4f)
                                ),
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .padding(14.dp),
                                    horizontalArrangement = Arrangement.SpaceBetween,
                                    verticalAlignment = Alignment.CenterVertically
                                ) {
                                    Column {
                                        Text(
                                            text = if (isCashSufficient) "KEMBALIAN" else "UANG KURANG",
                                            fontSize = 11.sp,
                                            fontWeight = FontWeight.Bold,
                                            color = if (isCashSufficient) SuccessGreen else ErrorRed
                                        )
                                        Text(
                                            text = if (isCashSufficient) RestaurantRepository.formatRupiah(changeAmount)
                                            else RestaurantRepository.formatRupiah(grandTotal - cashAmountDouble),
                                            fontSize = 20.sp,
                                            fontWeight = FontWeight.ExtraBold,
                                            color = if (isCashSufficient) SuccessGreen else ErrorRed
                                        )
                                    }

                                    Icon(
                                        imageVector = if (isCashSufficient) Icons.Default.CheckCircle else Icons.Default.Close,
                                        contentDescription = null,
                                        tint = if (isCashSufficient) SuccessGreen else ErrorRed,
                                        modifier = Modifier.size(28.dp)
                                    )
                                }
                            }
                        }
                    }

                    PaymentMethod.QRIS_OFFLINE -> {
                        Card(
                            modifier = Modifier.fillMaxWidth(),
                            shape = RoundedCornerShape(16.dp),
                            colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f))
                        ) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(16.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Text(
                                    text = "QRIS STANDAR PEMBAYARAN NASIONAL",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 1.sp
                                )
                                Text(
                                    text = "RESTO KASIR OFFLINE",
                                    fontSize = 15.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = AmberPrimary
                                )
                                Text(
                                    text = "NMID: ID1020268874100 • Offline Mode",
                                    fontSize = 11.sp,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )

                                Spacer(modifier = Modifier.height(12.dp))

                                // Render simulated QRIS matrix pattern
                                Box(
                                    modifier = Modifier
                                        .size(180.dp)
                                        .background(Color.White, RoundedCornerShape(8.dp))
                                        .border(2.dp, Color.Black, RoundedCornerShape(8.dp))
                                        .padding(10.dp),
                                    contentAlignment = Alignment.Center
                                ) {
                                    Canvas(modifier = Modifier.size(160.dp)) {
                                        val gridSize = 16
                                        val cellSize = size.width / gridSize
                                        val seed = grandTotal.toLong()

                                        for (i in 0 until gridSize) {
                                            for (j in 0 until gridSize) {
                                                // Draw finder patterns at corners
                                                val isTopLeftFinder = i < 4 && j < 4
                                                val isTopRightFinder = i >= gridSize - 4 && j < 4
                                                val isBottomLeftFinder = i < 4 && j >= gridSize - 4

                                                val isBlack = if (isTopLeftFinder || isTopRightFinder || isBottomLeftFinder) {
                                                    (i == 0 || i == 3 || j == 0 || j == 3 || (i == 1 && j == 1) || (i == 2 && j == 2) || (i == 1 && j == 2) || (i == 2 && j == 1))
                                                } else {
                                                    ((i * 17 + j * 31 + seed) % 3) == 0L
                                                }

                                                if (isBlack) {
                                                    drawRect(
                                                        color = Color.Black,
                                                        topLeft = Offset(i * cellSize, j * cellSize),
                                                        size = Size(cellSize, cellSize)
                                                    )
                                                }
                                            }
                                        }
                                    }
                                }

                                Spacer(modifier = Modifier.height(10.dp))
                                Text(
                                    text = "Tunjukkan QR ini ke pelanggan untuk di-scan via m-Banking/E-Wallet.",
                                    fontSize = 11.sp,
                                    textAlign = TextAlign.Center,
                                    color = MaterialTheme.colorScheme.onSurfaceVariant
                                )
                            }
                        }
                    }

                    PaymentMethod.DEBIT_CARD, PaymentMethod.CREDIT_CARD -> {
                        Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                            Text("Pilih Bank EDC:", fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .horizontalScroll(rememberScrollState()),
                                horizontalArrangement = Arrangement.spacedBy(6.dp)
                            ) {
                                listOf("BCA", "Mandiri", "BRI", "BNI", "CIMB").forEach { bank ->
                                    FilterChip(
                                        selected = selectedBank == bank,
                                        onClick = { selectedBank = bank },
                                        label = { Text(bank) }
                                    )
                                }
                            }

                            OutlinedTextField(
                                value = cardTraceNumber,
                                onValueChange = { cardTraceNumber = it },
                                label = { Text("No. Approval / Ref EDC (Opsional)") },
                                placeholder = { Text("Contoh: 894321") },
                                singleLine = true,
                                shape = RoundedCornerShape(12.dp),
                                modifier = Modifier.fillMaxWidth()
                            )
                        }
                    }

                    PaymentMethod.TRANSFER_BANK -> {
                        Surface(
                            shape = RoundedCornerShape(12.dp),
                            color = InfoBlue.copy(alpha = 0.1f),
                            modifier = Modifier.fillMaxWidth()
                        ) {
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(14.dp)
                            ) {
                                Text(
                                    text = "Transfer Rekening Kasir Resto",
                                    fontSize = 13.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = InfoBlue
                                )
                                Spacer(modifier = Modifier.height(4.dp))
                                Text(
                                    text = "BCA: 873-091-2244 a/n Resto Nusantara\nMandiri: 137-00-982134-1",
                                    fontSize = 12.sp,
                                    fontFamily = FontFamily.Monospace,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                            }
                        }
                    }
                }

                // Optional Cashier Note
                OutlinedTextField(
                    value = cashierNotes,
                    onValueChange = { cashierNotes = it },
                    label = { Text("Catatan Transaksi (Opsional)") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }

            // Bottom Action Button
            Surface(
                color = MaterialTheme.colorScheme.surface,
                tonalElevation = 6.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Button(
                    onClick = {
                        val paid = if (selectedMethod == PaymentMethod.CASH) cashAmountDouble else grandTotal
                        if (activeSettleOrder != null) {
                            onConfirmSettle(activeSettleOrder.order.id, selectedMethod, paid)
                        } else {
                            onConfirmPayment(selectedMethod, paid, true, cashierNotes)
                        }
                    },
                    enabled = selectedMethod != PaymentMethod.CASH || isCashSufficient,
                    shape = RoundedCornerShape(16.dp),
                    colors = ButtonDefaults.buttonColors(containerColor = com.example.ui.theme.PurplePrimary),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(52.dp)
                        .padding(horizontal = 20.dp)
                        .testTag("submit_payment_btn")
                ) {
                    Icon(Icons.Default.Print, contentDescription = null, modifier = Modifier.size(18.dp))
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "SELESAIKAN & CETAK STRUK",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.5.sp
                    )
                }
            }
        }
    }
}

@Composable
private fun PaymentMethodChip(
    name: String,
    icon: androidx.compose.ui.graphics.vector.ImageVector,
    isSelected: Boolean,
    onClick: () -> Unit
) {
    FilterChip(
        selected = isSelected,
        onClick = onClick,
        label = { Text(name, fontSize = 12.sp, fontWeight = if (isSelected) FontWeight.Bold else FontWeight.Medium) },
        leadingIcon = { Icon(imageVector = icon, contentDescription = null, modifier = Modifier.size(16.dp)) },
        shape = RoundedCornerShape(20.dp),
        border = null,
        colors = androidx.compose.material3.FilterChipDefaults.filterChipColors(
            selectedContainerColor = com.example.ui.theme.PurplePrimary,
            selectedLabelColor = Color.White,
            selectedLeadingIconColor = Color.White,
            containerColor = com.example.ui.theme.SurfaceLightChip,
            labelColor = com.example.ui.theme.TextSecondaryLight
        )
    )
}
