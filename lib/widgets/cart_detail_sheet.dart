import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';
import '../models/table_model.dart';
import '../providers/restaurant_provider.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class CartDetailSheet extends StatelessWidget {
  final RestaurantProvider provider;
  final VoidCallback onProceedPayment;
  final VoidCallback onSavePendingOrder;

  const CartDetailSheet({
    super.key,
    required this.provider,
    required this.onProceedPayment,
    required this.onSavePendingOrder,
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
    return Container(
      height: MediaQuery.of(context).size.height * 0.90,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Ringkasan Pesanan',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      '${provider.totalItemCount} item dalam keranjang',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: AppColors.error),
                      onPressed: () {
                        provider.clearCart();
                        Navigator.pop(context);
                      },
                      tooltip: 'Kosongkan Keranjang',
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceLightBorder),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              children: [
                // 1. Order Type Chips
                const Text(
                  'Tipe Pemesanan',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: _OrderTypeChip(
                        label: 'Dine In',
                        icon: Icons.dining,
                        selected: provider.orderType == OrderType.dineIn,
                        onTap: () => provider.setOrderType(OrderType.dineIn),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _OrderTypeChip(
                        label: 'Takeaway',
                        icon: Icons.takeout_dining,
                        selected: provider.orderType == OrderType.takeaway,
                        onTap: () => provider.setOrderType(OrderType.takeaway),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _OrderTypeChip(
                        label: 'Delivery',
                        icon: Icons.delivery_dining,
                        selected: provider.orderType == OrderType.delivery,
                        onTap: () => provider.setOrderType(OrderType.delivery),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // 2. Table Selector (If Dine In)
                if (provider.orderType == OrderType.dineIn) ...[
                  const Text(
                    'Pilih Meja',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: provider.tables.map((table) {
                        final isSelected = provider.selectedTable?.id == table.id;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            selected: isSelected,
                            onSelected: (_) => provider.selectTable(isSelected ? null : table),
                            avatar: Icon(
                              Icons.table_bar,
                              size: 14,
                              color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                            ),
                            label: Text('Meja ${table.tableNumber}'),
                            labelStyle: TextStyle(
                              fontSize: 12,
                              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                            backgroundColor: AppColors.surfaceLightChip,
                            selectedColor: AppColors.primary,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],

                // 3. Customer Name Field
                TextField(
                  onChanged: (val) => provider.setCustomerName(val),
                  controller: TextEditingController(text: provider.customerName)..selection = TextSelection.fromPosition(TextPosition(offset: provider.customerName.length)),
                  decoration: InputDecoration(
                    labelText: 'Nama Pelanggan (Opsional)',
                    prefixIcon: const Icon(Icons.person_outline, size: 18),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // 4. Order Details Container
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.surfaceLightBorder.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.08),
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Order Details',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              '${provider.totalItemCount} ITEMS',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(height: 1, color: AppColors.surfaceLightBorder),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          children: provider.cartItems.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryContainer,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      _getCategoryIcon(item.menu.categoryName),
                                      color: AppColors.onPrimaryContainer,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.menu.name,
                                          style: const TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          'x ${item.quantity} · ${item.notes.isNotEmpty ? item.notes : item.menu.unit}',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.textSecondaryLight,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        RestaurantRepository.formatRupiah(item.subtotal),
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          InkWell(
                                            onTap: () => provider.updateCartQuantity(
                                              item.menu.id!,
                                              item.quantity - 1,
                                            ),
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: const BoxDecoration(
                                                color: AppColors.surfaceLightChip,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                item.quantity == 1 ? Icons.delete : Icons.remove,
                                                size: 12,
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(horizontal: 6),
                                            child: Text(
                                              '${item.quantity}',
                                              style: const TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                          InkWell(
                                            onTap: item.quantity < item.menu.stock
                                                ? () => provider.updateCartQuantity(
                                                      item.menu.id!,
                                                      item.quantity + 1,
                                                    )
                                                : null,
                                            borderRadius: BorderRadius.circular(12),
                                            child: Container(
                                              width: 22,
                                              height: 22,
                                              decoration: BoxDecoration(
                                                color: item.quantity < item.menu.stock
                                                    ? AppColors.primary
                                                    : AppColors.surfaceLightChip,
                                                shape: BoxShape.circle,
                                              ),
                                              child: Icon(
                                                Icons.add,
                                                size: 12,
                                                color: item.quantity < item.menu.stock
                                                    ? Colors.white
                                                    : AppColors.textSecondaryLight,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // 5. Discount Presets
                const Text(
                  'Diskon Promo',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [0.0, 5.0, 10.0, 15.0, 20.0].map((disc) {
                    final isSelected = provider.discountPercent == disc;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: FilterChip(
                          selected: isSelected,
                          onSelected: (_) => provider.setDiscountPercent(disc),
                          label: Text(disc == 0.0 ? '0%' : '${disc.toInt()}%'),
                          labelStyle: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                          ),
                          backgroundColor: AppColors.surfaceLightChip,
                          selectedColor: AppColors.primary,
                          showCheckmark: false,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                          side: BorderSide.none,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 14),

                // 6. Pricing Breakdown Box
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.surfaceLightBorder.withValues(alpha: 0.6)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Subtotal', style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                          Text(RestaurantRepository.formatRupiah(provider.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      if (provider.discountPercent > 0) ...[
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Diskon (${provider.discountPercent.toInt()}%)', style: const TextStyle(fontSize: 12, color: AppColors.error)),
                            Text('- ${RestaurantRepository.formatRupiah(provider.discountAmount)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.error)),
                          ],
                        ),
                      ],
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('PB1 / Pajak Resto (${provider.taxPercent.toInt()}%)', style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight)),
                          Text(RestaurantRepository.formatRupiah(provider.taxAmount), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 6),
                        child: Divider(height: 1, color: AppColors.surfaceLightBorder),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                          ),
                          Text(
                            RestaurantRepository.formatRupiah(provider.grandTotal),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                if (provider.orderType == OrderType.dineIn && provider.selectedTable != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onSavePendingOrder,
                      icon: const Icon(Icons.save, size: 16),
                      label: const Text('Simpan Meja', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        side: const BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: onProceedPayment,
                    icon: const Icon(Icons.payments, size: 16),
                    label: const Text('PROSES BAYAR', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrderTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _OrderTypeChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : AppColors.surfaceLightChip,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondaryLight),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.bold : FontWeight.w500,
                  color: selected ? Colors.white : AppColors.textPrimaryLight,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
