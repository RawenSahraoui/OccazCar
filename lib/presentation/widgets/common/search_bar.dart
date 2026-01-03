import 'package:flutter/material.dart';

class VehicleSearchBar extends StatelessWidget {
  final String? searchQuery;
  final Function(String) onSearchChanged;

  const VehicleSearchBar({
    Key? key,
    this.searchQuery,
    required this.onSearchChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        onChanged: onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher une voiture...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: searchQuery != null && searchQuery!.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () => onSearchChanged(''),
          )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }
}