import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CategoryChipBar extends StatelessWidget {
  final List<String> categories;
  final String? selected;
  final ValueChanged<String?> onSelected;

  const CategoryChipBar({
    super.key,
    required this.categories,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: const Text('All'),
              selected: selected == null,
              selectedColor: AppTheme.primary.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primary,
              onSelected: (_) => onSelected(null),
            ),
          ),
          ...categories.map((c) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(c),
              selected: selected == c,
              selectedColor: AppTheme.primary.withValues(alpha: 0.15),
              checkmarkColor: AppTheme.primary,
              onSelected: (_) => onSelected(c),
            ),
          )),
        ],
      ),
    );
  }
}
