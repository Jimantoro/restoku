import 'package:flutter/foundation.dart';
import '../models/cart_item_model.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../models/order_model.dart';
import '../models/table_model.dart';
import '../repositories/restaurant_repository.dart';

enum AppNavTab {
  pos,
  tables,
  transactions,
  reports,
  menuManagement,
}

class RestaurantProvider extends ChangeNotifier {
  final RestaurantRepository repository;

  RestaurantProvider({RestaurantRepository? repo})
      : repository = repo ?? RestaurantRepository() {
    loadInitialData();
  }

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  AppNavTab _currentTab = AppNavTab.pos;
  AppNavTab get currentTab => _currentTab;

  List<CategoryModel> _categories = [];
  List<CategoryModel> get categories => _categories;

  List<MenuModel> _menus = [];
  List<MenuModel> get menus => _menus;

  List<TableModel> _tables = [];
  List<TableModel> get tables => _tables;

  List<OrderWithItemsModel> _orders = [];
  List<OrderWithItemsModel> get orders => _orders;

  int? _selectedCategoryId;
  int? get selectedCategoryId => _selectedCategoryId;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  TableModel? _selectedTable;
  TableModel? get selectedTable => _selectedTable;

  String _customerName = '';
  String get customerName => _customerName;

  OrderType _orderType = OrderType.dineIn;
  OrderType get orderType => _orderType;

  final List<CartItemModel> _cartItems = [];
  List<CartItemModel> get cartItems => _cartItems;

  double _discountPercent = 0.0;
  double get discountPercent => _discountPercent;

  double _taxPercent = 10.0; // 10% PB1 Restaurant Tax
  double get taxPercent => _taxPercent;

  final double _servicePercent = 0.0;
  double get servicePercent => _servicePercent;

  final String _cashierName = 'Kasir Resto';
  String get cashierName => _cashierName;

  CartItemModel? _activeNotesItem;
  CartItemModel? get activeNotesItem => _activeNotesItem;

  bool _showPaymentDialog = false;
  bool get showPaymentDialog => _showPaymentDialog;

  bool _showReceiptDialog = false;
  bool get showReceiptDialog => _showReceiptDialog;

  OrderWithItemsModel? _lastCompletedOrder;
  OrderWithItemsModel? get lastCompletedOrder => _lastCompletedOrder;

  OrderWithItemsModel? _activeSettleOrder;
  OrderWithItemsModel? get activeSettleOrder => _activeSettleOrder;

  String? _notificationMessage;
  String? get notificationMessage => _notificationMessage;

  // Filtered menus based on category & search query
  List<MenuModel> get filteredMenus {
    return _menus.filterMenus(_selectedCategoryId, _searchQuery);
  }

  // Cart Calculations
  double get subtotal => _cartItems.fold<double>(0.0, (sum, item) => sum + item.subtotal);
  double get discountAmount => subtotal * (_discountPercent / 100.0);
  double get afterDiscount => subtotal - discountAmount;
  double get taxAmount => afterDiscount * (_taxPercent / 100.0);
  double get serviceAmount => afterDiscount * (_servicePercent / 100.0);
  double get grandTotal => afterDiscount + taxAmount + serviceAmount;
  int get totalItemCount => _cartItems.fold<int>(0, (sum, item) => sum + item.quantity);

  // === Load Data from SQLite ===
  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await repository.getAllCategories();
      _menus = await repository.getAllMenus();
      _tables = await repository.getAllTables();
      _orders = await repository.getAllOrdersWithItems();
    } catch (e) {
      if (kDebugMode) {
        print('Error loading initial data: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // === Navigation ===
  void setTab(AppNavTab tab) {
    _currentTab = tab;
    notifyListeners();
  }

  void selectCategory(int? categoryId) {
    _selectedCategoryId = categoryId;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setCustomerName(String name) {
    _customerName = name;
    notifyListeners();
  }

  void setOrderType(OrderType type) {
    _orderType = type;
    if (type != OrderType.dineIn) {
      _selectedTable = null;
    }
    notifyListeners();
  }

  void selectTable(TableModel? table) {
    _selectedTable = table;
    if (table != null) {
      _orderType = OrderType.dineIn;
    }
    notifyListeners();
  }

  // === Cart Operations ===
  void addToCart(MenuModel menu) {
    if (menu.stock <= 0) {
      showNotification('Stok ${menu.name} habis!');
      return;
    }

    final existingIndex = _cartItems.indexWhere((item) => item.menu.id == menu.id);
    if (existingIndex >= 0) {
      final current = _cartItems[existingIndex];
      if (current.quantity + 1 > menu.stock) {
        showNotification('Stok maksimum tercapai (${menu.stock})');
        return;
      }
      _cartItems[existingIndex] = current.copyWith(quantity: current.quantity + 1);
    } else {
      _cartItems.add(CartItemModel(menu: menu, quantity: 1));
    }
    notifyListeners();
  }

  void updateCartQuantity(int menuId, int newQuantity) {
    if (newQuantity <= 0) {
      removeFromCart(menuId);
      return;
    }

    final index = _cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index >= 0) {
      final item = _cartItems[index];
      if (newQuantity > item.menu.stock) {
        showNotification('Stok tidak mencukupi (Maks: ${item.menu.stock})');
        _cartItems[index] = item.copyWith(quantity: item.menu.stock);
      } else {
        _cartItems[index] = item.copyWith(quantity: newQuantity);
      }
      notifyListeners();
    }
  }

  void removeFromCart(int menuId) {
    _cartItems.removeWhere((item) => item.menu.id == menuId);
    notifyListeners();
  }

  void clearCart() {
    _cartItems.clear();
    _selectedTable = null;
    _customerName = '';
    _discountPercent = 0.0;
    notifyListeners();
  }

  void setItemNotes(int menuId, String notes) {
    final index = _cartItems.indexWhere((item) => item.menu.id == menuId);
    if (index >= 0) {
      _cartItems[index] = _cartItems[index].copyWith(notes: notes);
      _activeNotesItem = null;
      notifyListeners();
    }
  }

  void openNotesDialog(CartItemModel item) {
    _activeNotesItem = item;
    notifyListeners();
  }

  void closeNotesDialog() {
    _activeNotesItem = null;
    notifyListeners();
  }

  void setDiscountPercent(double percent) {
    _discountPercent = percent;
    notifyListeners();
  }

  void setTaxPercent(double percent) {
    _taxPercent = percent;
    notifyListeners();
  }

  // === Payment Modal & Processing ===
  void openPaymentDialog([OrderWithItemsModel? settleOrder]) {
    if (settleOrder == null && _cartItems.isEmpty) {
      showNotification('Keranjang pesanan masih kosong!');
      return;
    }
    _activeSettleOrder = settleOrder;
    _showPaymentDialog = true;
    notifyListeners();
  }

  void closePaymentDialog() {
    _showPaymentDialog = false;
    _activeSettleOrder = null;
    notifyListeners();
  }

  Future<void> processPayment({
    required PaymentMethod paymentMethod,
    required double amountPaid,
    required bool isPaidNow,
    String notes = '',
  }) async {
    if (_cartItems.isEmpty) return;

    try {
      final completedOrder = await repository.processCheckout(
        cartItems: _cartItems,
        table: _selectedTable,
        customerName: _customerName,
        orderType: _orderType,
        discountPercent: _discountPercent,
        taxPercent: _taxPercent,
        servicePercent: _servicePercent,
        paymentMethod: paymentMethod,
        amountPaid: amountPaid,
        notes: notes,
        cashierName: _cashierName,
        isPaidNow: isPaidNow,
      );

      _cartItems.clear();
      _selectedTable = null;
      _customerName = '';
      _discountPercent = 0.0;
      _showPaymentDialog = false;
      _lastCompletedOrder = completedOrder;
      _showReceiptDialog = isPaidNow;

      showNotification(
        isPaidNow
            ? 'Transaksi offline berhasil disimpan!'
            : 'Pesanan meja berhasil disimpan!',
      );

      // Refresh data
      await loadInitialData();
    } catch (e) {
      showNotification('Gagal memproses pesanan: $e');
    }
  }

  // === Settle Pending Bill ===
  Future<void> processSettlePending({
    required int orderId,
    required PaymentMethod paymentMethod,
    required double amountPaid,
  }) async {
    try {
      final result = await repository.settlePendingOrder(
        orderId: orderId,
        paymentMethod: paymentMethod,
        amountPaid: amountPaid,
      );

      if (result != null) {
        _showPaymentDialog = false;
        _activeSettleOrder = null;
        _lastCompletedOrder = result;
        _showReceiptDialog = true;
        showNotification('Pembayaran tagihan berhasil diselesaikan!');
        await loadInitialData();
      }
    } catch (e) {
      showNotification('Gagal menyelesaikan tagihan: $e');
    }
  }

  Future<void> cancelOrder(int orderId) async {
    try {
      await repository.cancelOrder(orderId);
      showNotification('Pesanan berhasil dibatalkan & stok dikembalikan.');
      await loadInitialData();
    } catch (e) {
      showNotification('Gagal membatalkan pesanan: $e');
    }
  }

  void openReceiptDialog(OrderWithItemsModel order) {
    _lastCompletedOrder = order;
    _showReceiptDialog = true;
    notifyListeners();
  }

  void closeReceiptDialog() {
    _showReceiptDialog = false;
    notifyListeners();
  }

  // === Menu Management ===
  Future<void> addNewMenu({
    required String name,
    required int categoryId,
    required String categoryName,
    required double price,
    required double costPrice,
    required String description,
    required int stock,
  }) async {
    await repository.insertMenu(
      MenuModel(
        name: name,
        categoryId: categoryId,
        categoryName: categoryName,
        price: price,
        costPrice: costPrice,
        description: description,
        stock: stock,
      ),
    );
    showNotification('Menu $name berhasil ditambahkan!');
    await loadInitialData();
  }

  Future<void> updateMenu(MenuModel menu) async {
    await repository.updateMenu(menu);
    showNotification('Menu ${menu.name} berhasil diperbarui!');
    await loadInitialData();
  }

  Future<void> updateMenuStock(int menuId, int stock) async {
    await repository.updateStock(menuId, stock);
    showNotification('Stok berhasil diperbarui!');
    await loadInitialData();
  }

  Future<void> deleteMenu(int menuId, String menuName) async {
    await repository.deleteMenu(menuId);
    showNotification('Menu $menuName dihapus.');
    await loadInitialData();
  }

  // === Category Management ===
  Future<CategoryModel> getOrCreateCategory(String categoryName) async {
    final cat = await repository.getOrCreateCategory(categoryName);
    await loadInitialData();
    return cat;
  }

  Future<CategoryModel> addCategory(String categoryName) async {
    final cat = await repository.getOrCreateCategory(categoryName);
    showNotification('Kategori "${cat.name}" siap digunakan!');
    await loadInitialData();
    return cat;
  }

  // === Table Management ===
  Future<void> addTable({
    required String number,
    required String section,
    required int capacity,
  }) async {
    await repository.insertTable(
      TableModel(
        tableNumber: number,
        section: section,
        capacity: capacity,
        status: TableStatus.available,
      ),
    );
    showNotification('Meja $number berhasil ditambahkan!');
    await loadInitialData();
  }

  Future<void> updateTableStatus(int tableId, TableStatus status) async {
    await repository.updateTableStatus(tableId, status, null);
    showNotification('Status meja diperbarui!');
    await loadInitialData();
  }

  void showNotification(String msg) {
    _notificationMessage = msg;
    notifyListeners();
  }

  void clearNotification() {
    _notificationMessage = null;
  }
}

extension MenuListFilter on List<MenuModel> {
  List<MenuModel> filterMenus(int? categoryId, String query) {
    return where((menu) {
      final matchesCategory = categoryId == null || menu.categoryId == categoryId;
      final matchesSearch = query.trim().isEmpty ||
          menu.name.toLowerCase().contains(query.toLowerCase()) ||
          menu.description.toLowerCase().contains(query.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}
