package com.example.data.model

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.PrimaryKey
import androidx.room.Relation

@Entity(tableName = "categories")
data class CategoryEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    val iconName: String = "Restaurant",
    val displayOrder: Int = 0
)

@Entity(tableName = "menus")
data class MenuEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val name: String,
    val categoryId: Int,
    val categoryName: String,
    val price: Double,
    val costPrice: Double = 0.0,
    val description: String = "",
    val stock: Int = 50,
    val isAvailable: Boolean = true,
    val unit: String = "porsi"
)

enum class TableStatus {
    AVAILABLE,   // Kosong
    OCCUPIED,    // Terisi
    RESERVED,    // Reservasi
    BILLING      // Minta Bill
}

@Entity(tableName = "tables")
data class TableEntity(
    @PrimaryKey(autoGenerate = true) val id: Int = 0,
    val tableNumber: String,
    val section: String = "Utama", // Utama, VIP, Outdoor, Lt 2
    val capacity: Int = 4,
    val status: TableStatus = TableStatus.AVAILABLE,
    val activeOrderId: Long? = null
)

enum class PaymentMethod {
    CASH,           // Tunai
    QRIS_OFFLINE,   // QRIS Offline
    DEBIT_CARD,     // Kartu Debit / EDC
    CREDIT_CARD,    // Kartu Kredit
    TRANSFER_BANK   // Transfer Bank
}

enum class OrderStatus {
    PENDING,
    PAID,
    CANCELLED
}

enum class OrderType {
    DINE_IN,    // Makan di Tempat
    TAKEAWAY,   // Bungkus / Bawa Pulang
    DELIVERY    // Pesan Antar
}

@Entity(tableName = "orders")
data class OrderEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val invoiceNumber: String,
    val tableId: Int? = null,
    val tableName: String = "Takeaway",
    val customerName: String = "Pelanggan",
    val orderType: OrderType = OrderType.DINE_IN,
    val subtotal: Double = 0.0,
    val discountPercent: Double = 0.0,
    val discountAmount: Double = 0.0,
    val taxRatePercent: Double = 10.0,
    val taxAmount: Double = 0.0,
    val serviceRatePercent: Double = 0.0,
    val serviceAmount: Double = 0.0,
    val grandTotal: Double = 0.0,
    val paymentMethod: PaymentMethod = PaymentMethod.CASH,
    val amountPaid: Double = 0.0,
    val changeAmount: Double = 0.0,
    val status: OrderStatus = OrderStatus.PENDING,
    val notes: String = "",
    val cashierName: String = "Kasir 1",
    val referenceNumber: String = "",
    val createdAt: Long = System.currentTimeMillis()
)

@Entity(tableName = "order_items")
data class OrderItemEntity(
    @PrimaryKey(autoGenerate = true) val id: Long = 0,
    val orderId: Long,
    val menuId: Int,
    val menuName: String,
    val categoryName: String,
    val unitPrice: Double,
    val quantity: Int,
    val subtotal: Double,
    val notes: String = ""
)

data class OrderWithItems(
    @Embedded val order: OrderEntity,
    @Relation(
        parentColumn = "id",
        entityColumn = "orderId"
    )
    val items: List<OrderItemEntity>
)

// UI Model for Cart Item during active order creation
data class CartItem(
    val menu: MenuEntity,
    val quantity: Int = 1,
    val notes: String = ""
) {
    val subtotal: Double
        get() = menu.price * quantity
}
