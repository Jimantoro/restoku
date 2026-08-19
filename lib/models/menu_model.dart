class MenuModel {
  final int? id;
  final String name;
  final int categoryId;
  final String categoryName;
  final double price;
  final double costPrice;
  final String description;
  final int stock;
  final bool isAvailable;
  final String unit;

  const MenuModel({
    this.id,
    required this.name,
    required this.categoryId,
    required this.categoryName,
    required this.price,
    this.costPrice = 0.0,
    this.description = '',
    this.stock = 50,
    this.isAvailable = true,
    this.unit = 'porsi',
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'price': price,
      'costPrice': costPrice,
      'description': description,
      'stock': stock,
      'isAvailable': isAvailable ? 1 : 0,
      'unit': unit,
    };
  }

  factory MenuModel.fromMap(Map<String, dynamic> map) {
    return MenuModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      categoryId: map['categoryId'] as int? ?? 1,
      categoryName: map['categoryName'] as String? ?? '',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      costPrice: (map['costPrice'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] as String? ?? '',
      stock: map['stock'] as int? ?? 0,
      isAvailable: (map['isAvailable'] as int? ?? 1) == 1,
      unit: map['unit'] as String? ?? 'porsi',
    );
  }

  MenuModel copyWith({
    int? id,
    String? name,
    int? categoryId,
    String? categoryName,
    double? price,
    double? costPrice,
    String? description,
    int? stock,
    bool? isAvailable,
    String? unit,
  }) {
    return MenuModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      description: description ?? this.description,
      stock: stock ?? this.stock,
      isAvailable: isAvailable ?? this.isAvailable,
      unit: unit ?? this.unit,
    );
  }
}
