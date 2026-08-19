import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order_model.dart';
import '../models/table_model.dart';
import '../providers/restaurant_provider.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class TablesScreen extends StatelessWidget {
  const TablesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final tables = provider.tables;
    final orders = provider.orders;

    final sections = tables.map((t) => t.section).toSet().toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTableDialog(context, provider),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manajemen Meja & Denah',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimaryLight,
                  ),
                ),
                const Text(
                  'Pantau status meja pelanggan secara real-time',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
                const SizedBox(height: 12),

                // Status Legends
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _StatusLegend(
                      label: 'Kosong (${tables.where((t) => t.status == TableStatus.available).length})',
                      color: AppColors.success,
                    ),
                    _StatusLegend(
                      label: 'Terisi (${tables.where((t) => t.status == TableStatus.occupied).length})',
                      color: AppColors.error,
                    ),
                    _StatusLegend(
                      label: 'Reservasi (${tables.where((t) => t.status == TableStatus.reserved).length})',
                      color: AppColors.warning,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceLightBorder),

          // Grouped Sections List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 80),
              itemCount: sections.length,
              itemBuilder: (context, index) {
                final sectionName = sections[index];
                final sectionTables = tables.where((t) => t.section == sectionName).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Area $sectionName (${sectionTables.length} Meja)',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    const SizedBox(height: 8),

                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 1.25,
                      ),
                      itemCount: sectionTables.length,
                      itemBuilder: (context, tblIndex) {
                        final table = sectionTables[tblIndex];
                        final activeOrder = orders.cast<OrderWithItemsModel?>().firstWhere(
                              (o) => o?.order.id == table.activeOrderId,
                              orElse: () => null,
                            );

                        return _TableCard(
                          table: table,
                          activeOrder: activeOrder,
                          onTap: () {
                            if (table.status == TableStatus.available) {
                              provider.selectTable(table);
                              provider.setTab(AppNavTab.pos);
                            } else {
                              _showTableDetailSheet(context, table, activeOrder, provider);
                            }
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showAddTableDialog(BuildContext context, RestaurantProvider provider) {
    final numberCtrl = TextEditingController();
    final sectionCtrl = TextEditingController(text: 'Utama');
    final capCtrl = TextEditingController(text: '4');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tambah Meja Baru', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: numberCtrl,
              decoration: const InputDecoration(labelText: 'Nomor / Nama Meja (Contoh: 11, VIP-3)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: sectionCtrl,
              decoration: const InputDecoration(labelText: 'Area / Bagian (Utama, VIP, Outdoor)'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: capCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Kapasitas Kursi (Orang)'),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final number = numberCtrl.text.trim();
              final section = sectionCtrl.text.trim();
              final cleanCap = capCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
              final cap = int.tryParse(cleanCap) ?? 4;

              if (number.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Nomor meja tidak boleh kosong!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                return;
              }

              try {
                await provider.addTable(
                  number: number,
                  section: section.isNotEmpty ? section : 'Utama',
                  capacity: cap,
                );
                if (context.mounted) {
                  Navigator.pop(ctx);
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Gagal menambahkan meja: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Tambah Meja'),
          ),
        ],
      ),
    );
  }

  void _showTableDetailSheet(
    BuildContext context,
    TableModel table,
    OrderWithItemsModel? activeOrder,
    RestaurantProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Detail Meja ${table.tableNumber}',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Area ${table.section} • Kapasitas ${table.capacity} Orang',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),

            const Divider(height: 20),

            if (activeOrder != null) ...[
              Text(
                'Pesanan Aktif: ${activeOrder.order.invoiceNumber}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
              Text(
                'Pelanggan: ${activeOrder.order.customerName} • Waktu: ${RestaurantRepository.formatTimestamp(activeOrder.order.createdAt)}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
              ),
              const SizedBox(height: 10),

              // Items
              Container(
                constraints: const BoxConstraints(maxHeight: 160),
                child: ListView(
                  shrinkWrap: true,
                  children: activeOrder.items.map((it) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('${it.quantity}x ${it.menuName}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                          Text(RestaurantRepository.formatRupiah(it.subtotal), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),

              const Divider(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Tagihan', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  Text(
                    RestaurantRepository.formatRupiah(activeOrder.order.grandTotal),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: AppColors.primary),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.selectTable(table);
                        provider.setTab(AppNavTab.pos);
                      },
                      style: OutlinedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Tambah Menu'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        provider.openPaymentDialog(activeOrder);
                      },
                      icon: const Icon(Icons.payments, size: 16),
                      label: const Text('Bayar Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'Ubah Status Meja Secara Manual:',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateTableStatus(table.id!, TableStatus.available);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Kosong'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        provider.updateTableStatus(table.id!, TableStatus.reserved);
                        Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warning,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: const Text('Reservasi'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusLegend extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusLegend({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textPrimaryLight),
        ),
      ],
    );
  }
}

class _TableCard extends StatelessWidget {
  final TableModel table;
  final OrderWithItemsModel? activeOrder;
  final VoidCallback onTap;

  const _TableCard({
    required this.table,
    required this.activeOrder,
    required this.onTap,
  });

  Color _getStatusColor() {
    switch (table.status) {
      case TableStatus.available:
        return AppColors.success;
      case TableStatus.occupied:
        return AppColors.error;
      case TableStatus.reserved:
        return AppColors.warning;
      case TableStatus.billing:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _getStatusColor();

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: statusColor.withValues(alpha: 0.5), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Meja ${table.tableNumber}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      table.status.displayName,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),

              Row(
                children: [
                  const Icon(Icons.chair, size: 12, color: AppColors.textSecondaryLight),
                  const SizedBox(width: 4),
                  Text(
                    '${table.capacity} Orang',
                    style: const TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                  ),
                ],
              ),

              if (table.status == TableStatus.occupied && activeOrder != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLightElevated,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activeOrder!.order.customerName,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        RestaurantRepository.formatRupiah(activeOrder!.order.grandTotal),
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.primary),
                      ),
                    ],
                  ),
                )
              else if (table.status == TableStatus.available)
                const Text(
                  '+ Pesan Menu',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.success),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
