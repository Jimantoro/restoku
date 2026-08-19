import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category_model.dart';
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
    final priceCtrl = TextEditingController(text: menu != null ? menu.price.toInt().toString() : '');
    final costPriceCtrl = TextEditingController(text: menu != null ? menu.costPrice.toInt().toString() : '');
    final stockCtrl = TextEditingController(text: menu != null ? menu.stock.toString() : '50');
    final descCtrl = TextEditingController(text: menu?.description ?? '');

    CategoryModel? selectedCategory = menu != null
        ? provider.categories.cast<CategoryModel?>().firstWhere((c) => c?.id == menu.categoryId, orElse: () => null)
        : (provider.categories.isNotEmpty ? provider.categories.first : null);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(menu != null ? 'Edit Menu Makanan' : 'Tambah Menu Baru', style: const TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Nama Hidangan'),
                ),
                const SizedBox(height: 10),

                // Category Dropdown
                DropdownButtonFormField<CategoryModel>(
                  value: selectedCategory,
                  decoration: const InputDecoration(labelText: 'Kategori'),
                  items: provider.categories.map((cat) {
                    return DropdownMenuItem(value: cat, child: Text(cat.name));
                  }).toList(),
                  onChanged: (cat) => setModalState(() => selectedCategory = cat),
                ),
                const SizedBox(height: 10),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: priceCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Harga Jual (Rp)'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: stockCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Stok Awal'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),

                TextField(
                  controller: descCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(labelText: 'Deskripsi Menu (Opsional)'),
                ),
              ],
            ),
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameCtrl.text.trim().isNotEmpty && selectedCategory != null && priceCtrl.text.isNotEmpty) {
                  if (menu != null) {
                    provider.updateMenu(
                      menu.copyWith(
                        name: nameCtrl.text.trim(),
                        categoryId: selectedCategory!.id,
                        categoryName: selectedCategory!.name,
                        price: double.tryParse(priceCtrl.text) ?? 0.0,
                        costPrice: double.tryParse(costPriceCtrl.text) ?? 0.0,
                        description: descCtrl.text.trim(),
                        stock: int.tryParse(stockCtrl.text) ?? 0,
                      ),
                    );
                  } else {
                    provider.addNewMenu(
                      name: nameCtrl.text.trim(),
                      categoryId: selectedCategory!.id!,
                      categoryName: selectedCategory!.name,
                      price: double.tryParse(priceCtrl.text) ?? 0.0,
                      costPrice: double.tryParse(costPriceCtrl.text) ?? 0.0,
                      description: descCtrl.text.trim(),
                      stock: int.tryParse(stockCtrl.text) ?? 0,
                    );
                  }
                  Navigator.pop(ctx);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Simpan'),
            ),
          ],
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
