package com.example.data.dao

import androidx.room.Dao
import androidx.room.Delete
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction
import androidx.room.Update
import com.example.data.model.CategoryEntity
import com.example.data.model.MenuEntity
import com.example.data.model.OrderEntity
import com.example.data.model.OrderItemEntity
import com.example.data.model.OrderStatus
import com.example.data.model.OrderWithItems
import com.example.data.model.TableEntity
import com.example.data.model.TableStatus
import kotlinx.coroutines.flow.Flow

@Dao
interface CategoryDao {
    @Query("SELECT * FROM categories ORDER BY displayOrder ASC, id ASC")
    fun getAllCategories(): Flow<List<CategoryEntity>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertCategory(category: CategoryEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(categories: List<CategoryEntity>)

    @Update
    suspend fun updateCategory(category: CategoryEntity)

    @Delete
    suspend fun deleteCategory(category: CategoryEntity)
}

@Dao
interface MenuDao {
    @Query("SELECT * FROM menus ORDER BY categoryId ASC, name ASC")
    fun getAllMenus(): Flow<List<MenuEntity>>

    @Query("SELECT * FROM menus WHERE categoryId = :categoryId ORDER BY name ASC")
    fun getMenusByCategory(categoryId: Int): Flow<List<MenuEntity>>

    @Query("SELECT * FROM menus WHERE name LIKE '%' || :query || '%' OR description LIKE '%' || :query || '%'")
    fun searchMenus(query: String): Flow<List<MenuEntity>>

    @Query("SELECT * FROM menus WHERE id = :menuId")
    suspend fun getMenuById(menuId: Int): MenuEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertMenu(menu: MenuEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(menus: List<MenuEntity>)

    @Update
    suspend fun updateMenu(menu: MenuEntity)

    @Delete
    suspend fun deleteMenu(menu: MenuEntity)

    @Query("UPDATE menus SET stock = stock - :quantity WHERE id = :menuId AND stock >= :quantity")
    suspend fun reduceStock(menuId: Int, quantity: Int): Int

    @Query("UPDATE menus SET stock = stock + :quantity WHERE id = :menuId")
    suspend fun restoreStock(menuId: Int, quantity: Int): Int
}

@Dao
interface TableDao {
    @Query("SELECT * FROM tables ORDER BY id ASC")
    fun getAllTables(): Flow<List<TableEntity>>

    @Query("SELECT * FROM tables WHERE status = :status ORDER BY id ASC")
    fun getTablesByStatus(status: TableStatus): Flow<List<TableEntity>>

    @Query("SELECT * FROM tables WHERE id = :id")
    suspend fun getTableById(id: Int): TableEntity?

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTable(table: TableEntity): Long

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(tables: List<TableEntity>)

    @Update
    suspend fun updateTable(table: TableEntity)

    @Query("UPDATE tables SET status = :status, activeOrderId = :orderId WHERE id = :tableId")
    suspend fun updateTableStatus(tableId: Int, status: TableStatus, orderId: Long?)

    @Delete
    suspend fun deleteTable(table: TableEntity)
}

@Dao
interface OrderDao {
    @Transaction
    @Query("SELECT * FROM orders ORDER BY createdAt DESC")
    fun getAllOrdersWithItems(): Flow<List<OrderWithItems>>

    @Transaction
    @Query("SELECT * FROM orders WHERE status = :status ORDER BY createdAt DESC")
    fun getOrdersByStatus(status: OrderStatus): Flow<List<OrderWithItems>>

    @Transaction
    @Query("SELECT * FROM orders WHERE id = :orderId")
    suspend fun getOrderWithItemsById(orderId: Long): OrderWithItems?

    @Transaction
    @Query("SELECT * FROM orders WHERE createdAt >= :startTimestamp AND createdAt <= :endTimestamp ORDER BY createdAt DESC")
    fun getOrdersBetween(startTimestamp: Long, endTimestamp: Long): Flow<List<OrderWithItems>>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrder(order: OrderEntity): Long

    @Update
    suspend fun updateOrder(order: OrderEntity)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertOrderItems(items: List<OrderItemEntity>)

    @Query("DELETE FROM order_items WHERE orderId = :orderId")
    suspend fun deleteOrderItemsByOrderId(orderId: Long)

    @Query("UPDATE orders SET status = 'CANCELLED' WHERE id = :orderId")
    suspend fun cancelOrder(orderId: Long)
}
