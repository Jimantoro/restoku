package com.example.data.database

import android.content.Context
import androidx.room.Database
import androidx.room.Room
import androidx.room.RoomDatabase
import androidx.sqlite.db.SupportSQLiteDatabase
import com.example.data.dao.CategoryDao
import com.example.data.dao.MenuDao
import com.example.data.dao.OrderDao
import com.example.data.dao.TableDao
import com.example.data.model.CategoryEntity
import com.example.data.model.MenuEntity
import com.example.data.model.OrderEntity
import com.example.data.model.OrderItemEntity
import com.example.data.model.TableEntity
import com.example.data.model.TableStatus
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch

@Database(
    entities = [
        CategoryEntity::class,
        MenuEntity::class,
        TableEntity::class,
        OrderEntity::class,
        OrderItemEntity::class
    ],
    version = 1,
    exportSchema = false
)
abstract class AppDatabase : RoomDatabase() {

    abstract fun categoryDao(): CategoryDao
    abstract fun menuDao(): MenuDao
    abstract fun tableDao(): TableDao
    abstract fun orderDao(): OrderDao

    companion object {
        @Volatile
        private var INSTANCE: AppDatabase? = null

        fun getDatabase(context: Context, scope: CoroutineScope): AppDatabase {
            return INSTANCE ?: synchronized(this) {
                val instance = Room.databaseBuilder(
                    context.applicationContext,
                    AppDatabase::class.java,
                    "resto_pos_offline.db"
                )
                    .addCallback(DatabaseCallback(scope))
                    .build()
                INSTANCE = instance
                instance
            }
        }

        private class DatabaseCallback(
            private val scope: CoroutineScope
        ) : RoomDatabase.Callback() {
            override fun onCreate(db: SupportSQLiteDatabase) {
                super.onCreate(db)
                INSTANCE?.let { database ->
                    scope.launch(Dispatchers.IO) {
                        populateInitialData(database)
                    }
                }
            }
        }

        suspend fun populateInitialData(db: AppDatabase) {
            val categoryDao = db.categoryDao()
            val menuDao = db.menuDao()
            val tableDao = db.tableDao()

            // 1. Initial Categories
            val categories = listOf(
                CategoryEntity(id = 1, name = "Makanan Utama", iconName = "Restaurant", displayOrder = 1),
                CategoryEntity(id = 2, name = "Ayam & Bebek", iconName = "LunchDining", displayOrder = 2),
                CategoryEntity(id = 3, name = "Seafood", iconName = "SetMeal", displayOrder = 3),
                CategoryEntity(id = 4, name = "Minuman Segar", iconName = "LocalBar", displayOrder = 4),
                CategoryEntity(id = 5, name = "Kopi & Teh", iconName = "Coffee", displayOrder = 5),
                CategoryEntity(id = 6, name = "Camilan & Dessert", iconName = "BakeryDining", displayOrder = 6)
            )
            categoryDao.insertAll(categories)

            // 2. Initial Menus
            val menus = listOf(
                // Makanan Utama
                MenuEntity(name = "Nasi Goreng Spesial Resto", categoryId = 1, categoryName = "Makanan Utama", price = 28000.0, costPrice = 14000.0, description = "Nasi goreng bumbu rempah dengan telur mata sapi, sosis, ayam suwir dan acar segar.", stock = 45),
                MenuEntity(name = "Nasi Goreng Seafood", categoryId = 1, categoryName = "Makanan Utama", price = 35000.0, costPrice = 18000.0, description = "Nasi goreng oriental dengan udang, cumi segar, dan bakso ikan.", stock = 30),
                MenuEntity(name = "Mie Goreng Jawa", categoryId = 1, categoryName = "Makanan Utama", price = 26000.0, costPrice = 12000.0, description = "Mie telur kenyal dimasak kuah nyemek bumbu ebi, telur, dan sayuran.", stock = 40),
                MenuEntity(name = "Soto Betawi Daging Sapi", categoryId = 1, categoryName = "Makanan Utama", price = 42000.0, costPrice = 24000.0, description = "Kuah santan susu gurih kaya rempah dengan irisan daging sapi empuk dan emping.", stock = 25),
                MenuEntity(name = "Rendang Daging Sapi Minang", categoryId = 1, categoryName = "Makanan Utama", price = 38000.0, costPrice = 22000.0, description = "Daging sapi pilihan dimasak perlahan hingga bumbu meresap hitam pekat.", stock = 20),

                // Ayam & Bebek
                MenuEntity(name = "Ayam Bakar Madu Spesial", categoryId = 2, categoryName = "Ayam & Bebek", price = 32000.0, costPrice = 16000.0, description = "Ayam pejantan bakar dengan olesan madu legit gurih disajikan sambal terasi.", stock = 35),
                MenuEntity(name = "Ayam Goreng Lengkuas", categoryId = 2, categoryName = "Ayam & Bebek", price = 30000.0, costPrice = 15000.0, description = "Ayam ungkep rempah gurih dengan taburan serundeng lengkuas renyah.", stock = 35),
                MenuEntity(name = "Bebek Goreng Sambal Korek", categoryId = 2, categoryName = "Ayam & Bebek", price = 45000.0, costPrice = 25000.0, description = "Bebek empuk tidak amis digoreng garing dengan sambal korek pedas nampol.", stock = 20),
                MenuEntity(name = "Sate Ayam Madura (10 Tusuk)", categoryId = 2, categoryName = "Ayam & Bebek", price = 34000.0, costPrice = 17000.0, description = "Daging ayam fillet bakar bumbu kacang lembut, lontong dan irisan bawang merah.", stock = 30),

                // Seafood
                MenuEntity(name = "Gurame Asam Manis", categoryId = 3, categoryName = "Seafood", price = 65000.0, costPrice = 35000.0, description = "Gurame fillet terbang digoreng renyah dengan siraman saus asam manis nanas.", stock = 15),
                MenuEntity(name = "Udang Bakar Saus Jimbaran", categoryId = 3, categoryName = "Seafood", price = 52000.0, costPrice = 28000.0, description = "Udang windu segar bakar dengan saus rempah khas Jimbaran Bali.", stock = 18),
                MenuEntity(name = "Cumi Goreng Tepung Calamari", categoryId = 3, categoryName = "Seafood", price = 38000.0, costPrice = 20000.0, description = "Cumi ring digoreng tepung crispy disajikan dengan saus tartar.", stock = 22),

                // Minuman Segar
                MenuEntity(name = "Es Teh Manis Jumbo", categoryId = 4, categoryName = "Minuman Segar", price = 7000.0, costPrice = 2000.0, description = "Teh melati wangi segar racikan khas dengan gula asli.", stock = 100),
                MenuEntity(name = "Es Jeruk Peras Murni", categoryId = 4, categoryName = "Minuman Segar", price = 14000.0, costPrice = 5000.0, description = "Perasan jeruk asli segar kaya vitamin C.", stock = 50),
                MenuEntity(name = "Jus Alpukat Kocok Cokelat", categoryId = 4, categoryName = "Minuman Segar", price = 22000.0, costPrice = 10000.0, description = "Alpukat mentega legit diblender kental dengan lelehan saus cokelat.", stock = 30),
                MenuEntity(name = "Es Kelapa Muda Jeruk", categoryId = 4, categoryName = "Minuman Segar", price = 18000.0, costPrice = 8000.0, description = "Kelapa muda segar dengan sirup gula aren dan perasan jeruk nipis.", stock = 25),

                // Kopi & Teh
                MenuEntity(name = "Kopi Susu Gula Aren", categoryId = 5, categoryName = "Kopi & Teh", price = 20000.0, costPrice = 8000.0, description = "Espresso robusta & arabica dipadukan susu segar dan gula aren murni.", stock = 50),
                MenuEntity(name = "Americano / Long Black", categoryId = 5, categoryName = "Kopi & Teh", price = 18000.0, costPrice = 6000.0, description = "Espresso ganda dengan air mineral panas / dingin.", stock = 50),
                MenuEntity(name = "Teh Tarik Panas", categoryId = 5, categoryName = "Kopi & Teh", price = 16000.0, costPrice = 6000.0, description = "Teh susu berbusa kental dan creamy khas nusantara.", stock = 40),

                // Camilan & Dessert
                MenuEntity(name = "Pisang Bakar Coklat Keju", categoryId = 6, categoryName = "Camilan & Dessert", price = 20000.0, costPrice = 8000.0, description = "Pisang raja bakar dengan topping meses cokelat, keju cheddar parut dan susu kental.", stock = 30),
                MenuEntity(name = "Kentang Goreng Seasoned Fries", categoryId = 6, categoryName = "Camilan & Dessert", price = 18000.0, costPrice = 7000.0, description = "French fries renyah dengan taburan bumbu barbeque/keju.", stock = 40),
                MenuEntity(name = "Tahu Walik Crispy Sambal Kecap", categoryId = 6, categoryName = "Camilan & Dessert", price = 18000.0, costPrice = 7000.0, description = "Tahu pong isi adonan ayam cincang digoreng garing renyah.", stock = 35)
            )
            menuDao.insertAll(menus)

            // 3. Initial Tables
            val tables = listOf(
                TableEntity(id = 1, tableNumber = "01", section = "Utama", capacity = 4, status = TableStatus.AVAILABLE),
                TableEntity(id = 2, tableNumber = "02", section = "Utama", capacity = 4, status = TableStatus.AVAILABLE),
                TableEntity(id = 3, tableNumber = "03", section = "Utama", capacity = 2, status = TableStatus.AVAILABLE),
                TableEntity(id = 4, tableNumber = "04", section = "Utama", capacity = 6, status = TableStatus.AVAILABLE),
                TableEntity(id = 5, tableNumber = "05", section = "Utama", capacity = 4, status = TableStatus.AVAILABLE),
                TableEntity(id = 6, tableNumber = "06", section = "Outdoor", capacity = 4, status = TableStatus.AVAILABLE),
                TableEntity(id = 7, tableNumber = "07", section = "Outdoor", capacity = 2, status = TableStatus.AVAILABLE),
                TableEntity(id = 8, tableNumber = "08", section = "Outdoor", capacity = 6, status = TableStatus.AVAILABLE),
                TableEntity(id = 9, tableNumber = "VIP-1", section = "VIP Room", capacity = 8, status = TableStatus.AVAILABLE),
                TableEntity(id = 10, tableNumber = "VIP-2", section = "VIP Room", capacity = 10, status = TableStatus.AVAILABLE)
            )
            tableDao.insertAll(tables)
        }
    }
}
