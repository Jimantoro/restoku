import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../providers/restaurant_provider.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';

class PaymentModal extends StatefulWidget {
  final RestaurantProvider provider;
  final OrderWithItemsModel? activeSettleOrder;
  final VoidCallback onDismiss;

  const PaymentModal({
    super.key,
    required this.provider,
    this.activeSettleOrder,
    required this.onDismiss,
  });

  @override
  State<PaymentModal> createState() => _PaymentModalState();
}

class _PaymentModalState extends State<PaymentModal> {
  late PaymentMethod _selectedMethod;
  late TextEditingController _cashController;
  String _selectedBank = 'BCA';
  final TextEditingController _cardTraceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  double get _grandTotal =>
      widget.activeSettleOrder?.order.grandTotal ?? widget.provider.grandTotal;

  @override
  void initState() {
    super.initState();
    _selectedMethod = PaymentMethod.cash;
    _cashController = TextEditingController(text: _grandTotal.toInt().toString());
  }

  @override
  void dispose() {
    _cashController.dispose();
    _cardTraceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cashAmountDouble = double.tryParse(_cashController.text) ?? 0.0;
    final changeAmount = cashAmountDouble - _grandTotal;
    final isCashSufficient = cashAmountDouble >= _grandTotal;

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
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
                    Text(
                      widget.activeSettleOrder != null
                          ? 'Pelunasan Tagihan Meja'
                          : 'Pembayaran Kasir Offline',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimaryLight,
                      ),
                    ),
                    Text(
                      widget.activeSettleOrder != null
                          ? '${widget.activeSettleOrder!.order.invoiceNumber} • ${widget.activeSettleOrder!.order.tableName}'
                          : '${widget.provider.selectedTable != null ? "Meja ${widget.provider.selectedTable!.tableNumber}" : widget.provider.orderType.displayName} • ${widget.provider.totalItemCount} Item',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onDismiss,
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceLightBorder),

          // Scrollable Content
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              children: [
                // 1. Grand Total Card
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'TOTAL YANG HARUS DIBAYAR',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                          letterSpacing: 1,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        RestaurantRepository.formatRupiah(_grandTotal),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 2. Payment Method Selector
                const Text(
                  'Metode Pembayaran',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _MethodChip(
                        name: 'Tunai (Cash)',
                        icon: Icons.payments_outlined,
                        selected: _selectedMethod == PaymentMethod.cash,
                        onTap: () => setState(() => _selectedMethod = PaymentMethod.cash),
                      ),
                      const SizedBox(width: 8),
                      _MethodChip(
                        name: 'QRIS Offline',
                        icon: Icons.qr_code_2,
                        selected: _selectedMethod == PaymentMethod.qrisOffline,
                        onTap: () => setState(() => _selectedMethod = PaymentMethod.qrisOffline),
                      ),
                      const SizedBox(width: 8),
                      _MethodChip(
                        name: 'Debit / EDC',
                        icon: Icons.credit_card,
                        selected: _selectedMethod == PaymentMethod.debitCard,
                        onTap: () => setState(() => _selectedMethod = PaymentMethod.debitCard),
                      ),
                      const SizedBox(width: 8),
                      _MethodChip(
                        name: 'Transfer Bank',
                        icon: Icons.account_balance,
                        selected: _selectedMethod == PaymentMethod.transferBank,
                        onTap: () => setState(() => _selectedMethod = PaymentMethod.transferBank),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // 3. Method-Specific Views
                if (_selectedMethod == PaymentMethod.cash) ...[
                  TextField(
                    controller: _cashController,
                    keyboardType: TextInputType.number,
                    onChanged: (_) => setState(() {}),
                    decoration: InputDecoration(
                      labelText: 'Nominal Uang Tunai Diterima (Rp)',
                      prefixIcon: const Icon(Icons.money, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Quick Presets
                  const Text(
                    'Pilihan Cepat:',
                    style: TextStyle(fontSize: 11, color: AppColors.textSecondaryLight),
                  ),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: _generatePresets(_grandTotal).map((preset) {
                        final isSelected = _cashController.text == preset.toInt().toString();
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            selected: isSelected,
                            onSelected: (_) => setState(() {
                              _cashController.text = preset.toInt().toString();
                            }),
                            label: Text(
                              preset == _grandTotal
                                  ? 'Uang Pas (${RestaurantRepository.formatRupiah(preset)})'
                                  : RestaurantRepository.formatRupiah(preset),
                            ),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
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

                  const SizedBox(height: 12),

                  // Change status box
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isCashSufficient
                          ? AppColors.success.withValues(alpha: 0.1)
                          : AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isCashSufficient
                            ? AppColors.success.withValues(alpha: 0.4)
                            : AppColors.error.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isCashSufficient ? 'KEMBALIAN' : 'UANG KURANG',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isCashSufficient ? AppColors.success : AppColors.error,
                              ),
                            ),
                            Text(
                              isCashSufficient
                                  ? RestaurantRepository.formatRupiah(changeAmount)
                                  : RestaurantRepository.formatRupiah(_grandTotal - cashAmountDouble),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: isCashSufficient ? AppColors.success : AppColors.error,
                              ),
                            ),
                          ],
                        ),
                        Icon(
                          isCashSufficient ? Icons.check_circle : Icons.cancel,
                          color: isCashSufficient ? AppColors.success : AppColors.error,
                          size: 26,
                        ),
                      ],
                    ),
                  ),
                ] else if (_selectedMethod == PaymentMethod.qrisOffline) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLightElevated,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.surfaceLightBorder.withValues(alpha: 0.6)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'QRIS STANDAR PEMBAYARAN NASIONAL',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                        ),
                        const Text(
                          'RESTO KASIR OFFLINE',
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary),
                        ),
                        const Text(
                          'NMID: ID1020268874100 • Offline Mode',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: 160,
                          height: 160,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.black, width: 2),
                          ),
                          child: CustomPaint(
                            size: const Size(140, 140),
                            painter: _QrisMatrixPainter(seed: _grandTotal.toInt()),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Tunjukkan QR ini ke pelanggan untuk di-scan via m-Banking/E-Wallet.',
                          style: TextStyle(fontSize: 10, color: AppColors.textSecondaryLight),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ] else if (_selectedMethod == PaymentMethod.debitCard) ...[
                  const Text('Pilih Mesin Bank EDC:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['BCA', 'Mandiri', 'BRI', 'BNI', 'CIMB'].map((bank) {
                        final isSelected = _selectedBank == bank;
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: FilterChip(
                            selected: isSelected,
                            onSelected: (_) => setState(() => _selectedBank = bank),
                            label: Text(bank),
                            labelStyle: TextStyle(
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                            ),
                            backgroundColor: AppColors.surfaceLightChip,
                            selectedColor: AppColors.primary,
                            showCheckmark: false,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                            side: BorderSide.none,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _cardTraceController,
                    decoration: InputDecoration(
                      labelText: 'No. Approval / Ref EDC (Opsional)',
                      hintText: 'Contoh: 894321',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ] else if (_selectedMethod == PaymentMethod.transferBank) ...[
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.info.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Transfer Rekening Kasir Resto',
                          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.info),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'BCA: 873-091-2244 a/n Resto Nusantara\nMandiri: 137-00-982134-1',
                          style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 14),

                // 4. Notes
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: 'Catatan Transaksi (Opsional)',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Submit Button
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
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: (_selectedMethod != PaymentMethod.cash || isCashSufficient)
                    ? () {
                        final paid = (_selectedMethod == PaymentMethod.cash)
                            ? cashAmountDouble
                            : _grandTotal;

                        if (widget.activeSettleOrder != null) {
                          widget.provider.processSettlePending(
                            orderId: widget.activeSettleOrder!.order.id!,
                            paymentMethod: _selectedMethod,
                            amountPaid: paid,
                          );
                        } else {
                          widget.provider.processPayment(
                            paymentMethod: _selectedMethod,
                            amountPaid: paid,
                            isPaidNow: true,
                            notes: _notesController.text,
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.print, size: 18),
                label: const Text(
                  'SELESAIKAN & CETAK STRUK',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<double> _generatePresets(double total) {
    final exact = total;
    final nextFifty = (total / 50000).ceil() * 50000.0;
    final nextHundred = (total / 100000).ceil() * 100000.0;

    final set = <double>{exact};
    if (nextFifty > exact) set.add(nextFifty);
    if (nextHundred > exact && nextHundred != nextFifty) set.add(nextHundred);
    set.add(50000.0);
    set.add(100000.0);
    set.add(200000.0);
    return set.toList();
  }
}

class _MethodChip extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _MethodChip({
    required this.name,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: (_) => onTap(),
      avatar: Icon(icon, size: 16, color: selected ? Colors.white : AppColors.textSecondaryLight),
      label: Text(name),
      labelStyle: TextStyle(
        fontSize: 11,
        fontWeight: selected ? FontWeight.bold : FontWeight.w500,
        color: selected ? Colors.white : AppColors.textPrimaryLight,
      ),
      backgroundColor: AppColors.surfaceLightChip,
      selectedColor: AppColors.primary,
      showCheckmark: false,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      side: BorderSide.none,
    );
  }
}

class _QrisMatrixPainter extends CustomPainter {
  final int seed;

  _QrisMatrixPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    const gridSize = 16;
    final cellSize = size.width / gridSize;

    for (int i = 0; i < gridSize; i++) {
      for (int j = 0; j < gridSize; j++) {
        final isTopLeftFinder = i < 4 && j < 4;
        final isTopRightFinder = i >= gridSize - 4 && j < 4;
        final isBottomLeftFinder = i < 4 && j >= gridSize - 4;

        bool isBlack;
        if (isTopLeftFinder || isTopRightFinder || isBottomLeftFinder) {
          isBlack = (i == 0 || i == 3 || j == 0 || j == 3 ||
              (i == 1 && j == 1) || (i == 2 && j == 2) || (i == 1 && j == 2) || (i == 2 && j == 1));
        } else {
          isBlack = ((i * 17 + j * 31 + seed) % 3) == 0;
        }

        if (isBlack) {
          canvas.drawRect(
            Rect.fromLTWH(i * cellSize, j * cellSize, cellSize, cellSize),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _QrisMatrixPainter oldDelegate) => oldDelegate.seed != seed;
}
