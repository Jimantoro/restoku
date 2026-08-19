import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../theme/app_colors.dart';

class OrderItemNotesDialog extends StatefulWidget {
  final CartItemModel item;
  final ValueChanged<String> onSaveNotes;
  final VoidCallback onDismiss;

  const OrderItemNotesDialog({
    super.key,
    required this.item,
    required this.onSaveNotes,
    required this.onDismiss,
  });

  @override
  State<OrderItemNotesDialog> createState() => _OrderItemNotesDialogState();
}

class _OrderItemNotesDialogState extends State<OrderItemNotesDialog> {
  late TextEditingController _noteController;

  final List<String> _presetNotes = const [
    'Pedas Sedang',
    'Extra Pedas 🔥',
    'Tidak Pedas',
    'Tanpa Bawang',
    'Sedikit Minyak',
    'Es Dipisah',
    'Less Sugar (50%)',
    'Bungkus Terpisah',
  ];

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: widget.item.notes);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Catatan Pesanan',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              widget.item.menu.name,
              style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: 'Contoh: Pedas sedang, jangan pakai kecap...',
                hintStyle: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Catatan Cepat:',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textSecondaryLight),
            ),
            const SizedBox(height: 6),

            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: _presetNotes.map((preset) {
                final isSelected = _noteController.text.contains(preset);
                return FilterChip(
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      if (_noteController.text.isEmpty) {
                        _noteController.text = preset;
                      } else if (!_noteController.text.contains(preset)) {
                        _noteController.text = '${_noteController.text}, $preset';
                      }
                    });
                  },
                  label: Text(preset, style: TextStyle(fontSize: 11, color: isSelected ? Colors.white : AppColors.textPrimaryLight)),
                  backgroundColor: AppColors.surfaceLightChip,
                  selectedColor: AppColors.primary,
                  showCheckmark: false,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  side: BorderSide.none,
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: widget.onDismiss,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Batal'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    widget.onSaveNotes(_noteController.text.trim());
                    widget.onDismiss();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 0,
                  ),
                  child: const Text('Simpan Catatan'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
