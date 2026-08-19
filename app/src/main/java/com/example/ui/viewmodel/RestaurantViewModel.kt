package com.example.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.data.model.CartItem
import com.example.data.model.CategoryEntity
import com.example.data.model.MenuEntity
import com.example.data.model.OrderEntity
import com.example.data.model.OrderStatus
import com.example.data.model.OrderType
import com.example.data.model.OrderWithItems
import com.example.data.model.PaymentMethod
import com.example.data.model.TableEntity
import com.example.data.model.TableStatus
import com.example.data.repository.RestaurantRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
import kotlinx.coroutines.launch

enum class AppNavTab {
    POS_CASHIER,
    TABLES,
    TRANSACTIONS,
    REPORTS,
    MENU_MANAGEMENT
}

data class PosUiState(
    val currentTab: AppNavTab = AppNavTab.POS_CASHIER,
    val selectedCategoryId: Int? = null,
    val searchQuery: String = "",
    val selectedTable: TableEntity? = null,
    val customerName: String = "",
    val orderType: OrderType = OrderType.DINE_IN,
    val cartItems: List<CartItem> = emptyList(),
    val discountPercent: Double = 0.0,
    val taxPercent: Double = 10.0, // 10% standard restaurant tax PB1
    val servicePercent: Double = 0.0, // Optional service charge
    val cashierName: String = "Kasir Resto",
    val activeNotesItem: CartItem? = null, // For editing item notes
    val showPaymentDialog: Boolean = false,
    val showReceiptDialog: Boolean = false,
    val lastCompletedOrder: OrderWithItems? = null,
    val activeSettleOrder: OrderWithItems? = null, // For settling a pending bill from Table or History
    val notificationMessage: String? = null,
    val isOfflineMode: Boolean = true // Always true (100% Offline Capable)
) {
    val subtotal: Double
        get() = cartItems.sumOf { it.subtotal }

    val discountAmount: Double
        get() = subtotal * (discountPercent / 100.0)

    val afterDiscount: Double
        get() = subtotal - discountAmount

    val taxAmount: Double
        get() = afterDiscount * (taxPercent / 100.0)

    val serviceAmount: Double
        get() = afterDiscount * (servicePercent / 100.0)

    val grandTotal: Double
        get() = afterDiscount + taxAmount + serviceAmount

    val totalItemCount: Int
        get() = cartItems.sumOf { it.quantity }
}

class RestaurantViewModel(
    private val repository: RestaurantRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(PosUiState())
    val uiState: StateFlow<PosUiState> = _uiState.asStateFlow()

    val categories: StateFlow<List<CategoryEntity>> = repository.allCategories
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val tables: StateFlow<List<TableEntity>> = repository.allTables
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val orders: StateFlow<List<OrderWithItems>> = repository.allOrdersWithItems
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val _rawMenus = repository.allMenus

    // Filtered menus based on category & search query
    val filteredMenus: StateFlow<List<MenuEntity>> = combine(
        _rawMenus,
        _uiState
    ) { menus, state ->
        menus.filter { menu ->
            val matchesCategory = state.selectedCategoryId == null || menu.categoryId == state.selectedCategoryId
            val matchesSearch = state.searchQuery.isBlank() ||
                    menu.name.contains(state.searchQuery, ignoreCase = true) ||
                    menu.description.contains(state.searchQuery, ignoreCase = true)
            matchesCategory && matchesSearch
        }
    }.stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    // === Navigation ===
    fun setTab(tab: AppNavTab) {
        _uiState.update { it.copy(currentTab = tab) }
    }

    fun selectCategory(categoryId: Int?) {
        _uiState.update { it.copy(selectedCategoryId = categoryId) }
    }

    fun setSearchQuery(query: String) {
        _uiState.update { it.copy(searchQuery = query) }
    }

    fun setCustomerName(name: String) {
        _uiState.update { it.copy(customerName = name) }
    }

    fun setOrderType(type: OrderType) {
        _uiState.update {
            it.copy(
                orderType = type,
                selectedTable = if (type != OrderType.DINE_IN) null else it.selectedTable
            )
        }
    }

    fun selectTable(table: TableEntity?) {
        _uiState.update {
            it.copy(
                selectedTable = table,
                orderType = if (table != null) OrderType.DINE_IN else it.orderType
            )
        }
    }

    // === Cart Operations ===
    fun addToCart(menu: MenuEntity) {
        if (menu.stock <= 0) {
            showNotification("Stok ${menu.name} habis!")
            return
        }

        _uiState.update { state ->
            val existingIndex = state.cartItems.indexOfFirst { it.menu.id == menu.id }
            val updatedItems = state.cartItems.toMutableList()

            if (existingIndex >= 0) {
                val current = updatedItems[existingIndex]
                if (current.quantity + 1 > menu.stock) {
                    showNotification("Stok maksimum tercapai (${menu.stock})")
                    return@update state
                }
                updatedItems[existingIndex] = current.copy(quantity = current.quantity + 1)
            } else {
                updatedItems.add(CartItem(menu = menu, quantity = 1))
            }
            state.copy(cartItems = updatedItems)
        }
    }

    fun updateCartQuantity(menuId: Int, newQuantity: Int) {
        _uiState.update { state ->
            val updatedItems = state.cartItems.mapNotNull { item ->
                if (item.menu.id == menuId) {
                    if (newQuantity <= 0) null
                    else if (newQuantity > item.menu.stock) {
                        showNotification("Stok tidak mencukupi (Maks: ${item.menu.stock})")
                        item.copy(quantity = item.menu.stock)
                    } else item.copy(quantity = newQuantity)
                } else item
            }
            state.copy(cartItems = updatedItems)
        }
    }

    fun removeFromCart(menuId: Int) {
        _uiState.update { state ->
            state.copy(cartItems = state.cartItems.filter { it.menu.id != menuId })
        }
    }

    fun clearCart() {
        _uiState.update {
            it.copy(
                cartItems = emptyList(),
                selectedTable = null,
                customerName = "",
                discountPercent = 0.0
            )
        }
    }

    fun setItemNotes(menuId: Int, notes: String) {
        _uiState.update { state ->
            val updated = state.cartItems.map {
                if (it.menu.id == menuId) it.copy(notes = notes) else it
            }
            state.copy(cartItems = updated, activeNotesItem = null)
        }
    }

    fun openNotesDialog(item: CartItem) {
        _uiState.update { it.copy(activeNotesItem = item) }
    }

    fun closeNotesDialog() {
        _uiState.update { it.copy(activeNotesItem = null) }
    }

    fun setDiscountPercent(percent: Double) {
        _uiState.update { it.copy(discountPercent = percent) }
    }

    fun setTaxPercent(percent: Double) {
        _uiState.update { it.copy(taxPercent = percent) }
    }

    // === Payment Dialog & Processing ===
    fun openPaymentDialog() {
        if (_uiState.value.cartItems.isEmpty()) {
            showNotification("Keranjang pesanan masih kosong!")
            return
        }
        _uiState.update { it.copy(showPaymentDialog = true) }
    }

    fun closePaymentDialog() {
        _uiState.update { it.copy(showPaymentDialog = false) }
    }

    fun processPayment(
        paymentMethod: PaymentMethod,
        amountPaid: Double,
        isPaidNow: Boolean,
        notes: String = ""
    ) {
        val state = _uiState.value
        if (state.cartItems.isEmpty()) return

        viewModelScope.launch {
            try {
                val completedOrder = repository.processCheckout(
                    cartItems = state.cartItems,
                    table = state.selectedTable,
                    customerName = state.customerName,
                    orderType = state.orderType,
                    discountPercent = state.discountPercent,
                    taxPercent = state.taxPercent,
                    servicePercent = state.servicePercent,
                    paymentMethod = paymentMethod,
                    amountPaid = amountPaid,
                    notes = notes,
                    cashierName = state.cashierName,
                    isPaidNow = isPaidNow
                )

                _uiState.update {
                    it.copy(
                        cartItems = emptyList(),
                        selectedTable = null,
                        customerName = "",
                        discountPercent = 0.0,
                        showPaymentDialog = false,
                        showReceiptDialog = isPaidNow,
                        lastCompletedOrder = completedOrder,
                        notificationMessage = if (isPaidNow) "Transaksi offline berhasil disimpan!" else "Pesanan meja berhasil disimpan!"
                    )
                }
            } catch (e: Exception) {
                showNotification("Gagal memproses pesanan: ${e.message}")
            }
        }
    }

    // === Settle Pending Bill (from Table or History) ===
    fun openSettleDialog(order: OrderWithItems) {
        _uiState.update {
            it.copy(
                activeSettleOrder = order,
                showPaymentDialog = true
            )
        }
    }

    fun processSettlePending(
        orderId: Long,
        paymentMethod: PaymentMethod,
        amountPaid: Double
    ) {
        viewModelScope.launch {
            try {
                val result = repository.settlePendingOrder(orderId, paymentMethod, amountPaid)
                if (result != null) {
                    _uiState.update {
                        it.copy(
                            showPaymentDialog = false,
                            activeSettleOrder = null,
                            showReceiptDialog = true,
                            lastCompletedOrder = result,
                            notificationMessage = "Pembayaran tagihan berhasil diselesaikan!"
                        )
                    }
                }
            } catch (e: Exception) {
                showNotification("Gagal menyelesaikan tagihan: ${e.message}")
            }
        }
    }

    fun cancelOrder(orderId: Long) {
        viewModelScope.launch {
            try {
                repository.cancelOrder(orderId)
                showNotification("Pesanan berhasil dibatalkan & stok dikembalikan.")
            } catch (e: Exception) {
                showNotification("Gagal membatalkan pesanan: ${e.message}")
            }
        }
    }

    fun openReceiptDialog(order: OrderWithItems) {
        _uiState.update {
            it.copy(
                lastCompletedOrder = order,
                showReceiptDialog = true
            )
        }
    }

    fun closeReceiptDialog() {
        _uiState.update { it.copy(showReceiptDialog = false) }
    }

    // === Menu Management ===
    fun addNewMenu(
        name: String,
        categoryId: Int,
        categoryName: String,
        price: Double,
        costPrice: Double,
        description: String,
        stock: Int
    ) {
        viewModelScope.launch {
            repository.insertMenu(
                MenuEntity(
                    name = name,
                    categoryId = categoryId,
                    categoryName = categoryName,
                    price = price,
                    costPrice = costPrice,
                    description = description,
                    stock = stock
                )
            )
            showNotification("Menu $name berhasil ditambahkan!")
        }
    }

    fun updateMenu(menu: MenuEntity) {
        viewModelScope.launch {
            repository.updateMenu(menu)
            showNotification("Menu ${menu.name} berhasil diperbarui!")
        }
    }

    fun updateMenuStock(menuId: Int, stock: Int) {
        viewModelScope.launch {
            repository.updateStock(menuId, stock)
            showNotification("Stok berhasil diperbarui!")
        }
    }

    fun deleteMenu(menu: MenuEntity) {
        viewModelScope.launch {
            repository.deleteMenu(menu)
            showNotification("Menu ${menu.name} dihapus.")
        }
    }

    // === Table Management ===
    fun addTable(number: String, section: String, capacity: Int) {
        viewModelScope.launch {
            repository.insertTable(
                TableEntity(
                    tableNumber = number,
                    section = section,
                    capacity = capacity,
                    status = TableStatus.AVAILABLE
                )
            )
            showNotification("Meja $number berhasil ditambahkan!")
        }
    }

    fun updateTableStatus(tableId: Int, status: TableStatus) {
        viewModelScope.launch {
            repository.updateTableStatus(tableId, status, null)
            showNotification("Status meja diperbarui!")
        }
    }

    fun showNotification(msg: String) {
        _uiState.update { it.copy(notificationMessage = msg) }
    }

    fun clearNotification() {
        _uiState.update { it.copy(notificationMessage = null) }
    }
}

class RestaurantViewModelFactory(
    private val repository: RestaurantRepository
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(RestaurantViewModel::class.java)) {
            return RestaurantViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
