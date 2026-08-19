import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../providers/restaurant_provider.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final paidOrders = provider.orders.where((o) => o.order.status == OrderStatus.paid).toList();

    final totalRevenue = paidOrders.fold<double>(0.0, (sum, o) => sum + o.order.grandTotal);
    final totalOrdersCount = paidOrders.length;
    final averageTicket = totalOrdersCount > 0 ? totalRevenue / totalOrdersCount : 0.0;

    // Payment methods breakdown
    final cashTotal = paidOrders.where((o) => o.order.paymentMethod == PaymentMethod.cash).fold<double>(0.0, (sum, o) => sum + o.order.grandTotal);
    final qrisTotal = paidOrders.where((o) => o.order.paymentMethod == PaymentMethod.qrisOffline).fold<double>(0.0, (sum, o) => sum + o.order.grandTotal);
    final debitTotal = paidOrders.where((o) => o.order.paymentMethod == PaymentMethod.debitCard || o.order.paymentMethod == PaymentMethod.creditCard || o.order.paymentMethod == PaymentMethod.transferBank).fold<double>(0.0, (sum, o) => sum + o.order.grandTotal);

    // Top selling items aggregation
    final Map<String, int> itemSalesMap = {};
    for (var orderWithItems in paidOrders) {
      for (var item in orderWithItems.items) {
        final current = itemSalesMap[item.menuName] ?? 0;
        itemSalesMap[item.menuName] = current + item.quantity;
      }
    }
    final topItems = itemSalesMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topSixItems = topItems.take(6).toList();

    return Column(
      children: [
        // Header
        Container(
          color: Colors.white,
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Laporan Penjualan & Kasir',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
              ),
              Text(
                'Rekapitulasi pendapatan & transaksi offline',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ),

        const Divider(height: 1, color: AppColors.surfaceLightBorder),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [
              // 1. Total Omset Hero Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'TOTAL OMSET PENJUALAN',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withValues(alpha: 0.85),
                            letterSpacing: 1,
                          ),
                        ),
                        const Icon(Icons.trending_up, color: Colors.white, size: 20),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      RestaurantRepository.formatRupiah(totalRevenue),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Transaksi Selesai',
                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            Text(
                              '$totalOrdersCount Pesanan',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              'Rata-rata Nota',
                              style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                            Text(
                              RestaurantRepository.formatRupiah(averageTicket),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 2. Payment Method Breakdown Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Rincian Metode Pembayaran',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    _PaymentProgressRow(
                      label: 'Tunai (Cash)',
                      amount: cashTotal,
                      total: totalRevenue,
                      color: AppColors.success,
                      icon: Icons.payments_outlined,
                    ),
                    const SizedBox(height: 10),
                    _PaymentProgressRow(
                      label: 'QRIS Offline',
                      amount: qrisTotal,
                      total: totalRevenue,
                      color: AppColors.primary,
                      icon: Icons.qr_code_2,
                    ),
                    const SizedBox(height: 10),
                    _PaymentProgressRow(
                      label: 'Kartu Debit / EDC',
                      amount: debitTotal,
                      total: totalRevenue,
                      color: AppColors.info,
                      icon: Icons.credit_card,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // 3. Top Selling Menu Section
              const Text(
                'Menu Terlaris (Populer)',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              if (topSixItems.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Belum ada data penjualan menu.',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                  ),
                )
              else
                ...topSixItems.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;

                  Color rankColor;
                  switch (index) {
                    case 0:
                      rankColor = const Color(0xFFFFD700); // Gold
                      break;
                    case 1:
                      rankColor = const Color(0xFFC0C0C0); // Silver
                      break;
                    case 2:
                      rankColor = const Color(0xFFCD7F32); // Bronze
                      break;
                    default:
                      rankColor = AppColors.surfaceLightChip;
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: rankColor,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.Center,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: index < 3 ? Colors.black : AppColors.textPrimaryLight,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              item.key,
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${item.value} Porsi Terjual',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

              const SizedBox(height: 16),

              // 4. Offline Storage Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLightElevated,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.surfaceLightBorder.withValues(alpha: 0.5)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.sd_storage, color: AppColors.success, size: 24),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Database SQLite Lokal (sqflite)',
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '100% data transaksi tersimpan di memori perangkat, siap dipakai tanpa internet kapan saja.',
                            style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PaymentProgressRow extends StatelessWidget {
  final String label;
  final double amount;
  final double total;
  final Color color;
  final IconData icon;

  const _PaymentProgressRow({
    required this.label,
    required this.amount,
    required this.total,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (amount / total).clamp(0.0, 1.0) : 0.0;
    final percent = (progress * 100).toInt();

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
            ),
            Text(
              '${RestaurantRepository.formatRupiah(amount)} ($percent%)',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: color.withValues(alpha: 0.15),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}
