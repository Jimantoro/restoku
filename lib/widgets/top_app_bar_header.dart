import 'package:flutter/material.dart';
import '../models/table_model.dart';
import '../theme/app_colors.dart';

class TopAppBarHeader extends StatelessWidget {
  final String searchQuery;
  final ValueChanged<String> onSearchChange;
  final TableModel? selectedTable;
  final VoidCallback onTableClick;

  const TopAppBarHeader({
    super.key,
    required this.searchQuery,
    required this.onSearchChange,
    required this.selectedTable,
    required this.onTableClick,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Branding Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.restaurant_menu,
                      color: Colors.white,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RestoPOS',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryLight,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: const BoxDecoration(
                              color: AppColors.success,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'LOCAL DATABASE ACTIVE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.8,
                              color: AppColors.textSecondaryLight,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),

              // Table Quick Selector Pill
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onTableClick,
                  borderRadius: BorderRadius.circular(24),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: selectedTable != null
                          ? AppColors.primary
                          : AppColors.surfaceLightChip,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: selectedTable != null
                            ? AppColors.primary
                            : AppColors.surfaceLightBorder.withValues(alpha: 0.6),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.table_bar,
                          size: 16,
                          color: selectedTable != null
                              ? Colors.white
                              : AppColors.textSecondaryLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          selectedTable != null
                              ? 'Meja ${selectedTable!.tableNumber}'
                              : 'Pilih Meja',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: selectedTable != null
                                ? Colors.white
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Offline Mode Ready Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryContainer,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.surfaceLightBorderPurple),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.wifi_off,
                      size: 18,
                      color: AppColors.onPrimaryContainer,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Offline Mode Ready',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'LOCAL POS',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // Search Bar
          TextField(
            onChanged: onSearchChange,
            decoration: InputDecoration(
              hintText: 'Cari menu makanan, minuman...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textSecondaryLight),
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textSecondaryLight),
              filled: true,
              fillColor: AppColors.surfaceLightElevated,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
