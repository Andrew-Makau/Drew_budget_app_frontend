import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

import '../../../../../core/app_export.dart';

class CategorySelectorWidget extends StatefulWidget {
  final Function(Map<String, dynamic>) onCategorySelected;
  final Map<String, dynamic>? selectedCategory;

  const CategorySelectorWidget({
    super.key,
    required this.onCategorySelected,
    this.selectedCategory,
  });

  @override
  State<CategorySelectorWidget> createState() => _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  final List<Map<String, dynamic>> categories = [
    {
      'id': 1,
      'name': 'Food & Dining',
      'icon': 'restaurant',
      'color': const Color(0xFFFF6B6B),
    },
    {
      'id': 2,
      'name': 'Transportation',
      'icon': 'directions_car',
      'color': const Color(0xFF4ECDC4),
    },
    {
      'id': 3,
      'name': 'Shopping',
      'icon': 'shopping_bag',
      'color': const Color(0xFFFFE66D),
    },
    {
      'id': 4,
      'name': 'Entertainment',
      'icon': 'movie',
      'color': const Color(0xFFA8E6CF),
    },
    {
      'id': 5,
      'name': 'Health',
      'icon': 'local_hospital',
      'color': const Color(0xFFFF8B94),
    },
    {
      'id': 6,
      'name': 'Bills & Utilities',
      'icon': 'receipt',
      'color': const Color(0xFFB4A7D6),
    },
    {
      'id': 7,
      'name': 'Travel',
      'icon': 'flight',
      'color': const Color(0xFF88D8B0),
    },
    {
      'id': 8,
      'name': 'Education',
      'icon': 'school',
      'color': const Color(0xFFFFC3A0),
    },
  ];

  Map<String, dynamic>? selectedCategory;

  @override
  void initState() {
    super.initState();
    selectedCategory = widget.selectedCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
        SizedBox(height: 2.h),
        SizedBox(
          height: 12.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (context, index) => SizedBox(width: 3.w),
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = selectedCategory?['id'] == category['id'];

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedCategory = category;
                  });
                  widget.onCategorySelected(category);
                  HapticFeedback.lightImpact();
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 20.w,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (category['color'] as Color).withValues(alpha: 0.2)
                        : AppTheme.lightTheme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? category['color'] as Color
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(2.w),
                        decoration: BoxDecoration(
                          color: (category['color'] as Color)
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomIconWidget(
                          iconName: category['icon'] as String,
                          color: category['color'] as Color,
                          size: 6.w,
                        ),
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        category['name'] as String,
                        style:
                            AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? category['color'] as Color
                              : AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                          fontWeight:
                              isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}