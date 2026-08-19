package com.example.ui.components

import android.content.Context
import android.content.Intent
import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.foundation.verticalScroll
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Share
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontFamily
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.OrderWithItems
import com.example.data.repository.RestaurantRepository
import com.example.ui.theme.AmberPrimary
import com.example.ui.theme.SuccessGreen

@Composable
fun ReceiptModal(
    orderWithItems: OrderWithItems,
    onDismiss: () -> Unit
) {
    val context = LocalContext.current
    val order = orderWithItems.order
    val items = orderWithItems.items

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Row(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(
                        imageVector = Icons.Default.CheckCircle,
                        contentDescription = null,
                        tint = SuccessGreen,
                        modifier = Modifier.size(24.dp)
                    )
                    Spacer(modifier = Modifier.width(8.dp))
                    Text(
                        text = "Struk Pembayaran",
                        fontSize = 18.sp,
                        fontWeight = FontWeight.Bold
                    )
                }
            }
        },
        text = {
            // Thermal Receipt Slip Paper Look
            Surface(
                shape = RoundedCornerShape(12.dp),
                color = Color(0xFFFDFCFA),
                border = androidx.compose.foundation.BorderStroke(1.dp, Color(0xFFE2DDD5)),
                modifier = Modifier
                    .fillMaxWidth()
                    .verticalScroll(rememberScrollState())
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalAlignment = Alignment.CenterHorizontally
                ) {
                    // Header
                    Text(
                        text = "RESTO NUSANTARA",
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        fontFamily = FontFamily.Monospace,
                        color = Color.Black
                    )
                    Text(
                        text = "Jl. Kuliner Rasa No. 88, Jakarta",
                        fontSize = 11.sp,
                        fontFamily = FontFamily.Monospace,
                        color = Color.DarkGray
                    )
                    Text(
                        text = "Telp: (021) 555-1234 • Offline POS",
                        fontSize = 11.sp,
                        fontFamily = FontFamily.Monospace,
                        color = Color.DarkGray
                    )

                    Spacer(modifier = Modifier.height(10.dp))
                    ReceiptDashedLine()
                    Spacer(modifier = Modifier.height(6.dp))

                    // Meta Info
                    ReceiptRow(label = "No. Nota", value = order.invoiceNumber)
                    ReceiptRow(label = "Tanggal", value = RestaurantRepository.formatTimestamp(order.createdAt))
                    ReceiptRow(label = "Kasir", value = order.cashierName)
                    ReceiptRow(label = "Tipe", value = "${order.orderType.name} (${order.tableName})")
                    if (order.customerName.isNotBlank()) {
                        ReceiptRow(label = "Pelanggan", value = order.customerName)
                    }

                    Spacer(modifier = Modifier.height(6.dp))
                    ReceiptDashedLine()
                    Spacer(modifier = Modifier.height(8.dp))

                    // Itemized details
                    items.forEach { item ->
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(vertical = 3.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text(
                                    text = item.menuName,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    fontFamily = FontFamily.Monospace,
                                    color = Color.Black,
                                    modifier = Modifier.weight(1f)
                                )
                                Text(
                                    text = RestaurantRepository.formatRupiah(item.subtotal),
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Bold,
                                    fontFamily = FontFamily.Monospace,
                                    color = Color.Black
                                )
                            }
                            Row {
                                Text(
                                    text = "${item.quantity} x ${RestaurantRepository.formatRupiah(item.unitPrice)}",
                                    fontSize = 11.sp,
                                    fontFamily = FontFamily.Monospace,
                                    color = Color.DarkGray
                                )
                                if (item.notes.isNotBlank()) {
                                    Text(
                                        text = " (${item.notes})",
                                        fontSize = 10.sp,
                                        fontFamily = FontFamily.Monospace,
                                        color = Color.Gray
                                    )
                                }
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))
                    ReceiptDashedLine()
                    Spacer(modifier = Modifier.height(6.dp))

                    // Totals
                    ReceiptRow(label = "Subtotal", value = RestaurantRepository.formatRupiah(order.subtotal))
                    if (order.discountAmount > 0) {
                        ReceiptRow(label = "Diskon (${order.discountPercent.toInt()}%)", value = "- ${RestaurantRepository.formatRupiah(order.discountAmount)}")
                    }
                    ReceiptRow(label = "PB1 / Pajak (${order.taxRatePercent.toInt()}%)", value = RestaurantRepository.formatRupiah(order.taxAmount))
                    if (order.serviceAmount > 0) {
                        ReceiptRow(label = "Service Charge", value = RestaurantRepository.formatRupiah(order.serviceAmount))
                    }

                    Spacer(modifier = Modifier.height(6.dp))
                    ReceiptDashedLine()
                    Spacer(modifier = Modifier.height(6.dp))

                    ReceiptRow(
                        label = "GRAND TOTAL",
                        value = RestaurantRepository.formatRupiah(order.grandTotal),
                        isBold = true
                    )
                    ReceiptRow(label = "Metode Bayar", value = order.paymentMethod.name)
                    ReceiptRow(label = "Bayar / Diterima", value = RestaurantRepository.formatRupiah(order.amountPaid))
                    ReceiptRow(label = "Kembalian", value = RestaurantRepository.formatRupiah(order.changeAmount), isBold = true)

                    if (order.referenceNumber.isNotBlank()) {
                        ReceiptRow(label = "Ref / Auth", value = order.referenceNumber)
                    }

                    Spacer(modifier = Modifier.height(10.dp))
                    ReceiptDashedLine()
                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = "TERIMA KASIH ATAS KUNJUNGAN ANDA\nLayanan Konsumen: 0812-3456-7890",
                        fontSize = 10.sp,
                        fontFamily = FontFamily.Monospace,
                        textAlign = TextAlign.Center,
                        color = Color.DarkGray
                    )
                }
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    shareReceiptText(context, orderWithItems)
                },
                colors = ButtonDefaults.buttonColors(containerColor = com.example.ui.theme.PurplePrimary),
                shape = RoundedCornerShape(14.dp),
                modifier = Modifier.testTag("share_receipt_btn")
            ) {
                Icon(Icons.Default.Share, contentDescription = null, modifier = Modifier.size(16.dp))
                Spacer(modifier = Modifier.width(6.dp))
                Text("Bagikan Struk")
            }
        },
        dismissButton = {
            OutlinedButton(
                onClick = onDismiss,
                shape = RoundedCornerShape(14.dp)
            ) {
                Text("Selesai")
            }
        },
        shape = RoundedCornerShape(24.dp)
    )
}

@Composable
private fun ReceiptRow(
    label: String,
    value: String,
    isBold: Boolean = false
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 1.5.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(
            text = label,
            fontSize = if (isBold) 13.sp else 11.sp,
            fontWeight = if (isBold) FontWeight.Bold else FontWeight.Normal,
            fontFamily = FontFamily.Monospace,
            color = Color.Black
        )
        Text(
            text = value,
            fontSize = if (isBold) 13.sp else 11.sp,
            fontWeight = if (isBold) FontWeight.Bold else FontWeight.Normal,
            fontFamily = FontFamily.Monospace,
            color = Color.Black
        )
    }
}

@Composable
private fun ReceiptDashedLine() {
    Text(
        text = "- - - - - - - - - - - - - - - - - - - - - - - - - -",
        fontSize = 10.sp,
        fontFamily = FontFamily.Monospace,
        color = Color.LightGray,
        maxLines = 1
    )
}

private fun shareReceiptText(context: Context, orderWithItems: OrderWithItems) {
    val order = orderWithItems.order
    val items = orderWithItems.items

    val sb = StringBuilder()
    sb.appendLine("================================")
    sb.appendLine("       RESTO NUSANTARA")
    sb.appendLine("  STRUK PEMBAYARAN RESMI OFFLINE")
    sb.appendLine("================================")
    sb.appendLine("No Nota  : ${order.invoiceNumber}")
    sb.appendLine("Tanggal  : ${RestaurantRepository.formatTimestamp(order.createdAt)}")
    sb.appendLine("Kasir    : ${order.cashierName}")
    sb.appendLine("Tipe     : ${order.orderType.name} (${order.tableName})")
    if (order.customerName.isNotBlank()) {
        sb.appendLine("Pelanggan: ${order.customerName}")
    }
    sb.appendLine("--------------------------------")
    items.forEach { item ->
        sb.appendLine("${item.menuName}")
        sb.appendLine("  ${item.quantity}x @${RestaurantRepository.formatRupiah(item.unitPrice)} = ${RestaurantRepository.formatRupiah(item.subtotal)}")
        if (item.notes.isNotBlank()) {
            sb.appendLine("  * Catatan: ${item.notes}")
        }
    }
    sb.appendLine("--------------------------------")
    sb.appendLine("Subtotal      : ${RestaurantRepository.formatRupiah(order.subtotal)}")
    if (order.discountAmount > 0) {
        sb.appendLine("Diskon (${order.discountPercent.toInt()}%)  : -${RestaurantRepository.formatRupiah(order.discountAmount)}")
    }
    sb.appendLine("Pajak PB1 (${order.taxRatePercent.toInt()}%): ${RestaurantRepository.formatRupiah(order.taxAmount)}")
    sb.appendLine("GRAND TOTAL   : ${RestaurantRepository.formatRupiah(order.grandTotal)}")
    sb.appendLine("Metode Bayar  : ${order.paymentMethod.name}")
    sb.appendLine("Bayar Diterima: ${RestaurantRepository.formatRupiah(order.amountPaid)}")
    sb.appendLine("Kembalian     : ${RestaurantRepository.formatRupiah(order.changeAmount)}")
    sb.appendLine("================================")
    sb.appendLine("Terima Kasih Atas Kunjungan Anda")

    val sendIntent: Intent = Intent().apply {
        action = Intent.ACTION_SEND
        putExtra(Intent.EXTRA_TEXT, sb.toString())
        type = "text/plain"
    }
    val shareIntent = Intent.createChooser(sendIntent, "Bagikan Struk Digital")
    context.startActivity(shareIntent)
}
