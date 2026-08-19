import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/restaurant_provider.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  OrderStatus? _selectedStatusFilter;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final orders = provider.orders;

    final filteredOrders = orders.where((item) {
      final matchesStatus = _selectedStatusFilter == null || item.order.status == _selectedStatusFilter;
      final matchesSearch = _searchQuery.trim().isEmpty ||
          item.order.invoiceNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.order.customerName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.order.tableName.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesStatus && matchesSearch;
    }).toList();

    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Riwayat Transaksi Offline',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              const Text(
                'Semua transaksi tersimpan aman di penyimpanan lokal',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 10),

              // Search Field
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Cari nomor nota, meja, atau nama...',
                  hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
                  prefixIcon: const Icon(Icons.search, size: 18, color: AppColors.textSecondaryLight),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                  filled: true,
                  fillColor: AppColors.surfaceLightElevated,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Status Filter Chips
              Row(
                children: [
                  FilterChip(
                    selected: _selectedStatusFilter == null,
                    onSelected: (_) => setState(() => _selectedStatusFilter = null),
                    label: Text('Semua (${orders.length})'),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedStatusFilter == null ? FontWeight.bold : FontWeight.w500,
                      color: _selectedStatusFilter == null ? Colors.white : AppColors.textSecondaryLight,
                    ),
                    backgroundColor: AppColors.surfaceLightChip,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    selected: _selectedStatusFilter == OrderStatus.paid,
                    onSelected: (_) => setState(() => _selectedStatusFilter = OrderStatus.paid),
                    label: Text('Lunas (${orders.where((o) => o.order.status == OrderStatus.paid).length})'),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedStatusFilter == OrderStatus.paid ? FontWeight.bold : FontWeight.w500,
                      color: _selectedStatusFilter == OrderStatus.paid ? Colors.white : AppColors.textSecondaryLight,
                    ),
                    backgroundColor: AppColors.surfaceLightChip,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                  ),
                  const SizedBox(width: 6),
                  FilterChip(
                    selected: _selectedStatusFilter == OrderStatus.pending,
                    onSelected: (_) => setState(() => _selectedStatusFilter = OrderStatus.pending),
                    label: Text('Pending (${orders.where((o) => o.order.status == OrderStatus.pending).length})'),
                    labelStyle: TextStyle(
                      fontSize: 11,
                      fontWeight: _selectedStatusFilter == OrderStatus.pending ? FontWeight.bold : FontWeight.w500,
                      color: _selectedStatusFilter == OrderStatus.pending ? Colors.white : AppColors.textSecondaryLight,
                    ),
                    backgroundColor: AppColors.surfaceLightChip,
                    selectedColor: AppColors.primary,
                    showCheckmark: false,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    side: BorderSide.none,
                  ),
                ],
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AppColors.surfaceLightBorder),

        // List
        Expanded(
          child: filteredOrders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long,
                          size: 56,
                          color: AppColors.textSecondaryLight.withValues(alpha: 0.4),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum Ada Riwayat Transaksi',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Transaksi yang diproses akan otomatis muncul di sini.',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  itemCount: filteredOrders.length,
                  itemBuilder: (context, index) {
                    final item = filteredOrders[index];
                    return _TransactionCard(
                      orderWithItems: item,
                      onViewReceipt: () => provider.openReceiptDialog(item),
                      onSettleBill: () => provider.openPaymentDialog(item),
                      onCancelOrder: () => _confirmCancelOrder(context, provider, item),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmCancelOrder(BuildContext context, RestaurantProvider provider, OrderWithItemsModel item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Batalkan Pesanan?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
          'Apakah Anda yakin ingin membatalkan pesanan ${item.order.invoiceNumber}? Stok bahan makanan akan otomatis dikembalikan.',
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.cancelOrder(item.order.id!);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Batalkan Pesanan'),
          ),
        ],
      ),
    );
  }
}

class _TransactionCard extends StatelessWidget {
  final OrderWithItemsModel orderWithItems;
  final VoidCallback onViewReceipt;
  final VoidCallback onSettleBill;
  final VoidCallback onCancelOrder;

  const _TransactionCard({
    required this.orderWithItems,
    required this.onViewReceipt,
    required this.onSettleBill,
    required this.onCancelOrder,
  });

  @override
  Widget build(BuildContext context) {
    final order = orderWithItems.order;
    final items = orderWithItems.items;

    Color statusColor;
    switch (order.status) {
      case OrderStatus.paid:
        statusColor = AppColors.success;
        break;
      case OrderStatus.pending:
        statusColor = AppColors.warning;
        break;
      case OrderStatus.cancelled:
        statusColor = AppColors.error;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onViewReceipt,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.invoiceNumber,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          RestaurantRepository.formatTimestamp(order.createdAt),
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        order.status.displayName,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${order.tableName} • ${order.customerName}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                    Text(
                      'Metode: ${order.paymentMethod.displayName}',
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Text(
                  items.map((it) => '${it.quantity}x ${it.menuName}').join(', '),
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimaryLight),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

                const Divider(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Grand Total', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight)),
                        Text(
                          RestaurantRepository.formatRupiah(order.grandTotal),
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.primary),
                        ),
                      ],
                    ),

                    Row(
                      children: [
                        if (order.status == OrderStatus.pending) ...[
                          OutlinedButton(
                            onPressed: onCancelOrder,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              side: const BorderSide(color: AppColors.error),
                            ),
                            child: const Text('Batal', style: TextStyle(fontSize: 11, color: AppColors.error)),
                          ),
                          const SizedBox(width: 6),
                          ElevatedButton(
                            onPressed: onSettleBill,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              elevation: 0,
                            ),
                            child: const Text('Bayar Bill', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                          ),
                        ] else ...[
                          OutlinedButton.icon(
                            onPressed: onViewReceipt,
                            icon: const Icon(Icons.receipt_long, size: 14),
                            label: const Text('Lihat Struk', style: TextStyle(fontSize: 11)),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
