import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/menu_model.dart';
import '../providers/restaurant_provider.dart';
import '../repositories/restaurant_repository.dart';
import '../theme/app_colors.dart';
import '../widgets/category_filter_tabs.dart';

class MenuManagementScreen extends StatefulWidget {
  const MenuManagementScreen({super.key});

  @override
  State<MenuManagementScreen> createState() => _MenuManagementScreenState();
}

class _MenuManagementScreenState extends State<MenuManagementScreen> {
  int? _selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<RestaurantProvider>();
    final categories = provider.categories;
    final menus = provider.menus;

    final filteredMenus = _selectedCategoryId == null
        ? menus
        : menus.where((m) => m.categoryId == _selectedCategoryId).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceLight,
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showMenuFormDialog(context, provider, null),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Kelola Menu & Stok Bahan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                ),
                Text(
                  'Atur harga jual, kategori, dan stok hidangan resto',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: AppColors.surfaceLightBorder),

          // Categories Filter
          CategoryFilterTabs(
            categories: categories,
            selectedCategoryId: _selectedCategoryId,
            onCategorySelected: (catId) => setState(() => _selectedCategoryId = catId),
          ),

          // Menus List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
              itemCount: filteredMenus.length,
              itemBuilder: (context, index) {
                final menu = filteredMenus[index];
                return _MenuItemCard(
                  menu: menu,
                  onStockChange: (newStock) => provider.updateMenuStock(menu.id!, newStock),
                  onEdit: () => _showMenuFormDialog(context, provider, menu),
                  onDelete: () => _confirmDeleteMenu(context, provider, menu),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showMenuFormDialog(BuildContext context, RestaurantProvider provider, MenuModel? menu) {
    final nameCtrl = TextEditingController(text: menu?.name ?? '');
    final initialCatName = menu?.categoryName ?? (provider.categories.isNotEmpty ? provider.categories.first.name : 'Makanan Utama');
    final categoryCtrl = TextEditingController(text: initialCatName);
    final priceCtrl = TextEditingController(text: menu != null ? menu.price.toInt().toString() : '');
    final costPriceCtrl = TextEditingController(text: menu != null ? menu.costPrice.toInt().toString() : '');
    final stockCtrl = TextEditingController(text: menu != null ? menu.stock.toString() : '50');
    final descCtrl = TextEditingController(text: menu?.description ?? '');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        menu != null ? 'Edit Menu Makanan' : 'Tambah Menu Baru',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryLight),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // 1. Nama Hidangan
                  TextField(
                    controller: nameCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nama Hidangan',
                      hintText: 'Contoh: Nasi Goreng Spesial',
                      prefixIcon: const Icon(Icons.restaurant, size: 20),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // 2. Kategori (Bisa Ketik Langsung atau Pilih dari Dropdown/Chips)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextField(
                        controller: categoryCtrl,
                        onChanged: (_) => setModalState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Kategori (Ketik atau Pilih)',
                          hintText: 'Ketik nama kategori baru...',
                          prefixIcon: const Icon(Icons.category_outlined, size: 20),
                          suffixIcon: PopupMenuButton<String>(
                            icon: const Icon(Icons.arrow_drop_down_circle_outlined, color: AppColors.primary),
                            tooltip: 'Pilih dari daftar kategori yang ada',
                            onSelected: (String catName) {
                              setModalState(() {
                                categoryCtrl.text = catName;
                              });
                            },
                            itemBuilder: (ctx) => provider.categories.map((cat) {
                              return PopupMenuItem<String>(
                                value: cat.name,
                                child: Row(
                                  children: [
                                    const Icon(Icons.label_outline, size: 16, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Text(cat.name),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      // Saran Kategori Cepat (Chips)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: provider.categories.map((cat) {
                            final isSelected = categoryCtrl.text.trim().toLowerCase() == cat.name.toLowerCase();
                            return Padding(
                              padding: const EdgeInsets.only(right: 6),
                              child: ActionChip(
                                label: Text(
                                  cat.name,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                    color: isSelected ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                ),
                                backgroundColor: isSelected ? AppColors.primary : AppColors.surfaceLightChip,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                side: BorderSide.none,
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                                onPressed: () {
                                  setModalState(() {
                                    categoryCtrl.text = cat.name;
                                  });
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 3. Harga Jual & Stok Awal
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: priceCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Harga Jual (Rp)',
                            hintText: '25000',
                            prefixIcon: const Icon(Icons.payments_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: stockCtrl,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: 'Stok Awal',
                            hintText: '50',
                            prefixIcon: const Icon(Icons.inventory_2_outlined, size: 20),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // 4. Deskripsi Menu
                  TextField(
                    controller: descCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Deskripsi Menu (Opsional)',
                      hintText: 'Rasa gurih, pedas, disajikan dengan telur...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // Actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.pop(ctx),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Batal'),
                      ),
                      const SizedBox(width: 10),
                      ElevatedButton(
                        onPressed: () async {
                          final name = nameCtrl.text.trim();
                          final catName = categoryCtrl.text.trim();
                          final cleanPriceStr = priceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                          final cleanCostPriceStr = costPriceCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                          final cleanStockStr = stockCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

                          final price = double.tryParse(cleanPriceStr) ?? 0.0;
                          final costPrice = double.tryParse(cleanCostPriceStr) ?? 0.0;
                          final stock = int.tryParse(cleanStockStr) ?? 50;
                          final desc = descCtrl.text.trim();

                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Nama hidangan tidak boleh kosong!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (catName.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Kategori tidak boleh kosong!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          if (price <= 0) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Harga jual harus lebih besar dari 0!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            return;
                          }

                          try {
                            // Otomatis buat atau ambil kategori berdasarkan input teks
                            final category = await provider.getOrCreateCategory(catName);

                            if (menu != null) {
                              await provider.updateMenu(
                                menu.copyWith(
                                  name: name,
                                  categoryId: category.id,
                                  categoryName: category.name,
                                  price: price,
                                  costPrice: costPrice,
                                  description: desc,
                                  stock: stock,
                                ),
                              );
                            } else {
                              await provider.addNewMenu(
                                name: name,
                                categoryId: category.id!,
                                categoryName: category.name,
                                price: price,
                                costPrice: costPrice,
                                description: desc,
                                stock: stock,
                              );
                            }
                            if (context.mounted) {
                              Navigator.pop(ctx);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Gagal menyimpan menu: $e'),
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
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        child: const Text('Simpan', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _confirmDeleteMenu(BuildContext context, RestaurantProvider provider, MenuModel menu) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Menu?', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Apakah Anda yakin ingin menghapus "${menu.name}"?'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              provider.deleteMenu(menu.id!, menu.name);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  final MenuModel menu;
  final ValueChanged<int> onStockChange;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _MenuItemCard({
    required this.menu,
    required this.onStockChange,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      menu.name,
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${menu.categoryName} • ${RestaurantRepository.formatRupiah(menu.price)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.primary, size: 18),
                    onPressed: onEdit,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.delete, color: AppColors.error, size: 18),
                    onPressed: onDelete,
                    constraints: const BoxConstraints(),
                    padding: const EdgeInsets.all(6),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Stock Stepper Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLightElevated,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.inventory,
                      size: 16,
                      color: menu.stock > 0 ? AppColors.success : AppColors.error,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      menu.stock > 0 ? 'Sisa Stok: ${menu.stock} ${menu.unit}' : 'Stok Habis (0)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: menu.stock > 0 ? AppColors.textPrimaryLight : AppColors.error,
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    InkWell(
                      onTap: menu.stock > 0 ? () => onStockChange(menu.stock - 1) : null,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceLightChip,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.remove, size: 14),
                      ),
                    ),
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => onStockChange(menu.stock + 5),
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
