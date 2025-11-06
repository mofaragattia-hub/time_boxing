import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3)
class TaskCategory extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  int color;

  @HiveField(3)
  int icon;

  TaskCategory({
    required this.id,
    required this.name,
    required this.color,
    required this.icon,
  });

  Color get categoryColor => Color(color);
  /// The raw code point for the icon. Convert to [IconData] in widgets by
  /// using `Icon(IconData(category.icon, fontFamily: 'MaterialIcons'))`.
  int get iconCodePoint => icon;
}