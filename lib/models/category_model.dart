class CategoryModel {
  final int? id;
  final String name;
  final String iconName;
  final int displayOrder;

  const CategoryModel({
    this.id,
    required this.name,
    this.iconName = 'Restaurant',
    this.displayOrder = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'iconName': iconName,
      'displayOrder': displayOrder,
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      iconName: map['iconName'] as String? ?? 'Restaurant',
      displayOrder: map['displayOrder'] as int? ?? 0,
    );
  }

  CategoryModel copyWith({
    int? id,
    String? name,
    String? iconName,
    int? displayOrder,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }
}
