package com.example.ui.components

import androidx.compose.foundation.background
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
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.rememberScrollState
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.BakeryDining
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.DeleteOutline
import androidx.compose.material.icons.filled.DeliveryDining
import androidx.compose.material.icons.filled.Dining
import androidx.compose.material.icons.filled.EditNote
import androidx.compose.material.icons.filled.LocalBar
import androidx.compose.material.icons.filled.LunchDining
import androidx.compose.material.icons.filled.Payments
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material.icons.filled.Restaurant
import androidx.compose.material.icons.filled.Save
import androidx.compose.material.icons.filled.SetMeal
import androidx.compose.material.icons.filled.TableBar
import androidx.compose.material.icons.filled.TakeoutDining
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.FilterChip
import androidx.compose.material3.FilterChipDefaults
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.ModalBottomSheet
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.CartItem
import com.example.data.model.OrderType
import com.example.data.model.TableEntity
import com.example.data.repository.RestaurantRepository
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.PurpleOnPrimaryContainer
import com.example.ui.theme.PurplePrimary
import com.example.ui.theme.PurplePrimaryContainer
import com.example.ui.theme.PurpleSecondaryContainer
import com.example.ui.theme.SurfaceLightBorder
import com.example.ui.theme.SurfaceLightChip
import com.example.ui.theme.TextSecondaryLight
import com.example.ui.viewmodel.PosUiState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CartDetailSheet(
    uiState: PosUiState,
    tables: List<TableEntity>,
    onDismiss: () -> Unit,
    onQuantityChange: (Int, Int) -> Unit,
    onRemoveItem: (Int) -> Unit,
    onClearCart: () -> Unit,
    onOpenNotes: (CartItem) -> Unit,
    onCustomerNameChange: (String) -> Unit,
    onOrderTypeChange: (OrderType) -> Unit,
    onTableSelect: (TableEntity?) -> Unit,
    onDiscountChange: (Double) -> Unit,
    onProceedPayment: () -> Unit,
    onSavePendingOrder: () -> Unit
) {
    val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = true)

    ModalBottomSheet(
        onDismissRequest = onDismiss,
        sheetState = sheetState,
        containerColor = MaterialTheme.colorScheme.surface,
        dragHandle = null,
        shape = RoundedCornerShape(topStart = 28.dp, topEnd = 28.dp)
    ) {
        Column(
            modifier = Modifier
                .fillMaxWidth()
                .fillMaxHeight(0.93f)
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
                        text = "Ringkasan Pesanan",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "${uiState.totalItemCount} item dalam keranjang",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }

                Row {
                    IconButton(
                        onClick = onClearCart,
                        modifier = Modifier.testTag("clear_cart_btn")
                    ) {
                        Icon(
                            imageVector = Icons.Default.DeleteOutline,
                            contentDescription = "Kosongkan Keranjang",
                            tint = ErrorRed
                        )
                    }

                    IconButton(onClick = onDismiss) {
                        Icon(
                            imageVector = Icons.Default.Close,
                            contentDescription = "Tutup",
                            tint = MaterialTheme.colorScheme.onSurface
                        )
                    }
                }
            }

            HorizontalDivider(
                modifier = Modifier.padding(vertical = 8.dp),
                color = SurfaceLightBorder.copy(alpha = 0.4f)
            )

            // Scrollable Body
            LazyColumn(
                modifier = Modifier
                    .weight(1f)
                    .padding(horizontal = 20.dp),
                verticalArrangement = Arrangement.spacedBy(14.dp)
            ) {
                // 1. Order Type Chips
                item {
                    Text(
                        text = "Tipe Pemesanan",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        OrderTypeFilterChip(
                            label = "Dine In",
                            icon = Icons.Default.Dining,
                            selected = uiState.orderType == OrderType.DINE_IN,
                            onClick = { onOrderTypeChange(OrderType.DINE_IN) },
                            modifier = Modifier.weight(1f)
                        )
                        OrderTypeFilterChip(
                            label = "Takeaway",
                            icon = Icons.Default.TakeoutDining,
                            selected = uiState.orderType == OrderType.TAKEAWAY,
                            onClick = { onOrderTypeChange(OrderType.TAKEAWAY) },
                            modifier = Modifier.weight(1f)
                        )
                        OrderTypeFilterChip(
                            label = "Delivery",
                            icon = Icons.Default.DeliveryDining,
                            selected = uiState.orderType == OrderType.DELIVERY,
                            onClick = { onOrderTypeChange(OrderType.DELIVERY) },
                            modifier = Modifier.weight(1f)
                        )
                    }
                }

                // 2. Table Selector (If Dine In)
                if (uiState.orderType == OrderType.DINE_IN) {
                    item {
                        Text(
                            text = "Pilih Meja",
                            fontSize = 13.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.height(6.dp))
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .horizontalScroll(rememberScrollState()),
                            horizontalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            tables.forEach { table ->
                                val isSelected = uiState.selectedTable?.id == table.id
                                FilterChip(
                                    selected = isSelected,
                                    onClick = { onTableSelect(if (isSelected) null else table) },
                                    label = { Text("Meja ${table.tableNumber}") },
                                    leadingIcon = {
                                        Icon(
                                            Icons.Default.TableBar,
                                            contentDescription = null,
                                            modifier = Modifier.size(14.dp)
                                        )
                                    },
                                    shape = RoundedCornerShape(20.dp),
                                    colors = FilterChipDefaults.filterChipColors(
                                        selectedContainerColor = PurplePrimary,
                                        selectedLabelColor = Color.White,
                                        selectedLeadingIconColor = Color.White,
                                        containerColor = SurfaceLightChip,
                                        labelColor = TextSecondaryLight
                                    )
                                )
                            }
                        }
                    }
                }

                // 3. Customer Name Field
                item {
                    OutlinedTextField(
                        value = uiState.customerName,
                        onValueChange = onCustomerNameChange,
                        label = { Text("Nama Pelanggan (Opsional)") },
                        singleLine = true,
                        shape = RoundedCornerShape(16.dp),
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = PurplePrimary
                        ),
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("customer_name_input")
                    )
                }

                // 4. Order Details Card Container (Professional Polish style)
                item {
                    Surface(
                        shape = RoundedCornerShape(24.dp),
                        color = MaterialTheme.colorScheme.surfaceVariant,
                        border = androidx.compose.foundation.BorderStroke(1.dp, SurfaceLightBorder),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(modifier = Modifier.fillMaxWidth()) {
                            // Container Header
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .background(PurplePrimary.copy(alpha = 0.08f))
                                    .padding(horizontal = 16.dp, vertical = 12.dp),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "Order Details",
                                    fontSize = 14.sp,
                                    fontWeight = FontWeight.Bold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                                Text(
                                    text = "${uiState.totalItemCount} ITEMS",
                                    fontSize = 11.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = PurplePrimary,
                                    letterSpacing = 0.5.sp
                                )
                            }

                            HorizontalDivider(color = SurfaceLightBorder.copy(alpha = 0.5f))

                            // Items List inside container
                            Column(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .padding(14.dp),
                                verticalArrangement = Arrangement.spacedBy(12.dp)
                            ) {
                                uiState.cartItems.forEach { item ->
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Row(
                                            modifier = Modifier.weight(1f),
                                            verticalAlignment = Alignment.CenterVertically
                                        ) {
                                            Box(
                                                modifier = Modifier
                                                    .size(46.dp)
                                                    .clip(RoundedCornerShape(12.dp))
                                                    .background(PurplePrimaryContainer),
                                                contentAlignment = Alignment.Center
                                            ) {
                                                Icon(
                                                    imageVector = getCartIcon(item.menu.categoryName),
                                                    contentDescription = null,
                                                    tint = PurpleOnPrimaryContainer,
                                                    modifier = Modifier.size(24.dp)
                                                )
                                            }

                                            Spacer(modifier = Modifier.width(12.dp))

                                            Column {
                                                Text(
                                                    text = item.menu.name,
                                                    fontSize = 14.sp,
                                                    fontWeight = FontWeight.Bold,
                                                    color = MaterialTheme.colorScheme.onSurface,
                                                    maxLines = 1,
                                                    overflow = TextOverflow.Ellipsis
                                                )
                                                Text(
                                                    text = "x ${item.quantity} · ${if (item.notes.isNotBlank()) item.notes else item.menu.unit}",
                                                    fontSize = 12.sp,
                                                    color = MaterialTheme.colorScheme.onSurfaceVariant,
                                                    maxLines = 1,
                                                    overflow = TextOverflow.Ellipsis
                                                )
                                            }
                                        }

                                        Column(horizontalAlignment = Alignment.End) {
                                            Text(
                                                text = RestaurantRepository.formatRupiah(item.subtotal),
                                                fontSize = 14.sp,
                                                fontWeight = FontWeight.Bold,
                                                color = MaterialTheme.colorScheme.onSurface
                                            )

                                            Row(
                                                verticalAlignment = Alignment.CenterVertically,
                                                horizontalArrangement = Arrangement.spacedBy(2.dp)
                                            ) {
                                                FilledTonalIconButton(
                                                    onClick = { onQuantityChange(item.menu.id, item.quantity - 1) },
                                                    modifier = Modifier.size(24.dp),
                                                    shape = CircleShape
                                                ) {
                                                    Icon(
                                                        imageVector = if (item.quantity == 1) Icons.Default.Delete else Icons.Default.Remove,
                                                        contentDescription = "Kurang",
                                                        modifier = Modifier.size(12.dp)
                                                    )
                                                }

                                                Text(
                                                    text = item.quantity.toString(),
                                                    fontSize = 12.sp,
                                                    fontWeight = FontWeight.Bold,
                                                    modifier = Modifier.padding(horizontal = 4.dp)
                                                )

                                                FilledTonalIconButton(
                                                    onClick = { onQuantityChange(item.menu.id, item.quantity + 1) },
                                                    modifier = Modifier.size(24.dp),
                                                    shape = CircleShape,
                                                    enabled = item.quantity < item.menu.stock,
                                                    colors = IconButtonDefaults.filledTonalIconButtonColors(
                                                        containerColor = PurplePrimary,
                                                        contentColor = Color.White
                                                    )
                                                ) {
                                                    Icon(
                                                        imageVector = Icons.Default.Add,
                                                        contentDescription = "Tambah",
                                                        modifier = Modifier.size(12.dp)
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

                // 5. Discount Presets
                item {
                    Text(
                        text = "Diskon Promo",
                        fontSize = 13.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Spacer(modifier = Modifier.height(6.dp))
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(6.dp)
                    ) {
                        listOf(0.0, 5.0, 10.0, 15.0, 20.0).forEach { disc ->
                            FilterChip(
                                selected = uiState.discountPercent == disc,
                                onClick = { onDiscountChange(disc) },
                                label = { Text(if (disc == 0.0) "0%" else "${disc.toInt()}%") },
                                shape = RoundedCornerShape(20.dp),
                                colors = FilterChipDefaults.filterChipColors(
                                    selectedContainerColor = PurplePrimary,
                                    selectedLabelColor = Color.White,
                                    containerColor = SurfaceLightChip,
                                    labelColor = TextSecondaryLight
                                ),
                                modifier = Modifier.weight(1f)
                            )
                        }
                    }
                }

                // 6. Pricing Breakdown Box
                item {
                    Surface(
                        shape = RoundedCornerShape(20.dp),
                        color = Color.White,
                        border = androidx.compose.foundation.BorderStroke(1.dp, SurfaceLightBorder),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Column(
                            modifier = Modifier
                                .fillMaxWidth()
                                .padding(16.dp),
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text("Subtotal", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                Text(RestaurantRepository.formatRupiah(uiState.subtotal), fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                            }

                            if (uiState.discountPercent > 0) {
                                Row(
                                    modifier = Modifier.fillMaxWidth(),
                                    horizontalArrangement = Arrangement.SpaceBetween
                                ) {
                                    Text("Diskon (${uiState.discountPercent.toInt()}%)", fontSize = 13.sp, color = ErrorRed)
                                    Text("- ${RestaurantRepository.formatRupiah(uiState.discountAmount)}", fontSize = 13.sp, fontWeight = FontWeight.SemiBold, color = ErrorRed)
                                }
                            }

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween
                            ) {
                                Text("PB1 / Pajak Resto (${uiState.taxPercent.toInt()}%)", fontSize = 13.sp, color = MaterialTheme.colorScheme.onSurfaceVariant)
                                Text(RestaurantRepository.formatRupiah(uiState.taxAmount), fontSize = 13.sp, fontWeight = FontWeight.SemiBold)
                            }

                            HorizontalDivider(modifier = Modifier.padding(vertical = 4.dp), color = SurfaceLightBorder.copy(alpha = 0.5f))

                            Row(
                                modifier = Modifier.fillMaxWidth(),
                                horizontalArrangement = Arrangement.SpaceBetween,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Text(
                                    text = "Total",
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = MaterialTheme.colorScheme.onSurface
                                )
                                Text(
                                    text = RestaurantRepository.formatRupiah(uiState.grandTotal),
                                    fontSize = 20.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = PurplePrimary
                                )
                            }
                            Text(
                                text = "Includes 10% Service & PB1 Tax",
                                fontSize = 10.sp,
                                color = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }
                }
            }

            // Bottom Actions: Save Pending Table Order or Pay Now
            Surface(
                color = MaterialTheme.colorScheme.surface,
                tonalElevation = 6.dp,
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 20.dp, vertical = 12.dp),
                    horizontalArrangement = Arrangement.spacedBy(10.dp)
                ) {
                    if (uiState.orderType == OrderType.DINE_IN && uiState.selectedTable != null) {
                        OutlinedButton(
                            onClick = onSavePendingOrder,
                            modifier = Modifier
                                .weight(1f)
                                .height(52.dp)
                                .testTag("save_table_order_btn"),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Icon(Icons.Default.Save, contentDescription = null, modifier = Modifier.size(18.dp))
                            Spacer(modifier = Modifier.width(6.dp))
                            Text("Simpan Meja", fontSize = 13.sp, fontWeight = FontWeight.Bold)
                        }
                    }

                    Button(
                        onClick = onProceedPayment,
                        modifier = Modifier
                            .weight(1f)
                            .height(52.dp)
                            .testTag("proceed_payment_btn"),
                        shape = RoundedCornerShape(16.dp),
                        colors = ButtonDefaults.buttonColors(containerColor = PurplePrimary)
                    ) {
                        Icon(Icons.Default.Payments, contentDescription = null, modifier = Modifier.size(18.dp))
                        Spacer(modifier = Modifier.width(6.dp))
                        Text("PROSES PEMBAYARAN", fontSize = 13.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}

@Composable
private fun OrderTypeFilterChip(
    label: String,
    icon: ImageVector,
    selected: Boolean,
    onClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    FilterChip(
        selected = selected,
        onClick = onClick,
        label = { Text(label, fontSize = 12.sp, fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal) },
        leadingIcon = { Icon(icon, contentDescription = null, modifier = Modifier.size(16.dp)) },
        shape = RoundedCornerShape(20.dp),
        colors = FilterChipDefaults.filterChipColors(
            selectedContainerColor = PurplePrimary,
            selectedLabelColor = Color.White,
            selectedLeadingIconColor = Color.White,
            containerColor = SurfaceLightChip,
            labelColor = TextSecondaryLight
        ),
        modifier = modifier
    )
}

private fun getCartIcon(categoryName: String): ImageVector {
    return when {
        categoryName.contains("Minum", ignoreCase = true) || categoryName.contains("Teh", ignoreCase = true) || categoryName.contains("Kopi", ignoreCase = true) -> Icons.Default.LocalBar
        categoryName.contains("Snack", ignoreCase = true) || categoryName.contains("Camilan", ignoreCase = true) || categoryName.contains("Pisang", ignoreCase = true) -> Icons.Default.BakeryDining
        categoryName.contains("Ikan", ignoreCase = true) || categoryName.contains("Laut", ignoreCase = true) -> Icons.Default.SetMeal
        categoryName.contains("Nasi", ignoreCase = true) || categoryName.contains("Ayam", ignoreCase = true) || categoryName.contains("Goreng", ignoreCase = true) -> Icons.Default.LunchDining
        else -> Icons.Default.Restaurant
    }
}
