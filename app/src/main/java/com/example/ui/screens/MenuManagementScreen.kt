package com.example.ui.screens

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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Add
import androidx.compose.material.icons.filled.Delete
import androidx.compose.material.icons.filled.Edit
import androidx.compose.material.icons.filled.Inventory
import androidx.compose.material.icons.filled.Remove
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Card
import androidx.compose.material3.CardDefaults
import androidx.compose.material3.DropdownMenuItem
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.ExposedDropdownMenuBox
import androidx.compose.material3.ExposedDropdownMenuDefaults
import androidx.compose.material3.FilledTonalIconButton
import androidx.compose.material3.FloatingActionButton
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.IconButtonDefaults
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.OutlinedButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.Scaffold
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
import com.example.data.model.CategoryEntity
import com.example.data.model.MenuEntity
import com.example.data.repository.RestaurantRepository
import com.example.ui.components.CategoryFilterTabs
import com.example.ui.theme.AmberPrimary
import com.example.ui.theme.ErrorRed
import com.example.ui.theme.SuccessGreen
import com.example.ui.viewmodel.RestaurantViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MenuManagementScreen(
    categories: List<CategoryEntity>,
    menus: List<MenuEntity>,
    viewModel: RestaurantViewModel,
    modifier: Modifier = Modifier
) {
    var selectedCategoryId by remember { mutableStateOf<Int?>(null) }
    var showAddMenuDialog by remember { mutableStateOf(false) }
    var menuToEdit by remember { mutableStateOf<MenuEntity?>(null) }

    val filteredMenus = if (selectedCategoryId == null) menus else menus.filter { it.categoryId == selectedCategoryId }

    Scaffold(
        modifier = modifier.fillMaxSize(),
        floatingActionButton = {
            FloatingActionButton(
                onClick = { showAddMenuDialog = true },
                containerColor = AmberPrimary,
                contentColor = Color.White,
                shape = RoundedCornerShape(16.dp),
                modifier = Modifier.testTag("add_menu_fab")
            ) {
                Icon(imageVector = Icons.Default.Add, contentDescription = "Tambah Menu Baru")
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
                        text = "Kelola Menu & Stok Bahan",
                        fontSize = 20.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "Atur harga jual, kategori, dan stok hidangan resto",
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
            }

            // Categories Filter
            CategoryFilterTabs(
                categories = categories,
                selectedCategoryId = selectedCategoryId,
                onCategorySelected = { selectedCategoryId = it }
            )

            // Menus List
            LazyColumn(
                modifier = Modifier
                    .fillMaxWidth()
                    .weight(1f)
                    .padding(horizontal = 16.dp),
                contentPadding = PaddingValues(top = 8.dp, bottom = 80.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                items(filteredMenus, key = { it.id }) { menu ->
                    MenuManagementItemCard(
                        menu = menu,
                        onStockChange = { newStock -> viewModel.updateMenuStock(menu.id, newStock) },
                        onEdit = { menuToEdit = menu },
                        onDelete = { viewModel.deleteMenu(menu) }
                    )
                }
            }
        }
    }

    // Add or Edit Menu Dialog
    if (showAddMenuDialog || menuToEdit != null) {
        MenuFormDialog(
            menu = menuToEdit,
            categories = categories,
            onDismiss = {
                showAddMenuDialog = false
                menuToEdit = null
            },
            onSave = { name, catId, catName, price, costPrice, desc, stock ->
                if (menuToEdit != null) {
                    viewModel.updateMenu(
                        menuToEdit!!.copy(
                            name = name,
                            categoryId = catId,
                            categoryName = catName,
                            price = price,
                            costPrice = costPrice,
                            description = desc,
                            stock = stock
                        )
                    )
                } else {
                    viewModel.addNewMenu(
                        name = name,
                        categoryId = catId,
                        categoryName = catName,
                        price = price,
                        costPrice = costPrice,
                        description = desc,
                        stock = stock
                    )
                }
                showAddMenuDialog = false
                menuToEdit = null
            }
        )
    }
}

@Composable
private fun MenuManagementItemCard(
    menu: MenuEntity,
    onStockChange: (Int) -> Unit,
    onEdit: () -> Unit,
    onDelete: () -> Unit
) {
    Card(
        modifier = Modifier.fillMaxWidth(),
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
                Column(modifier = Modifier.weight(1f)) {
                    Text(
                        text = menu.name,
                        fontSize = 15.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface
                    )
                    Text(
                        text = "${menu.categoryName} • ${RestaurantRepository.formatRupiah(menu.price)}",
                        fontSize = 12.sp,
                        color = AmberPrimary,
                        fontWeight = FontWeight.SemiBold
                    )
                }

                Row {
                    IconButton(onClick = onEdit, modifier = Modifier.size(32.dp)) {
                        Icon(Icons.Default.Edit, contentDescription = "Edit", tint = AmberPrimary, modifier = Modifier.size(18.dp))
                    }
                    IconButton(onClick = onDelete, modifier = Modifier.size(32.dp)) {
                        Icon(Icons.Default.Delete, contentDescription = "Hapus", tint = ErrorRed, modifier = Modifier.size(18.dp))
                    }
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Stock Quick Editor Bar
            Surface(
                shape = RoundedCornerShape(10.dp),
                color = MaterialTheme.colorScheme.surfaceVariant.copy(alpha = 0.4f),
                modifier = Modifier.fillMaxWidth()
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(horizontal = 12.dp, vertical = 6.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Icon(
                            imageVector = Icons.Default.Inventory,
                            contentDescription = null,
                            tint = if (menu.stock > 0) SuccessGreen else ErrorRed,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = if (menu.stock > 0) "Sisa Stok: ${menu.stock} ${menu.unit}" else "Stok Habis (0)",
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold,
                            color = if (menu.stock > 0) MaterialTheme.colorScheme.onSurface else ErrorRed
                        )
                    }

                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        FilledTonalIconButton(
                            onClick = { if (menu.stock > 0) onStockChange(menu.stock - 1) },
                            modifier = Modifier.size(28.dp),
                            shape = CircleShape
                        ) {
                            Icon(Icons.Default.Remove, contentDescription = "Kurang Stok", modifier = Modifier.size(14.dp))
                        }

                        FilledTonalIconButton(
                            onClick = { onStockChange(menu.stock + 5) },
                            modifier = Modifier.size(28.dp),
                            shape = CircleShape,
                            colors = IconButtonDefaults.filledTonalIconButtonColors(containerColor = AmberPrimary, contentColor = Color.White)
                        ) {
                            Icon(Icons.Default.Add, contentDescription = "Tambah Stok", modifier = Modifier.size(14.dp))
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
private fun MenuFormDialog(
    menu: MenuEntity?,
    categories: List<CategoryEntity>,
    onDismiss: () -> Unit,
    onSave: (String, Int, String, Double, Double, String, Int) -> Unit
) {
    var name by remember { mutableStateOf(menu?.name ?: "") }
    var selectedCategory by remember { mutableStateOf(categories.find { it.id == menu?.categoryId } ?: categories.firstOrNull()) }
    var priceText by remember { mutableStateOf(menu?.price?.toLong()?.toString() ?: "") }
    var costPriceText by remember { mutableStateOf(menu?.costPrice?.toLong()?.toString() ?: "") }
    var stockText by remember { mutableStateOf(menu?.stock?.toString() ?: "50") }
    var description by remember { mutableStateOf(menu?.description ?: "") }
    var isCategoryDropdownExpanded by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = {
            Text(
                text = if (menu != null) "Edit Menu Makanan" else "Tambah Menu Baru",
                fontWeight = FontWeight.Bold
            )
        },
        text = {
            Column(verticalArrangement = Arrangement.spacedBy(10.dp)) {
                OutlinedTextField(
                    value = name,
                    onValueChange = { name = it },
                    label = { Text("Nama Hidangan") },
                    singleLine = true,
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )

                // Category selector
                ExposedDropdownMenuBox(
                    expanded = isCategoryDropdownExpanded,
                    onExpandedChange = { isCategoryDropdownExpanded = it }
                ) {
                    OutlinedTextField(
                        value = selectedCategory?.name ?: "Pilih Kategori",
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Kategori") },
                        trailingIcon = { ExposedDropdownMenuDefaults.TrailingIcon(expanded = isCategoryDropdownExpanded) },
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier
                            .fillMaxWidth()
                            .menuAnchor()
                    )
                    ExposedDropdownMenu(
                        expanded = isCategoryDropdownExpanded,
                        onDismissRequest = { isCategoryDropdownExpanded = false }
                    ) {
                        categories.forEach { category ->
                            DropdownMenuItem(
                                text = { Text(category.name) },
                                onClick = {
                                    selectedCategory = category
                                    isCategoryDropdownExpanded = false
                                }
                            )
                        }
                    }
                }

                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    OutlinedTextField(
                        value = priceText,
                        onValueChange = { priceText = it.filter { ch -> ch.isDigit() } },
                        label = { Text("Harga Jual (Rp)") },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.weight(1f)
                    )
                    OutlinedTextField(
                        value = stockText,
                        onValueChange = { stockText = it.filter { ch -> ch.isDigit() } },
                        label = { Text("Stok Awal") },
                        singleLine = true,
                        shape = RoundedCornerShape(12.dp),
                        modifier = Modifier.weight(1f)
                    )
                }

                OutlinedTextField(
                    value = description,
                    onValueChange = { description = it },
                    label = { Text("Deskripsi Menu (Opsional)") },
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )
            }
        },
        confirmButton = {
            Button(
                onClick = {
                    if (name.isNotBlank() && selectedCategory != null && priceText.isNotBlank()) {
                        onSave(
                            name.trim(),
                            selectedCategory!!.id,
                            selectedCategory!!.name,
                            priceText.toDoubleOrNull() ?: 0.0,
                            costPriceText.toDoubleOrNull() ?: 0.0,
                            description.trim(),
                            stockText.toIntOrNull() ?: 0
                        )
                    }
                },
                colors = ButtonDefaults.buttonColors(containerColor = AmberPrimary),
                shape = RoundedCornerShape(10.dp)
            ) {
                Text("Simpan")
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
