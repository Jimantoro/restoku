import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/menu_model.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class MenuCard extends StatelessWidget {
  final MenuModel menu;
  final CartItemModel? cartItem;
  final VoidCallback onAddToCart;
  final ValueChanged<int> onQuantityChange;
  final ValueChanged<CartItemModel> onOpenNotes;

  const MenuCard({
    super.key,
    required this.menu,
    required this.cartItem,
    required this.onAddToCart,
    required this.onQuantityChange,
    required this.onOpenNotes,
  });

  IconData _getCategoryIcon(String categoryName) {
    final lower = categoryName.toLowerCase();
    if (lower.contains('minum') || lower.contains('teh') || lower.contains('kopi')) {
      return Icons.local_bar;
    }
    if (lower.contains('snack') || lower.contains('camilan') || lower.contains('pisang')) {
      return Icons.bakery_dining;
    }
    if (lower.contains('ikan') || lower.contains('laut') || lower.contains('seafood')) {
      return Icons.set_meal;
    }
    if (lower.contains('nasi') || lower.contains('ayam') || lower.contains('bebek') || lower.contains('goreng')) {
      return Icons.lunch_dining;
    }
    return Icons.restaurant;
  }

  @override
  Widget build(BuildContext context) {
    final isOutOfStock = menu.stock <= 0;
    final inCartQty = cartItem?.quantity ?? 0;

    return Opacity(
      opacity: isOutOfStock ? 0.6 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: inCartQty > 0
                ? AppColors.primary
                : AppColors.surfaceLightBorder.withValues(alpha: 0.5),
            width: inCartQty > 0 ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top: Category Icon + Stock Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.primaryContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getCategoryIcon(menu.categoryName),
                    color: AppColors.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isOutOfStock
                        ? AppColors.error.withValues(alpha: 0.12)
                        : AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOutOfStock ? 'Habis' : 'Stok: ${menu.stock}',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isOutOfStock ? AppColors.error : AppColors.success,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Middle: Name & Description
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  menu.name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (menu.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    menu.description,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondaryLight,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),

            const SizedBox(height: 8),

            // Note preview if exists
            if (cartItem != null && cartItem!.notes.isNotEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '📝 ${cartItem!.notes}',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.onPrimaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Bottom: Price & Action Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  RestaurantRepository.formatRupiah(menu.price),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.primary,
                  ),
                ),

                if (inCartQty > 0)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Notes button
                      InkWell(
                        onTap: () => onOpenNotes(cartItem!),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: cartItem!.notes.isNotEmpty
                                ? AppColors.primary.withValues(alpha: 0.15)
                                : AppColors.surfaceLightChip,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.edit_note,
                            size: 16,
                            color: cartItem!.notes.isNotEmpty
                                ? AppColors.primary
                                : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Minus button
                      InkWell(
                        onTap: () => onQuantityChange(inCartQty - 1),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: const BoxDecoration(
                            color: AppColors.surfaceLightChip,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.remove,
                            size: 14,
                            color: AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Text(
                          '$inCartQty',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // Plus button
                      InkWell(
                        onTap: inCartQty < menu.stock ? () => onQuantityChange(inCartQty + 1) : null,
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: inCartQty < menu.stock ? AppColors.primary : AppColors.surfaceLightChip,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.add,
                            size: 14,
                            color: inCartQty < menu.stock ? Colors.white : AppColors.textSecondaryLight,
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  ElevatedButton(
                    onPressed: isOutOfStock ? null : onAddToCart,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      minimumSize: const Size(60, 30),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add, size: 14),
                        SizedBox(width: 2),
                        Text('Pesan', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
