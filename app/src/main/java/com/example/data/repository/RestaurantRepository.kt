package com.example.data.repository

import com.example.data.database.AppDatabase
import com.example.data.model.CartItem
import com.example.data.model.CategoryEntity
import com.example.data.model.MenuEntity
import com.example.data.model.OrderEntity
import com.example.data.model.OrderItemEntity
import com.example.data.model.OrderStatus
import com.example.data.model.OrderType
import com.example.data.model.OrderWithItems
import com.example.data.model.PaymentMethod
import com.example.data.model.TableEntity
import com.example.data.model.TableStatus
import kotlinx.coroutines.flow.Flow
import java.text.NumberFormat
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale
import kotlin.random.Random

class RestaurantRepository(private val database: AppDatabase) {

    private val categoryDao = database.categoryDao()
    private val menuDao = database.menuDao()
    private val tableDao = database.tableDao()
    private val orderDao = database.orderDao()

    val allCategories: Flow<List<CategoryEntity>> = categoryDao.getAllCategories()
    val allMenus: Flow<List<MenuEntity>> = menuDao.getAllMenus()
    val allTables: Flow<List<TableEntity>> = tableDao.getAllTables()
    val allOrdersWithItems: Flow<List<OrderWithItems>> = orderDao.getAllOrdersWithItems()

    fun getMenusByCategory(categoryId: Int): Flow<List<MenuEntity>> = menuDao.getMenusByCategory(categoryId)
    fun searchMenus(query: String): Flow<List<MenuEntity>> = menuDao.searchMenus(query)
    fun getOrdersByStatus(status: OrderStatus): Flow<List<OrderWithItems>> = orderDao.getOrdersByStatus(status)

    suspend fun getOrderById(orderId: Long): OrderWithItems? = orderDao.getOrderWithItemsById(orderId)

    // === Menu Management ===
    suspend fun insertMenu(menu: MenuEntity): Long = menuDao.insertMenu(menu)
    suspend fun updateMenu(menu: MenuEntity) = menuDao.updateMenu(menu)
    suspend fun deleteMenu(menu: MenuEntity) = menuDao.deleteMenu(menu)
    suspend fun updateStock(menuId: Int, newStock: Int) {
        val menu = menuDao.getMenuById(menuId)
        if (menu != null) {
            menuDao.updateMenu(menu.copy(stock = newStock))
        }
    }

    // === Category Management ===
    suspend fun insertCategory(category: CategoryEntity): Long = categoryDao.insertCategory(category)
    suspend fun deleteCategory(category: CategoryEntity) = categoryDao.deleteCategory(category)

    // === Table Management ===
    suspend fun insertTable(table: TableEntity): Long = tableDao.insertTable(table)
    suspend fun updateTable(table: TableEntity) = tableDao.updateTable(table)
    suspend fun updateTableStatus(tableId: Int, status: TableStatus, activeOrderId: Long? = null) {
        tableDao.updateTableStatus(tableId, status, activeOrderId)
    }

    // === Checkout & Payment Engine (100% Offline) ===
    suspend fun processCheckout(
        cartItems: List<CartItem>,
        table: TableEntity?,
        customerName: String,
        orderType: OrderType,
        discountPercent: Double,
        taxPercent: Double,
        servicePercent: Double,
        paymentMethod: PaymentMethod,
        amountPaid: Double,
        notes: String = "",
        cashierName: String = "Kasir Resto",
        isPaidNow: Boolean = true
    ): OrderWithItems {
        val timestamp = System.currentTimeMillis()
        val dateStr = SimpleDateFormat("yyyyMMdd", Locale.getDefault()).format(Date(timestamp))
        val randomSuffix = Random.nextInt(1000, 9999)
        val invoiceNumber = "INV-$dateStr-$randomSuffix"

        val subtotal = cartItems.sumOf { it.subtotal }
        val discountAmount = (subtotal * (discountPercent / 100.0))
        val afterDiscount = subtotal - discountAmount
        val taxAmount = (afterDiscount * (taxPercent / 100.0))
        val serviceAmount = (afterDiscount * (servicePercent / 100.0))
        val grandTotal = afterDiscount + taxAmount + serviceAmount

        val finalStatus = if (isPaidNow) OrderStatus.PAID else OrderStatus.PENDING
        val finalPaid = if (isPaidNow) amountPaid else 0.0
        val changeAmount = if (isPaidNow && amountPaid >= grandTotal) amountPaid - grandTotal else 0.0

        val referenceNumber = when (paymentMethod) {
            PaymentMethod.QRIS_OFFLINE -> "QRIS-OFF-$timestamp"
            PaymentMethod.DEBIT_CARD -> "EDC-DEBIT-${Random.nextInt(100000, 999999)}"
            PaymentMethod.CREDIT_CARD -> "EDC-CC-${Random.nextInt(100000, 999999)}"
            PaymentMethod.TRANSFER_BANK -> "TF-VA-${Random.nextInt(10000000, 99999999)}"
            PaymentMethod.CASH -> "CASH-$randomSuffix"
        }

        val order = OrderEntity(
            invoiceNumber = invoiceNumber,
            tableId = table?.id,
            tableName = table?.let { "Meja ${it.tableNumber}" } ?: (if (orderType == OrderType.TAKEAWAY) "Takeaway / Bungkus" else "Delivery"),
            customerName = if (customerName.isBlank()) (table?.let { "Tamu Meja ${it.tableNumber}" } ?: "Pelanggan") else customerName,
            orderType = orderType,
            subtotal = subtotal,
            discountPercent = discountPercent,
            discountAmount = discountAmount,
            taxRatePercent = taxPercent,
            taxAmount = taxAmount,
            serviceRatePercent = servicePercent,
            serviceAmount = serviceAmount,
            grandTotal = grandTotal,
            paymentMethod = paymentMethod,
            amountPaid = finalPaid,
            changeAmount = changeAmount,
            status = finalStatus,
            notes = notes,
            cashierName = cashierName,
            referenceNumber = referenceNumber,
            createdAt = timestamp
        )

        val orderId = orderDao.insertOrder(order)

        // Insert Order Items and reduce stock atomically
        val orderItems = cartItems.map { item ->
            menuDao.reduceStock(item.menu.id, item.quantity)
            OrderItemEntity(
                orderId = orderId,
                menuId = item.menu.id,
                menuName = item.menu.name,
                categoryName = item.menu.categoryName,
                unitPrice = item.menu.price,
                quantity = item.quantity,
                subtotal = item.subtotal,
                notes = item.notes
            )
        }
        orderDao.insertOrderItems(orderItems)

        // Update table status if dine in
        table?.let {
            if (isPaidNow) {
                // If paid immediately, table remains available
                tableDao.updateTableStatus(it.id, TableStatus.AVAILABLE, null)
            } else {
                // If saved pending, mark table as occupied with active order
                tableDao.updateTableStatus(it.id, TableStatus.OCCUPIED, orderId)
            }
        }

        return OrderWithItems(order = order.copy(id = orderId), items = orderItems)
    }

    // === Settle Pending Bill ===
    suspend fun settlePendingOrder(
        orderId: Long,
        paymentMethod: PaymentMethod,
        amountPaid: Double
    ): OrderWithItems? {
        val orderWithItems = orderDao.getOrderWithItemsById(orderId) ?: return null
        val order = orderWithItems.order
        val grandTotal = order.grandTotal
        val change = if (amountPaid >= grandTotal) amountPaid - grandTotal else 0.0

        val referenceNumber = when (paymentMethod) {
            PaymentMethod.QRIS_OFFLINE -> "QRIS-OFF-${System.currentTimeMillis()}"
            PaymentMethod.DEBIT_CARD -> "EDC-DEBIT-${Random.nextInt(100000, 999999)}"
            PaymentMethod.CREDIT_CARD -> "EDC-CC-${Random.nextInt(100000, 999999)}"
            PaymentMethod.TRANSFER_BANK -> "TF-VA-${Random.nextInt(10000000, 99999999)}"
            PaymentMethod.CASH -> "CASH-${Random.nextInt(1000, 9999)}"
        }

        val updatedOrder = order.copy(
            status = OrderStatus.PAID,
            paymentMethod = paymentMethod,
            amountPaid = amountPaid,
            changeAmount = change,
            referenceNumber = referenceNumber
        )
        orderDao.updateOrder(updatedOrder)

        // Release table if occupied
        order.tableId?.let { tableId ->
            tableDao.updateTableStatus(tableId, TableStatus.AVAILABLE, null)
        }

        return OrderWithItems(order = updatedOrder, items = orderWithItems.items)
    }

    // === Void / Cancel Order ===
    suspend fun cancelOrder(orderId: Long) {
        val orderWithItems = orderDao.getOrderWithItemsById(orderId) ?: return
        // Restore stock
        for (item in orderWithItems.items) {
            menuDao.restoreStock(item.menuId, item.quantity)
        }
        orderDao.cancelOrder(orderId)

        // Free table if associated
        orderWithItems.order.tableId?.let { tableId ->
            tableDao.updateTableStatus(tableId, TableStatus.AVAILABLE, null)
        }
    }

    companion object {
        fun formatRupiah(amount: Double): String {
            val format = NumberFormat.getCurrencyInstance(Locale("id", "ID"))
            return format.format(amount).replace("Rp", "Rp ").replace(",00", "")
        }

        fun formatTimestamp(timestamp: Long): String {
            val sdf = SimpleDateFormat("dd MMM yyyy, HH:mm", Locale("id", "ID"))
            return sdf.format(Date(timestamp))
        }

        fun formatDateOnly(timestamp: Long): String {
            val sdf = SimpleDateFormat("EEEE, dd MMMM yyyy", Locale("id", "ID"))
            return sdf.format(Date(timestamp))
        }
    }
}
