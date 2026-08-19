import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../providers/restaurant_provider.dart';
import '../theme/app_colors.dart';
import '../widgets/cart_bottom_summary.dart';
import '../widgets/cart_detail_sheet.dart';
import '../widgets/category_filter_tabs.dart';
import '../widgets/menu_card.dart';
import '../widgets/order_item_notes_dialog.dart';
import '../widgets/top_app_bar_header.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final menus = provider.filteredMenus;

    return Stack(
      children: [
        Column(
          children: [
            // Top App Bar Header with Search & Table Selector
            TopAppBarHeader(
              searchQuery: provider.searchQuery,
              onSearchChange: (query) => provider.setSearchQuery(query),
              selectedTable: provider.selectedTable,
              onTableClick: () => provider.setTab(AppNavTab.tables),
            ),

            // Category Filter Chips
            CategoryFilterTabs(
              categories: provider.categories,
              selectedCategoryId: provider.selectedCategoryId,
              onCategorySelected: (catId) => provider.selectCategory(catId),
            ),

            // Menu Grid
            Expanded(
              child: menus.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fastfood,
                              size: 54,
                              color: AppColors.textSecondaryLight.withValues(alpha: 0.5),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Menu tidak ditemukan',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Coba ubah kata kunci pencarian atau pilih kategori lain.',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textSecondaryLight,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        8,
                        16,
                        provider.cartItems.isNotEmpty ? 90 : 16,
                      ),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.76,
                      ),
                      itemCount: menus.length,
                      itemBuilder: (context, index) {
                        final menu = menus[index];
                        final cartItem = provider.cartItems.cast<CartItemModel?>().firstWhere(
                              (it) => it?.menu.id == menu.id,
                              orElse: () => null,
                            );

                        return MenuCard(
                          menu: menu,
                          cartItem: cartItem,
                          onAddToCart: () => provider.addToCart(menu),
                          onQuantityChange: (qty) =>
                              provider.updateCartQuantity(menu.id!, qty),
                          onOpenNotes: (item) {
                            showDialog(
                              context: context,
                              builder: (ctx) => OrderItemNotesDialog(
                                item: item,
                                onSaveNotes: (notes) =>
                                    provider.setItemNotes(item.menu.id!, notes),
                                onDismiss: () => Navigator.pop(ctx),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),

        // Sticky Bottom Summary Bar
        Align(
          alignment: Alignment.bottomCenter,
          child: CartBottomSummary(
            totalItemCount: provider.totalItemCount,
            grandTotal: provider.grandTotal,
            orderLabel: provider.selectedTable != null
                ? 'Meja ${provider.selectedTable!.tableNumber}'
                : provider.orderType.displayName,
            onOpenCartDetail: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (ctx) => CartDetailSheet(
                  provider: provider,
                  onProceedPayment: () {
                    Navigator.pop(ctx);
                    provider.openPaymentDialog();
                  },
                  onSavePendingOrder: () {
                    Navigator.pop(ctx);
                    provider.processPayment(
                      paymentMethod: PaymentMethod.cash,
                      amountPaid: 0.0,
                      isPaidNow: false,
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
