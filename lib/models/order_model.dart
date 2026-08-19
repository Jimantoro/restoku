enum PaymentMethod {
  cash,         // Tunai
  qrisOffline,  // QRIS Offline
  debitCard,    // Kartu Debit / EDC
  creditCard,   // Kartu Kredit
  transferBank, // Transfer Bank
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Tunai (Cash)';
      case PaymentMethod.qrisOffline:
        return 'QRIS Offline';
      case PaymentMethod.debitCard:
        return 'Kartu Debit / EDC';
      case PaymentMethod.creditCard:
        return 'Kartu Kredit';
      case PaymentMethod.transferBank:
        return 'Transfer Bank';
    }
  }

  String get dbValue {
    switch (this) {
      case PaymentMethod.cash:
        return 'CASH';
      case PaymentMethod.qrisOffline:
        return 'QRIS_OFFLINE';
      case PaymentMethod.debitCard:
        return 'DEBIT_CARD';
      case PaymentMethod.creditCard:
        return 'CREDIT_CARD';
      case PaymentMethod.transferBank:
        return 'TRANSFER_BANK';
    }
  }

  static PaymentMethod fromDb(String? value) {
    switch (value) {
      case 'QRIS_OFFLINE':
        return PaymentMethod.qrisOffline;
      case 'DEBIT_CARD':
        return PaymentMethod.debitCard;
      case 'CREDIT_CARD':
        return PaymentMethod.creditCard;
      case 'TRANSFER_BANK':
        return PaymentMethod.transferBank;
      case 'CASH':
      default:
        return PaymentMethod.cash;
    }
  }
}

enum OrderStatus {
  pending,
  paid,
  cancelled,
}

extension OrderStatusExtension on OrderStatus {
  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'BELUM BAYAR';
      case OrderStatus.paid:
        return 'LUNAS';
      case OrderStatus.cancelled:
        return 'DIBATALKAN';
    }
  }

  String get dbValue {
    switch (this) {
      case OrderStatus.pending:
        return 'PENDING';
      case OrderStatus.paid:
        return 'PAID';
      case OrderStatus.cancelled:
        return 'CANCELLED';
    }
  }

  static OrderStatus fromDb(String? value) {
    switch (value) {
      case 'PAID':
        return OrderStatus.paid;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      case 'PENDING':
      default:
        return OrderStatus.pending;
    }
  }
}

enum OrderType {
  dineIn,
  takeaway,
  delivery,
}

extension OrderTypeExtension on OrderType {
  String get displayName {
    switch (this) {
      case OrderType.dineIn:
        return 'Dine In';
      case OrderType.takeaway:
        return 'Takeaway';
      case OrderType.delivery:
        return 'Delivery';
    }
  }

  String get dbValue {
    switch (this) {
      case OrderType.dineIn:
        return 'DINE_IN';
      case OrderType.takeaway:
        return 'TAKEAWAY';
      case OrderType.delivery:
        return 'DELIVERY';
    }
  }

  static OrderType fromDb(String? value) {
    switch (value) {
      case 'TAKEAWAY':
        return OrderType.takeaway;
      case 'DELIVERY':
        return OrderType.delivery;
      case 'DINE_IN':
      default:
        return OrderType.dineIn;
    }
  }
}

class OrderModel {
  final int? id;
  final String invoiceNumber;
  final int? tableId;
  final String tableName;
  final String customerName;
  final OrderType orderType;
  final double subtotal;
  final double discountPercent;
  final double discountAmount;
  final double taxRatePercent;
  final double taxAmount;
  final double serviceRatePercent;
  final double serviceAmount;
  final double grandTotal;
  final PaymentMethod paymentMethod;
  final double amountPaid;
  final double changeAmount;
  final OrderStatus status;
  final String notes;
  final String cashierName;
  final String referenceNumber;
  final int createdAt;

  const OrderModel({
    this.id,
    required this.invoiceNumber,
    this.tableId,
    this.tableName = 'Takeaway',
    this.customerName = 'Pelanggan',
    this.orderType = OrderType.dineIn,
    this.subtotal = 0.0,
    this.discountPercent = 0.0,
    this.discountAmount = 0.0,
    this.taxRatePercent = 10.0,
    this.taxAmount = 0.0,
    this.serviceRatePercent = 0.0,
    this.serviceAmount = 0.0,
    this.grandTotal = 0.0,
    this.paymentMethod = PaymentMethod.cash,
    this.amountPaid = 0.0,
    this.changeAmount = 0.0,
    this.status = OrderStatus.pending,
    this.notes = '',
    this.cashierName = 'Kasir Resto',
    this.referenceNumber = '',
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'invoiceNumber': invoiceNumber,
      'tableId': tableId,
      'tableName': tableName,
      'customerName': customerName,
      'orderType': orderType.dbValue,
      'subtotal': subtotal,
      'discountPercent': discountPercent,
      'discountAmount': discountAmount,
      'taxRatePercent': taxRatePercent,
      'taxAmount': taxAmount,
      'serviceRatePercent': serviceRatePercent,
      'serviceAmount': serviceAmount,
      'grandTotal': grandTotal,
      'paymentMethod': paymentMethod.dbValue,
      'amountPaid': amountPaid,
      'changeAmount': changeAmount,
      'status': status.dbValue,
      'notes': notes,
      'cashierName': cashierName,
      'referenceNumber': referenceNumber,
      'createdAt': createdAt,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as int?,
      invoiceNumber: map['invoiceNumber'] as String? ?? '',
      tableId: map['tableId'] as int?,
      tableName: map['tableName'] as String? ?? 'Takeaway',
      customerName: map['customerName'] as String? ?? 'Pelanggan',
      orderType: OrderTypeExtension.fromDb(map['orderType'] as String?),
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      discountPercent: (map['discountPercent'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (map['discountAmount'] as num?)?.toDouble() ?? 0.0,
      taxRatePercent: (map['taxRatePercent'] as num?)?.toDouble() ?? 10.0,
      taxAmount: (map['taxAmount'] as num?)?.toDouble() ?? 0.0,
      serviceRatePercent: (map['serviceRatePercent'] as num?)?.toDouble() ?? 0.0,
      serviceAmount: (map['serviceAmount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (map['grandTotal'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: PaymentMethodExtension.fromDb(map['paymentMethod'] as String?),
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      changeAmount: (map['changeAmount'] as num?)?.toDouble() ?? 0.0,
      status: OrderStatusExtension.fromDb(map['status'] as String?),
      notes: map['notes'] as String? ?? '',
      cashierName: map['cashierName'] as String? ?? 'Kasir Resto',
      referenceNumber: map['referenceNumber'] as String? ?? '',
      createdAt: map['createdAt'] as int? ?? DateTime.now().millisecondsSinceEpoch,
    );
  }

  OrderModel copyWith({
    int? id,
    String? invoiceNumber,
    int? tableId,
    String? tableName,
    String? customerName,
    OrderType? orderType,
    double? subtotal,
    double? discountPercent,
    double? discountAmount,
    double? taxRatePercent,
    double? taxAmount,
    double? serviceRatePercent,
    double? serviceAmount,
    double? grandTotal,
    PaymentMethod? paymentMethod,
    double? amountPaid,
    double? changeAmount,
    OrderStatus? status,
    String? notes,
    String? cashierName,
    String? referenceNumber,
    int? createdAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      tableId: tableId ?? this.tableId,
      tableName: tableName ?? this.tableName,
      customerName: customerName ?? this.customerName,
      orderType: orderType ?? this.orderType,
      subtotal: subtotal ?? this.subtotal,
      discountPercent: discountPercent ?? this.discountPercent,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRatePercent: taxRatePercent ?? this.taxRatePercent,
      taxAmount: taxAmount ?? this.taxAmount,
      serviceRatePercent: serviceRatePercent ?? this.serviceRatePercent,
      serviceAmount: serviceAmount ?? this.serviceAmount,
      grandTotal: grandTotal ?? this.grandTotal,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amountPaid: amountPaid ?? this.amountPaid,
      changeAmount: changeAmount ?? this.changeAmount,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      cashierName: cashierName ?? this.cashierName,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class OrderItemModel {
  final int? id;
  final int orderId;
  final int menuId;
  final String menuName;
  final String categoryName;
  final double unitPrice;
  final int quantity;
  final double subtotal;
  final String notes;

  const OrderItemModel({
    this.id,
    required this.orderId,
    required this.menuId,
    required this.menuName,
    required this.categoryName,
    required this.unitPrice,
    required this.quantity,
    required this.subtotal,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'orderId': orderId,
      'menuId': menuId,
      'menuName': menuName,
      'categoryName': categoryName,
      'unitPrice': unitPrice,
      'quantity': quantity,
      'subtotal': subtotal,
      'notes': notes,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      orderId: map['orderId'] as int? ?? 0,
      menuId: map['menuId'] as int? ?? 0,
      menuName: map['menuName'] as String? ?? '',
      categoryName: map['categoryName'] as String? ?? '',
      unitPrice: (map['unitPrice'] as num?)?.toDouble() ?? 0.0,
      quantity: map['quantity'] as int? ?? 1,
      subtotal: (map['subtotal'] as num?)?.toDouble() ?? 0.0,
      notes: map['notes'] as String? ?? '',
    );
  }
}

class OrderWithItemsModel {
  final OrderModel order;
  final List<OrderItemModel> items;

  const OrderWithItemsModel({
    required this.order,
    required this.items,
  });
}
