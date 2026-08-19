import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../models/order_model.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class ReceiptModal extends StatelessWidget {
  final OrderWithItemsModel orderWithItems;
  final VoidCallback onDismiss;

  const ReceiptModal({
    super.key,
    required this.orderWithItems,
    required this.onDismiss,
  });

  void _shareReceiptText() {
    final order = orderWithItems.order;
    final items = orderWithItems.items;

    final buffer = StringBuffer();
    buffer.writeln('================================');
    buffer.writeln('       RESTO NUSANTARA');
    buffer.writeln('  STRUK PEMBAYARAN RESMI OFFLINE');
    buffer.writeln('================================');
    buffer.writeln('No Nota  : ${order.invoiceNumber}');
    buffer.writeln('Tanggal  : ${RestaurantRepository.formatTimestamp(order.createdAt)}');
    buffer.writeln('Kasir    : ${order.cashierName}');
    buffer.writeln('Tipe     : ${order.orderType.displayName} (${order.tableName})');
    if (order.customerName.isNotEmpty) {
      buffer.writeln('Pelanggan: ${order.customerName}');
    }
    buffer.writeln('--------------------------------');
    for (var item in items) {
      buffer.writeln(item.menuName);
      buffer.writeln('  ${item.quantity}x @${RestaurantRepository.formatRupiah(item.unitPrice)} = ${RestaurantRepository.formatRupiah(item.subtotal)}');
      if (item.notes.isNotEmpty) {
        buffer.writeln('  * Catatan: ${item.notes}');
      }
    }
    buffer.writeln('--------------------------------');
    buffer.writeln('Subtotal      : ${RestaurantRepository.formatRupiah(order.subtotal)}');
    if (order.discountAmount > 0) {
      buffer.writeln('Diskon (${order.discountPercent.toInt()}%)  : -${RestaurantRepository.formatRupiah(order.discountAmount)}');
    }
    buffer.writeln('Pajak PB1 (${order.taxRatePercent.toInt()}%): ${RestaurantRepository.formatRupiah(order.taxAmount)}');
    buffer.writeln('GRAND TOTAL   : ${RestaurantRepository.formatRupiah(order.grandTotal)}');
    buffer.writeln('Metode Bayar  : ${order.paymentMethod.displayName}');
    buffer.writeln('Bayar Diterima: ${RestaurantRepository.formatRupiah(order.amountPaid)}');
    buffer.writeln('Kembalian     : ${RestaurantRepository.formatRupiah(order.changeAmount)}');
    buffer.writeln('================================');
    buffer.writeln('Terima Kasih Atas Kunjungan Anda');

    Share.share(buffer.toString(), subject: 'Struk ${order.invoiceNumber}');
  }

  @override
  Widget build(BuildContext context) {
    final order = orderWithItems.order;
    final items = orderWithItems.items;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.success, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Struk Pembayaran',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Thermal Slip Paper Look
            Flexible(
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFDFCFA),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2DDD5)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const Text(
                        'RESTO NUSANTARA',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        'Jl. Kuliner Rasa No. 88, Jakarta',
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black54),
                      ),
                      const Text(
                        'Telp: (021) 555-1234 • Offline POS',
                        style: TextStyle(fontSize: 10, fontFamily: 'monospace', color: Colors.black54),
                      ),

                      const SizedBox(height: 6),
                      const _DashedDivider(),
                      const SizedBox(height: 6),

                      // Meta
                      _ReceiptRow(label: 'No. Nota', value: order.invoiceNumber),
                      _ReceiptRow(label: 'Tanggal', value: RestaurantRepository.formatTimestamp(order.createdAt)),
                      _ReceiptRow(label: 'Kasir', value: order.cashierName),
                      _ReceiptRow(label: 'Tipe', value: '${order.orderType.displayName} (${order.tableName})'),
                      if (order.customerName.isNotEmpty)
                        _ReceiptRow(label: 'Pelanggan', value: order.customerName),

                      const SizedBox(height: 6),
                      const _DashedDivider(),
                      const SizedBox(height: 6),

                      // Items
                      ...items.map((item) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2.5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item.menuName,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: 'monospace',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    RestaurantRepository.formatRupiah(item.subtotal),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'monospace',
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${item.quantity} x ${RestaurantRepository.formatRupiah(item.unitPrice)}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: Colors.black54,
                                    ),
                                  ),
                                  if (item.notes.isNotEmpty)
                                    Text(
                                      ' (${item.notes})',
                                      style: const TextStyle(
                                        fontSize: 9,
                                        fontFamily: 'monospace',
                                        color: Colors.black45,
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 6),
                      const _DashedDivider(),
                      const SizedBox(height: 6),

                      // Totals
                      _ReceiptRow(label: 'Subtotal', value: RestaurantRepository.formatRupiah(order.subtotal)),
                      if (order.discountAmount > 0)
                        _ReceiptRow(
                          label: 'Diskon (${order.discountPercent.toInt()}%)',
                          value: '- ${RestaurantRepository.formatRupiah(order.discountAmount)}',
                        ),
                      _ReceiptRow(
                        label: 'PB1 / Pajak (${order.taxRatePercent.toInt()}%)',
                        value: RestaurantRepository.formatRupiah(order.taxAmount),
                      ),

                      const SizedBox(height: 6),
                      const _DashedDivider(),
                      const SizedBox(height: 6),

                      _ReceiptRow(
                        label: 'GRAND TOTAL',
                        value: RestaurantRepository.formatRupiah(order.grandTotal),
                        isBold: true,
                      ),
                      _ReceiptRow(label: 'Metode Bayar', value: order.paymentMethod.displayName),
                      _ReceiptRow(label: 'Bayar / Diterima', value: RestaurantRepository.formatRupiah(order.amountPaid)),
                      _ReceiptRow(
                        label: 'Kembalian',
                        value: RestaurantRepository.formatRupiah(order.changeAmount),
                        isBold: true,
                      ),

                      if (order.referenceNumber.isNotEmpty)
                        _ReceiptRow(label: 'Ref / Auth', value: order.referenceNumber),

                      const SizedBox(height: 8),
                      const _DashedDivider(),
                      const SizedBox(height: 6),

                      const Text(
                        'TERIMA KASIH ATAS KUNJUNGAN ANDA\nLayanan Konsumen: 0812-3456-7890',
                        style: TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.black54),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Actions
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareReceiptText,
                    icon: const Icon(Icons.share, size: 16),
                    label: const Text('Bagikan Struk', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: onDismiss,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Selesai', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;

  const _ReceiptRow({
    required this.label,
    required this.value,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isBold ? 12 : 10,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 12 : 10,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontFamily: 'monospace',
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _DashedDivider extends StatelessWidget {
  const _DashedDivider();

  @override
  Widget build(BuildContext context) {
    return const Text(
      '- - - - - - - - - - - - - - - - - - - - - - - - - -',
      style: TextStyle(fontSize: 9, fontFamily: 'monospace', color: Colors.black26),
      maxLines: 1,
      overflow: TextOverflow.clip,
    );
  }
}
