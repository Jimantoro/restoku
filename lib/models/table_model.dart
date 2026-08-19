enum TableStatus {
  available, // Kosong
  occupied,  // Terisi
  reserved,  // Reservasi
  billing,   // Minta Bill
}

extension TableStatusExtension on TableStatus {
  String get displayName {
    switch (this) {
      case TableStatus.available:
        return 'Kosong';
      case TableStatus.occupied:
        return 'Terisi';
      case TableStatus.reserved:
        return 'Reservasi';
      case TableStatus.billing:
        return 'Minta Bill';
    }
  }

  String get dbValue {
    switch (this) {
      case TableStatus.available:
        return 'AVAILABLE';
      case TableStatus.occupied:
        return 'OCCUPIED';
      case TableStatus.reserved:
        return 'RESERVED';
      case TableStatus.billing:
        return 'BILLING';
    }
  }

  static TableStatus fromDb(String? value) {
    switch (value) {
      case 'OCCUPIED':
        return TableStatus.occupied;
      case 'RESERVED':
        return TableStatus.reserved;
      case 'BILLING':
        return TableStatus.billing;
      case 'AVAILABLE':
      default:
        return TableStatus.available;
    }
  }
}

class TableModel {
  final int? id;
  final String tableNumber;
  final String section; // Utama, VIP, Outdoor
  final int capacity;
  final TableStatus status;
  final int? activeOrderId;

  const TableModel({
    this.id,
    required this.tableNumber,
    this.section = 'Utama',
    this.capacity = 4,
    this.status = TableStatus.available,
    this.activeOrderId,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'tableNumber': tableNumber,
      'section': section,
      'capacity': capacity,
      'status': status.dbValue,
      'activeOrderId': activeOrderId,
    };
  }

  factory TableModel.fromMap(Map<String, dynamic> map) {
    return TableModel(
      id: map['id'] as int?,
      tableNumber: map['tableNumber'] as String? ?? '',
      section: map['section'] as String? ?? 'Utama',
      capacity: map['capacity'] as int? ?? 4,
      status: TableStatusExtension.fromDb(map['status'] as String?),
      activeOrderId: map['activeOrderId'] as int?,
    );
  }

  TableModel copyWith({
    int? id,
    String? tableNumber,
    String? section,
    int? capacity,
    TableStatus? status,
    int? activeOrderId,
    bool clearActiveOrder = false,
  }) {
    return TableModel(
      id: id ?? this.id,
      tableNumber: tableNumber ?? this.tableNumber,
      section: section ?? this.section,
      capacity: capacity ?? this.capacity,
      status: status ?? this.status,
      activeOrderId: clearActiveOrder ? null : (activeOrderId ?? this.activeOrderId),
    );
  }
}
