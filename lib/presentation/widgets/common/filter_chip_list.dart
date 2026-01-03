import 'package:flutter/material.dart';

class FilterChipList extends StatelessWidget {
  final List<String> categories = [
    'Tous',
    'excellent',
    'good',
    'fair',
    'poor',
  ];

  final String? selectedCategory;
  final Function(String?) onCategorySelected;

  FilterChipList({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'Tous':
        return 'Tous';
      case 'excellent':
        return 'Excellent';
      case 'good':
        return 'Bon';
      case 'fair':
        return 'Moyen';
      case 'poor':
        return 'Mauvais';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category == selectedCategory ||
              (category == 'Tous' && selectedCategory == null);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(_getCategoryLabel(category)),
              selected: isSelected,
              onSelected: (selected) {
                if (category == 'Tous') {
                  onCategorySelected(null);
                } else {
                  onCategorySelected(selected ? category : null);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }
}