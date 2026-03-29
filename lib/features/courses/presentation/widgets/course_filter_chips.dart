import 'package:e_learning/core/constants/design_tokens.dart';
import 'package:e_learning/core/utils/arabic_mapper.dart';
import 'package:flutter/material.dart';

class CourseFilterChips extends StatelessWidget {
  const CourseFilterChips({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: categories
          .map(
            (category) => ChoiceChip(
              label: Text(ArabicMapper.category(category)),
              selected: category == selectedCategory,
              onSelected: (_) => onSelected(category),
            ),
          )
          .toList(),
    );
  }
}
