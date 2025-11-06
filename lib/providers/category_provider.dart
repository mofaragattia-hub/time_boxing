import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:timeboxing/models/category_model.dart';

class CategoryProvider with ChangeNotifier {
  final String _boxName = 'categoriesBox';
  Box<TaskCategory>? _box;

  List<TaskCategory> _categories = [];
  List<TaskCategory> get categories => _categories;

  CategoryProvider() {
    _init();
  }

  Future<void> _init() async {
    _box = await Hive.openBox<TaskCategory>(_boxName);
    _loadCategories();
    if (_categories.isEmpty) {
      await _createDefaultCategories();
    }
  }

  void _loadCategories() {
    _categories = _box!.values.toList();
    notifyListeners();
  }

  Future<void> _createDefaultCategories() async {
    final defaultCategories = [
      TaskCategory(
        id: 'work',
        name: 'Work',
        color: 0xFF2196F3, // Blue
        icon: 0xe8f9, // work icon
      ),
      TaskCategory(
        id: 'personal',
        name: 'Personal',
        color: 0xFF4CAF50, // Green
        icon: 0xe7fd, // person icon
      ),
      TaskCategory(
        id: 'study',
        name: 'Study',
        color: 0xFFFFC107, // Amber
        icon: 0xe80c, // school icon
      ),
      TaskCategory(
        id: 'health',
        name: 'Health',
        color: 0xFFF44336, // Red
        icon: 0xe3f6, // health icon
      ),
    ];

    for (final category in defaultCategories) {
      await _box!.put(category.id, category);
    }
    _loadCategories();
  }

  Future<void> addCategory(TaskCategory category) async {
    await _box!.put(category.id, category);
    _loadCategories();
  }

  Future<void> updateCategory(TaskCategory category) async {
    await _box!.put(category.id, category);
    _loadCategories();
  }

  Future<void> deleteCategory(TaskCategory category) async {
    await _box!.delete(category.id);
    _loadCategories();
  }
}