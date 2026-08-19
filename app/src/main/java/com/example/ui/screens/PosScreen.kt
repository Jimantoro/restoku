package com.example.ui.screens

import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.grid.GridCells
import androidx.compose.foundation.lazy.grid.LazyVerticalGrid
import androidx.compose.foundation.lazy.grid.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Fastfood
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.model.CategoryEntity
import com.example.data.model.MenuEntity
import com.example.data.model.TableEntity
import com.example.ui.components.CartBottomSummary
import com.example.ui.components.CartDetailSheet
import com.example.ui.components.CategoryFilterTabs
import com.example.ui.components.MenuCard
import com.example.ui.components.OrderItemNotesDialog
import com.example.ui.components.TopAppBarHeader
import com.example.ui.viewmodel.PosUiState
import com.example.ui.viewmodel.RestaurantViewModel

@Composable
fun PosScreen(
    uiState: PosUiState,
    categories: List<CategoryEntity>,
    menus: List<MenuEntity>,
    tables: List<TableEntity>,
    viewModel: RestaurantViewModel,
    onNavigateToTables: () -> Unit,
    modifier: Modifier = Modifier
) {
    var showCartDetail by remember { mutableStateOf(false) }

    Box(modifier = modifier.fillMaxSize()) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Header with search & table selector
            TopAppBarHeader(
                searchQuery = uiState.searchQuery,
                onSearchChange = { viewModel.setSearchQuery(it) },
                selectedTable = uiState.selectedTable,
                onTableClick = onNavigateToTables
            )

            // Category Filter Chips
            CategoryFilterTabs(
                categories = categories,
                selectedCategoryId = uiState.selectedCategoryId,
                onCategorySelected = { viewModel.selectCategory(it) }
            )

            // Menu Grid
            if (menus.isEmpty()) {
                Box(
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .padding(24.dp),
                    contentAlignment = Alignment.Center
                ) {
                    Column(horizontalAlignment = Alignment.CenterHorizontally) {
                        Icon(
                            imageVector = Icons.Default.Fastfood,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.onSurfaceVariant.copy(alpha = 0.5f),
                            modifier = Modifier.size(54.dp)
                        )
                        Spacer(modifier = Modifier.height(12.dp))
                        Text(
                            text = "Menu tidak ditemukan",
                            fontSize = 16.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.onSurface
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = "Coba ubah kata kunci pencarian atau pilih kategori lain.",
                            fontSize = 13.sp,
                            color = MaterialTheme.colorScheme.onSurfaceVariant,
                            textAlign = TextAlign.Center
                        )
                    }
                }
            } else {
                LazyVerticalGrid(
                    columns = GridCells.Adaptive(minSize = 160.dp),
                    contentPadding = PaddingValues(
                        start = 16.dp,
                        end = 16.dp,
                        top = 8.dp,
                        bottom = if (uiState.cartItems.isNotEmpty()) 90.dp else 16.dp
                    ),
                    horizontalArrangement = Arrangement.spacedBy(12.dp),
                    verticalArrangement = Arrangement.spacedBy(12.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .weight(1f)
                        .testTag("menu_grid")
                ) {
                    items(menus, key = { it.id }) { menu ->
                        val cartItem = uiState.cartItems.find { it.menu.id == menu.id }
                        MenuCard(
                            menu = menu,
                            cartItem = cartItem,
                            onAddToCart = { viewModel.addToCart(menu) },
                            onQuantityChange = { qty -> viewModel.updateCartQuantity(menu.id, qty) },
                            onOpenNotes = { item -> viewModel.openNotesDialog(item) }
                        )
                    }
                }
            }
        }

        // Floating Sticky Cart Summary
        CartBottomSummary(
            uiState = uiState,
            onOpenCartDetail = { showCartDetail = true },
            modifier = Modifier.align(Alignment.BottomCenter)
        )
    }

    // Cart Details Sheet
    if (showCartDetail && uiState.cartItems.isNotEmpty()) {
        CartDetailSheet(
            uiState = uiState,
            tables = tables,
            onDismiss = { showCartDetail = false },
            onQuantityChange = { menuId, qty -> viewModel.updateCartQuantity(menuId, qty) },
            onRemoveItem = { menuId -> viewModel.removeFromCart(menuId) },
            onClearCart = {
                viewModel.clearCart()
                showCartDetail = false
            },
            onOpenNotes = { item -> viewModel.openNotesDialog(item) },
            onCustomerNameChange = { viewModel.setCustomerName(it) },
            onOrderTypeChange = { viewModel.setOrderType(it) },
            onTableSelect = { viewModel.selectTable(it) },
            onDiscountChange = { viewModel.setDiscountPercent(it) },
            onProceedPayment = {
                showCartDetail = false
                viewModel.openPaymentDialog()
            },
            onSavePendingOrder = {
                showCartDetail = false
                viewModel.processPayment(
                    paymentMethod = com.example.data.model.PaymentMethod.CASH,
                    amountPaid = 0.0,
                    isPaidNow = false
                )
            }
        )
    }

    // Notes Dialog
    uiState.activeNotesItem?.let { notesItem ->
        OrderItemNotesDialog(
            item = notesItem,
            onSaveNotes = { note -> viewModel.setItemNotes(notesItem.menu.id, note) },
            onDismiss = { viewModel.closeNotesDialog() }
        )
    }
}
