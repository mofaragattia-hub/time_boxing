import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeboxing/models/category_model.dart';
import 'package:timeboxing/providers/category_provider.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? 'التصنيفات' : 'Categories'),
      ),
      body: Consumer<CategoryProvider>(
        builder: (context, categoryProvider, child) {
          return ListView.builder(
            itemCount: categoryProvider.categories.length,
            itemBuilder: (context, index) {
              final category = categoryProvider.categories[index];
              return ListTile(
                leading: Icon(
                  category.categoryIcon,
                  color: category.categoryColor,
                ),
                title: Text(category.name),
                trailing: IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _showCategoryDialog(context, category),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _showCategoryDialog(BuildContext context, [TaskCategory? category]) async {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final isEditing = category != null;
    
    String name = isEditing ? category.name : '';
    int color = isEditing ? category.color : Colors.blue.value;
    String icon = isEditing ? category.icon : 'e8f9';

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEditing 
          ? (isArabic ? 'تعديل التصنيف' : 'Edit Category')
          : (isArabic ? 'تصنيف جديد' : 'New Category')
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: isArabic ? 'اسم التصنيف' : 'Category Name',
              ),
              onChanged: (value) => name = value,
              controller: TextEditingController(text: name),
            ),
            const SizedBox(height: 16),
            // Here you can add color picker and icon picker
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(isArabic ? 'إلغاء' : 'Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.isNotEmpty) {
                final provider = Provider.of<CategoryProvider>(context, listen: false);
                final newCategory = TaskCategory(
                  id: isEditing ? category.id : DateTime.now().toString(),
                  name: name,
                  color: color,
                  icon: icon,
                );
                
                if (isEditing) {
                  provider.updateCategory(newCategory);
                } else {
                  provider.addCategory(newCategory);
                }
                Navigator.of(ctx).pop();
              }
            },
            child: Text(isArabic ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }
}