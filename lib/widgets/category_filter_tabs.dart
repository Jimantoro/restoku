import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../theme/app_colors.dart';

class CategoryFilterTabs extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final ValueChanged<int?> onCategorySelected;

  const CategoryFilterTabs({
    super.key,
    required this.categories,
    required this.selectedCategoryId,
    required this.onCategorySelected,
  });

  IconData _getCategoryIcon(String iconName) {
    switch (iconName) {
      case 'Restaurant':
        return Icons.restaurant;
      case 'LunchDining':
        return Icons.lunch_dining;
      case 'SetMeal':
        return Icons.set_meal;
      case 'LocalBar':
        return Icons.local_bar;
      case 'Coffee':
        return Icons.coffee;
      case 'BakeryDining':
        return Icons.bakery_dining;
      default:
        return Icons.restaurant;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // "Semua Menu" chip
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: selectedCategoryId == null,
              onSelected: (_) => onCategorySelected(null),
              avatar: Icon(
                Icons.grid_view,
                size: 16,
                color: selectedCategoryId == null ? Colors.white : AppColors.textSecondaryLight,
              ),
              label: Text(
                'Semua Menu',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: selectedCategoryId == null ? FontWeight.bold : FontWeight.w500,
                  color: selectedCategoryId == null ? Colors.white : AppColors.textSecondaryLight,
                ),
              ),
              backgroundColor: AppColors.surfaceLightChip,
              selectedColor: AppColors.primary,
              showCheckmark: false,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              side: BorderSide.none,
            ),
          ),

          // Dynamic Category Chips
          ...categories.map((category) {
            final isSelected = selectedCategoryId == category.id;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilterChip(
                selected: isSelected,
                onSelected: (_) => onCategorySelected(category.id),
                avatar: Icon(
                  _getCategoryIcon(category.iconName),
                  size: 16,
                  color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                ),
                label: Text(
                  category.name,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? Colors.white : AppColors.textSecondaryLight,
                  ),
                ),
                backgroundColor: AppColors.surfaceLightChip,
                selectedColor: AppColors.primary,
                showCheckmark: false,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                side: BorderSide.none,
              ),
            );
          }),
        ],
      ),
    );
  }
}
