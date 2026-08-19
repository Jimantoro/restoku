import 'dart:math';
import 'package:intl/intl.dart';
import '../database/app_database.dart';
import '../models/cart_item_model.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/table_model.dart';

class RestaurantRepository {
  final AppDatabase database;

  RestaurantRepository({AppDatabase? db}) : database = db ?? AppDatabase.instance;

  // === Fetch Operations ===
  Future<List<CategoryModel>> getAllCategories() => database.getAllCategories();
  Future<List<MenuModel>> getAllMenus() => database.getAllMenus();
  Future<List<TableModel>> getAllTables() => database.getAllTables();
  Future<List<OrderWithItemsModel>> getAllOrdersWithItems() => database.getAllOrdersWithItems();
  Future<OrderWithItemsModel?> getOrderById(int orderId) => database.getOrderWithItemsById(orderId);

  // === Menu Management ===
  Future<int> insertMenu(MenuModel menu) => database.insertMenu(menu);
  Future<int> updateMenu(MenuModel menu) => database.updateMenu(menu);
  Future<int> deleteMenu(int id) => database.deleteMenu(id);
  Future<void> updateStock(int menuId, int newStock) async {
    final menu = await database.getMenuById(menuId);
    if (menu != null) {
      await database.updateMenu(menu.copyWith(stock: newStock));
    }
  }

  // === Category Management ===
  Future<int> insertCategory(CategoryModel category) => database.insertCategory(category);
  Future<int> deleteCategory(int id) => database.deleteCategory(id);

  // === Table Management ===
  Future<int> insertTable(TableModel table) => database.insertTable(table);
  Future<int> updateTable(TableModel table) => database.updateTable(table);
  Future<void> updateTableStatus(int tableId, TableStatus status, [int? activeOrderId]) =>
      database.updateTableStatus(tableId, status, activeOrderId);

  // === Checkout & Payment Engine (100% Offline) ===
  Future<OrderWithItemsModel> processCheckout({
    required List<CartItemModel> cartItems,
    TableModel? table,
    String customerName = 'Pelanggan',
    OrderType orderType = OrderType.dineIn,
    double discountPercent = 0.0,
    double taxPercent = 10.0,
    double servicePercent = 0.0,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    double amountPaid = 0.0,
    String notes = '',
    String cashierName = 'Kasir Resto',
    bool isPaidNow = true,
  }) async {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    final randomSuffix = 1000 + Random().nextInt(9000);
    final invoiceNumber = 'INV-$dateStr-$randomSuffix';

    final subtotal = cartItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
    final discountAmount = subtotal * (discountPercent / 100.0);
    final afterDiscount = subtotal - discountAmount;
    final taxAmount = afterDiscount * (taxPercent / 100.0);
    final serviceAmount = afterDiscount * (servicePercent / 100.0);
    final grandTotal = afterDiscount + taxAmount + serviceAmount;

    final finalStatus = isPaidNow ? OrderStatus.paid : OrderStatus.pending;
    final finalPaid = isPaidNow ? amountPaid : 0.0;
    final changeAmount = (isPaidNow && amountPaid >= grandTotal) ? amountPaid - grandTotal : 0.0;

    final timestamp = now.millisecondsSinceEpoch;
    String referenceNumber = '';
    switch (paymentMethod) {
      case PaymentMethod.qrisOffline:
        referenceNumber = 'QRIS-OFF-$timestamp';
        break;
      case PaymentMethod.debitCard:
        referenceNumber = 'EDC-DEBIT-${100000 + Random().nextInt(900000)}';
        break;
      case PaymentMethod.creditCard:
        referenceNumber = 'EDC-CC-${100000 + Random().nextInt(900000)}';
        break;
      case PaymentMethod.transferBank:
        referenceNumber = 'TF-VA-${10000000 + Random().nextInt(90000000)}';
        break;
      case PaymentMethod.cash:
        referenceNumber = 'CASH-$randomSuffix';
        break;
    }

    final order = OrderModel(
      invoiceNumber: invoiceNumber,
      tableId: table?.id,
      tableName: table != null
          ? 'Meja ${table.tableNumber}'
          : (orderType == OrderType.takeaway ? 'Takeaway / Bungkus' : 'Delivery'),
      customerName: customerName.trim().isEmpty
          ? (table != null ? 'Tamu Meja ${table.tableNumber}' : 'Pelanggan')
          : customerName.trim(),
      orderType: orderType,
      subtotal: subtotal,
      discountPercent: discountPercent,
      discountAmount: discountAmount,
      taxRatePercent: taxPercent,
      taxAmount: taxAmount,
      serviceRatePercent: servicePercent,
      serviceAmount: serviceAmount,
      grandTotal: grandTotal,
      paymentMethod: paymentMethod,
      amountPaid: finalPaid,
      changeAmount: changeAmount,
      status: finalStatus,
      notes: notes,
      cashierName: cashierName,
      referenceNumber: referenceNumber,
      createdAt: timestamp,
    );

    final orderId = await database.insertOrder(order);

    // Insert Order Items and reduce stock atomically
    final List<OrderItemModel> orderItems = [];
    for (var item in cartItems) {
      if (item.menu.id != null) {
        await database.reduceStock(item.menu.id!, item.quantity);
      }
      orderItems.add(
        OrderItemModel(
          orderId: orderId,
          menuId: item.menu.id ?? 0,
          menuName: item.menu.name,
          categoryName: item.menu.categoryName,
          unitPrice: item.menu.price,
          quantity: item.quantity,
          subtotal: item.subtotal,
          notes: item.notes,
        ),
      );
    }
    await database.insertOrderItems(orderItems);

    // Update table status if dine in
    if (table != null && table.id != null) {
      if (isPaidNow) {
        await database.updateTableStatus(table.id!, TableStatus.available, null);
      } else {
        await database.updateTableStatus(table.id!, TableStatus.occupied, orderId);
      }
    }

    return OrderWithItemsModel(
      order: order.copyWith(id: orderId),
      items: orderItems,
    );
  }

  // === Settle Pending Bill ===
  Future<OrderWithItemsModel?> settlePendingOrder({
    required int orderId,
    required PaymentMethod paymentMethod,
    required double amountPaid,
  }) async {
    final orderWithItems = await database.getOrderWithItemsById(orderId);
    if (orderWithItems == null) return null;

    final order = orderWithItems.order;
    final grandTotal = order.grandTotal;
    final change = (amountPaid >= grandTotal) ? amountPaid - grandTotal : 0.0;

    String referenceNumber = '';
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    switch (paymentMethod) {
      case PaymentMethod.qrisOffline:
        referenceNumber = 'QRIS-OFF-$timestamp';
        break;
      case PaymentMethod.debitCard:
        referenceNumber = 'EDC-DEBIT-${100000 + Random().nextInt(900000)}';
        break;
      case PaymentMethod.creditCard:
        referenceNumber = 'EDC-CC-${100000 + Random().nextInt(900000)}';
        break;
      case PaymentMethod.transferBank:
        referenceNumber = 'TF-VA-${10000000 + Random().nextInt(90000000)}';
        break;
      case PaymentMethod.cash:
        referenceNumber = 'CASH-${1000 + Random().nextInt(9000)}';
        break;
    }

    final updatedOrder = order.copyWith(
      status: OrderStatus.paid,
      paymentMethod: paymentMethod,
      amountPaid: amountPaid,
      changeAmount: change,
      referenceNumber: referenceNumber,
    );
    await database.updateOrder(updatedOrder);

    // Release table if occupied
    if (order.tableId != null) {
      await database.updateTableStatus(order.tableId!, TableStatus.available, null);
    }

    return OrderWithItemsModel(order: updatedOrder, items: orderWithItems.items);
  }

  // === Void / Cancel Order ===
  Future<void> cancelOrder(int orderId) async {
    final orderWithItems = await database.getOrderWithItemsById(orderId);
    if (orderWithItems == null) return;

    // Restore stock
    for (var item in orderWithItems.items) {
      await database.restoreStock(item.menuId, item.quantity);
    }
    await database.cancelOrder(orderId);

    // Free table if associated
    if (orderWithItems.order.tableId != null) {
      await database.updateTableStatus(orderWithItems.order.tableId!, TableStatus.available, null);
    }
  }

  // === Static Helper Formatters ===
  static String formatRupiah(double amount) {
    final formatter = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  static String formatTimestamp(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatter = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');
    return formatter.format(date);
  }

  static String formatDateOnly(int timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final formatter = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    return formatter.format(date);
  }
}
