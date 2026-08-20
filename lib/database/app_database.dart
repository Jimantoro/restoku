import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/table_model.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('resto_pos_offline.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    DatabaseFactory dbFactory;
    String dbPath;

    if (!kIsWeb && (Platform.isWindows || Platform.isLinux || Platform.isMacOS)) {
      sqfliteFfiInit();
      dbFactory = databaseFactoryFfi;
      dbPath = await dbFactory.getDatabasesPath();
    } else {
      dbFactory = databaseFactory;
      try {
        dbPath = await dbFactory.getDatabasesPath();
      } catch (_) {
        // Fallback otomatis ke SQLite FFI jika native channel gagal
        sqfliteFfiInit();
        dbFactory = databaseFactoryFfi;
        dbPath = await dbFactory.getDatabasesPath();
      }
    }

    final path = join(dbPath, filePath);

    return await dbFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _createDB,
      ),
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Categories Table
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        iconName TEXT NOT NULL,
        displayOrder INTEGER NOT NULL
      )
    ''');

    // 2. Menus Table
    await db.execute('''
      CREATE TABLE menus (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        categoryId INTEGER NOT NULL,
        categoryName TEXT NOT NULL,
        price REAL NOT NULL,
        costPrice REAL NOT NULL,
        description TEXT NOT NULL,
        stock INTEGER NOT NULL,
        isAvailable INTEGER NOT NULL,
        unit TEXT NOT NULL
      )
    ''');

    // 3. Tables Table
    await db.execute('''
      CREATE TABLE tables (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tableNumber TEXT NOT NULL,
        section TEXT NOT NULL,
        capacity INTEGER NOT NULL,
        status TEXT NOT NULL,
        activeOrderId INTEGER
      )
    ''');

    // 4. Orders Table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoiceNumber TEXT NOT NULL,
        tableId INTEGER,
        tableName TEXT NOT NULL,
        customerName TEXT NOT NULL,
        orderType TEXT NOT NULL,
        subtotal REAL NOT NULL,
        discountPercent REAL NOT NULL,
        discountAmount REAL NOT NULL,
        taxRatePercent REAL NOT NULL,
        taxAmount REAL NOT NULL,
        serviceRatePercent REAL NOT NULL,
        serviceAmount REAL NOT NULL,
        grandTotal REAL NOT NULL,
        paymentMethod TEXT NOT NULL,
        amountPaid REAL NOT NULL,
        changeAmount REAL NOT NULL,
        status TEXT NOT NULL,
        notes TEXT NOT NULL,
        cashierName TEXT NOT NULL,
        referenceNumber TEXT NOT NULL,
        createdAt INTEGER NOT NULL
      )
    ''');

    // 5. Order Items Table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        menuId INTEGER NOT NULL,
        menuName TEXT NOT NULL,
        categoryName TEXT NOT NULL,
        unitPrice REAL NOT NULL,
        quantity INTEGER NOT NULL,
        subtotal REAL NOT NULL,
        notes TEXT NOT NULL,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE
      )
    ''');

    // Seed Initial Data
    await _populateInitialData(db);
  }

  Future<void> _populateInitialData(Database db) async {
    // 1. Initial Categories
    final categories = [
      {'id': 1, 'name': 'Makanan Utama', 'iconName': 'Restaurant', 'displayOrder': 1},
      {'id': 2, 'name': 'Ayam & Bebek', 'iconName': 'LunchDining', 'displayOrder': 2},
      {'id': 3, 'name': 'Seafood', 'iconName': 'SetMeal', 'displayOrder': 3},
      {'id': 4, 'name': 'Minuman Segar', 'iconName': 'LocalBar', 'displayOrder': 4},
      {'id': 5, 'name': 'Kopi & Teh', 'iconName': 'Coffee', 'displayOrder': 5},
      {'id': 6, 'name': 'Camilan & Dessert', 'iconName': 'BakeryDining', 'displayOrder': 6},
    ];
    for (var cat in categories) {
      await db.insert('categories', cat);
    }

    // 2. Initial Menus
    final menus = [
      // Makanan Utama
      {
        'name': 'Nasi Goreng Spesial Resto',
        'categoryId': 1,
        'categoryName': 'Makanan Utama',
        'price': 28000.0,
        'costPrice': 14000.0,
        'description': 'Nasi goreng bumbu rempah dengan telur mata sapi, sosis, ayam suwir dan acar segar.',
        'stock': 45,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Nasi Goreng Seafood',
        'categoryId': 1,
        'categoryName': 'Makanan Utama',
        'price': 35000.0,
        'costPrice': 18000.0,
        'description': 'Nasi goreng oriental dengan udang, cumi segar, dan bakso ikan.',
        'stock': 30,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Mie Goreng Jawa',
        'categoryId': 1,
        'categoryName': 'Makanan Utama',
        'price': 26000.0,
        'costPrice': 12000.0,
        'description': 'Mie telur kenyal dimasak kuah nyemek bumbu ebi, telur, dan sayuran.',
        'stock': 40,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Soto Betawi Daging Sapi',
        'categoryId': 1,
        'categoryName': 'Makanan Utama',
        'price': 42000.0,
        'costPrice': 24000.0,
        'description': 'Kuah santan susu gurih kaya rempah dengan irisan daging sapi empuk dan emping.',
        'stock': 25,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Rendang Daging Sapi Minang',
        'categoryId': 1,
        'categoryName': 'Makanan Utama',
        'price': 38000.0,
        'costPrice': 22000.0,
        'description': 'Daging sapi pilihan dimasak perlahan hingga bumbu meresap hitam pekat.',
        'stock': 20,
        'isAvailable': 1,
        'unit': 'porsi'
      },

      // Ayam & Bebek
      {
        'name': 'Ayam Bakar Madu Spesial',
        'categoryId': 2,
        'categoryName': 'Ayam & Bebek',
        'price': 32000.0,
        'costPrice': 16000.0,
        'description': 'Ayam pejantan bakar dengan olesan madu legit gurih disajikan sambal terasi.',
        'stock': 35,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Ayam Goreng Lengkuas',
        'categoryId': 2,
        'categoryName': 'Ayam & Bebek',
        'price': 30000.0,
        'costPrice': 15000.0,
        'description': 'Ayam ungkep rempah gurih dengan taburan serundeng lengkuas renyah.',
        'stock': 35,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Bebek Goreng Sambal Korek',
        'categoryId': 2,
        'categoryName': 'Ayam & Bebek',
        'price': 45000.0,
        'costPrice': 25000.0,
        'description': 'Bebek empuk tidak amis digoreng garing dengan sambal korek pedas nampol.',
        'stock': 20,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Sate Ayam Madura (10 Tusuk)',
        'categoryId': 2,
        'categoryName': 'Ayam & Bebek',
        'price': 34000.0,
        'costPrice': 17000.0,
        'description': 'Daging ayam fillet bakar bumbu kacang lembut, lontong dan irisan bawang merah.',
        'stock': 30,
        'isAvailable': 1,
        'unit': 'porsi'
      },

      // Seafood
      {
        'name': 'Gurame Asam Manis',
        'categoryId': 3,
        'categoryName': 'Seafood',
        'price': 65000.0,
        'costPrice': 35000.0,
        'description': 'Gurame fillet terbang digoreng renyah dengan siraman saus asam manis nanas.',
        'stock': 15,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Udang Bakar Saus Jimbaran',
        'categoryId': 3,
        'categoryName': 'Seafood',
        'price': 52000.0,
        'costPrice': 28000.0,
        'description': 'Udang windu segar bakar dengan saus rempah khas Jimbaran Bali.',
        'stock': 18,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Cumi Goreng Tepung Calamari',
        'categoryId': 3,
        'categoryName': 'Seafood',
        'price': 38000.0,
        'costPrice': 20000.0,
        'description': 'Cumi ring digoreng tepung crispy disajikan dengan saus tartar.',
        'stock': 22,
        'isAvailable': 1,
        'unit': 'porsi'
      },

      // Minuman Segar
      {
        'name': 'Es Teh Manis Jumbo',
        'categoryId': 4,
        'categoryName': 'Minuman Segar',
        'price': 7000.0,
        'costPrice': 2000.0,
        'description': 'Teh melati wangi segar racikan khas dengan gula asli.',
        'stock': 100,
        'isAvailable': 1,
        'unit': 'gelas'
      },
      {
        'name': 'Es Jeruk Peras Murni',
        'categoryId': 4,
        'categoryName': 'Minuman Segar',
        'price': 14000.0,
        'costPrice': 5000.0,
        'description': 'Perasan jeruk asli segar kaya vitamin C.',
        'stock': 50,
        'isAvailable': 1,
        'unit': 'gelas'
      },
      {
        'name': 'Jus Alpukat Kocok Cokelat',
        'categoryId': 4,
        'categoryName': 'Minuman Segar',
        'price': 22000.0,
        'costPrice': 10000.0,
        'description': 'Alpukat mentega legit diblender kental dengan lelehan saus cokelat.',
        'stock': 30,
        'isAvailable': 1,
        'unit': 'gelas'
      },
      {
        'name': 'Es Kelapa Muda Jeruk',
        'categoryId': 4,
        'categoryName': 'Minuman Segar',
        'price': 18000.0,
        'costPrice': 8000.0,
        'description': 'Kelapa muda segar dengan sirup gula aren dan perasan jeruk nipis.',
        'stock': 25,
        'isAvailable': 1,
        'unit': 'gelas'
      },

      // Kopi & Teh
      {
        'name': 'Kopi Susu Gula Aren',
        'categoryId': 5,
        'categoryName': 'Kopi & Teh',
        'price': 20000.0,
        'costPrice': 8000.0,
        'description': 'Espresso robusta & arabica dipadukan susu segar dan gula aren murni.',
        'stock': 50,
        'isAvailable': 1,
        'unit': 'cup'
      },
      {
        'name': 'Americano / Long Black',
        'categoryId': 5,
        'categoryName': 'Kopi & Teh',
        'price': 18000.0,
        'costPrice': 6000.0,
        'description': 'Espresso ganda dengan air mineral panas / dingin.',
        'stock': 50,
        'isAvailable': 1,
        'unit': 'cup'
      },
      {
        'name': 'Teh Tarik Panas',
        'categoryId': 5,
        'categoryName': 'Kopi & Teh',
        'price': 16000.0,
        'costPrice': 6000.0,
        'description': 'Teh susu berbusa kental dan creamy khas nusantara.',
        'stock': 40,
        'isAvailable': 1,
        'unit': 'cangkir'
      },

      // Camilan & Dessert
      {
        'name': 'Pisang Bakar Coklat Keju',
        'categoryId': 6,
        'categoryName': 'Camilan & Dessert',
        'price': 20000.0,
        'costPrice': 8000.0,
        'description': 'Pisang raja bakar dengan topping meses cokelat, keju cheddar parut dan susu kental.',
        'stock': 30,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Kentang Goreng Seasoned Fries',
        'categoryId': 6,
        'categoryName': 'Camilan & Dessert',
        'price': 18000.0,
        'costPrice': 7000.0,
        'description': 'French fries renyah dengan taburan bumbu barbeque/keju.',
        'stock': 40,
        'isAvailable': 1,
        'unit': 'porsi'
      },
      {
        'name': 'Tahu Walik Crispy Sambal Kecap',
        'categoryId': 6,
        'categoryName': 'Camilan & Dessert',
        'price': 18000.0,
        'costPrice': 7000.0,
        'description': 'Tahu pong isi adonan ayam cincang digoreng garing renyah.',
        'stock': 35,
        'isAvailable': 1,
        'unit': 'porsi'
      }
    ];

    for (var menu in menus) {
      await db.insert('menus', menu);
    }

    // 3. Initial Tables
    final tables = [
      {'id': 1, 'tableNumber': '01', 'section': 'Utama', 'capacity': 4, 'status': 'AVAILABLE'},
      {'id': 2, 'tableNumber': '02', 'section': 'Utama', 'capacity': 4, 'status': 'AVAILABLE'},
      {'id': 3, 'tableNumber': '03', 'section': 'Utama', 'capacity': 2, 'status': 'AVAILABLE'},
      {'id': 4, 'tableNumber': '04', 'section': 'Utama', 'capacity': 6, 'status': 'AVAILABLE'},
      {'id': 5, 'tableNumber': '05', 'section': 'Utama', 'capacity': 4, 'status': 'AVAILABLE'},
      {'id': 6, 'tableNumber': '06', 'section': 'Outdoor', 'capacity': 4, 'status': 'AVAILABLE'},
      {'id': 7, 'tableNumber': '07', 'section': 'Outdoor', 'capacity': 2, 'status': 'AVAILABLE'},
      {'id': 8, 'tableNumber': '08', 'section': 'Outdoor', 'capacity': 6, 'status': 'AVAILABLE'},
      {'id': 9, 'tableNumber': 'VIP-1', 'section': 'VIP Room', 'capacity': 8, 'status': 'AVAILABLE'},
      {'id': 10, 'tableNumber': 'VIP-2', 'section': 'VIP Room', 'capacity': 10, 'status': 'AVAILABLE'},
    ];

    for (var tbl in tables) {
      await db.insert('tables', tbl);
    }
  }

  // === Category Operations ===
  Future<List<CategoryModel>> getAllCategories() async {
    final db = await database;
    final result = await db.query('categories', orderBy: 'displayOrder ASC, id ASC');
    return result.map((json) => CategoryModel.fromMap(json)).toList();
  }

  Future<int> insertCategory(CategoryModel category) async {
    final db = await database;
    return await db.insert('categories', category.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> deleteCategory(int id) async {
    final db = await database;
    return await db.delete('categories', where: 'id = ?', whereArgs: [id]);
  }

  // === Menu Operations ===
  Future<List<MenuModel>> getAllMenus() async {
    final db = await database;
    final result = await db.query('menus', orderBy: 'categoryId ASC, name ASC');
    return result.map((json) => MenuModel.fromMap(json)).toList();
  }

  Future<MenuModel?> getMenuById(int id) async {
    final db = await database;
    final result = await db.query('menus', where: 'id = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      return MenuModel.fromMap(result.first);
    }
    return null;
  }

  Future<int> insertMenu(MenuModel menu) async {
    final db = await database;
    return await db.insert('menus', menu.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateMenu(MenuModel menu) async {
    final db = await database;
    return await db.update('menus', menu.toMap(), where: 'id = ?', whereArgs: [menu.id]);
  }

  Future<int> deleteMenu(int id) async {
    final db = await database;
    return await db.delete('menus', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> reduceStock(int menuId, int quantity) async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE menus 
      SET stock = stock - ? 
      WHERE id = ? AND stock >= ?
    ''', [quantity, menuId, quantity]);
  }

  Future<int> restoreStock(int menuId, int quantity) async {
    final db = await database;
    return await db.rawUpdate('''
      UPDATE menus 
      SET stock = stock + ? 
      WHERE id = ?
    ''', [quantity, menuId]);
  }

  // === Table Operations ===
  Future<List<TableModel>> getAllTables() async {
    final db = await database;
    final result = await db.query('tables', orderBy: 'id ASC');
    return result.map((json) => TableModel.fromMap(json)).toList();
  }

  Future<int> insertTable(TableModel table) async {
    final db = await database;
    return await db.insert('tables', table.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTable(TableModel table) async {
    final db = await database;
    return await db.update('tables', table.toMap(), where: 'id = ?', whereArgs: [table.id]);
  }

  Future<int> updateTableStatus(int tableId, TableStatus status, int? activeOrderId) async {
    final db = await database;
    return await db.update(
      'tables',
      {
        'status': status.dbValue,
        'activeOrderId': activeOrderId,
      },
      where: 'id = ?',
      whereArgs: [tableId],
    );
  }

  Future<int> deleteTable(int id) async {
    final db = await database;
    return await db.delete('tables', where: 'id = ?', whereArgs: [id]);
  }

  // === Order & Item Operations ===
  Future<List<OrderWithItemsModel>> getAllOrdersWithItems() async {
    final db = await database;
    final orderMaps = await db.query('orders', orderBy: 'createdAt DESC');
    final List<OrderWithItemsModel> list = [];

    for (var orderMap in orderMaps) {
      final order = OrderModel.fromMap(orderMap);
      final itemMaps = await db.query('order_items', where: 'orderId = ?', whereArgs: [order.id]);
      final items = itemMaps.map((itemJson) => OrderItemModel.fromMap(itemJson)).toList();
      list.add(OrderWithItemsModel(order: order, items: items));
    }
    return list;
  }

  Future<OrderWithItemsModel?> getOrderWithItemsById(int orderId) async {
    final db = await database;
    final orderMaps = await db.query('orders', where: 'id = ?', whereArgs: [orderId]);
    if (orderMaps.isEmpty) return null;

    final order = OrderModel.fromMap(orderMaps.first);
    final itemMaps = await db.query('order_items', where: 'orderId = ?', whereArgs: [orderId]);
    final items = itemMaps.map((itemJson) => OrderItemModel.fromMap(itemJson)).toList();
    return OrderWithItemsModel(order: order, items: items);
  }

  Future<int> insertOrder(OrderModel order) async {
    final db = await database;
    return await db.insert('orders', order.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> insertOrderItems(List<OrderItemModel> items) async {
    final db = await database;
    final batch = db.batch();
    for (var item in items) {
      batch.insert('order_items', item.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  Future<int> updateOrder(OrderModel order) async {
    final db = await database;
    return await db.update('orders', order.toMap(), where: 'id = ?', whereArgs: [order.id]);
  }

  Future<int> cancelOrder(int orderId) async {
    final db = await database;
    return await db.update(
      'orders',
      {'status': 'CANCELLED'},
      where: 'id = ?',
      whereArgs: [orderId],
    );
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
