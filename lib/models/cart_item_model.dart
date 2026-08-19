import 'menu_model.dart';

class CartItemModel {
  final MenuModel menu;
  final int quantity;
  final String notes;

  const CartItemModel({
    required this.menu,
    this.quantity = 1,
    this.notes = '',
  });

  double get subtotal => menu.price * quantity;

  CartItemModel copyWith({
    MenuModel? menu,
    int? quantity,
    String? notes,
  }) {
    return CartItemModel(
      menu: menu ?? this.menu,
      quantity: quantity ?? this.quantity,
      notes: notes ?? this.notes,
    );
  }
}
