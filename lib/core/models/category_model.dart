import 'package:flutter/material.dart';

class CategoryModel {
  String id;
  String name;
  IconData icon;

  CategoryModel({
    required this.id,
    required this.name,
    required this.icon,
  });

  static List<CategoryModel> getCategoriesWithAll(BuildContext context) {
    return [
      CategoryModel(id: 'all', name: 'All', icon: Icons.explore),
      CategoryModel(id: 'sports', name: 'Sports', icon: Icons.sports_baseball),
      CategoryModel(id: 'meeting', name: 'Meeting', icon: Icons.meeting_room),
      CategoryModel(id: 'workshop', name: 'Workshop', icon: Icons.work),
      CategoryModel(id: 'gaming', name: 'Gaming', icon: Icons.games),
      CategoryModel(id: 'eating', name: 'Eating', icon: Icons.fastfood),
    ];
  }
}
