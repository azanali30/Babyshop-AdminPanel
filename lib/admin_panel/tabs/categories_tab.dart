import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class CategoriesTab extends StatelessWidget {
  final FirestoreService firestoreService;
  CategoriesTab({required this.firestoreService});

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF7E57C2))),
          SizedBox(height: 16),
          Text('Loading Categories...', style: TextStyle(color: Color(0xFF7E57C2))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.category, size: 64, color: Colors.grey[400]),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Category Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage product categories',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () => _showAddCategoryDialog(context),
                icon: Icon(Icons.add, size: 20),
                label: Text('Add Category'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFF7C9D1),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
        ),

        // Categories List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getCategories(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingIndicator();

              final categories = snapshot.data!.docs.where((doc) => doc.data() != null).toList();

              if (categories.isEmpty) return _buildEmptyState('No categories found');

              return ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  return _buildCategoryCard(category, context);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryCard(QueryDocumentSnapshot category, BuildContext context) {
    final data = category.data() as Map<String, dynamic>;
    final name = data['name'] ?? 'Unnamed';
    final description = data['description'] ?? '';
    final imageUrl = data['image'] ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100],
            image: imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(imageUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: imageUrl.isEmpty ? Icon(Icons.category, color: Color(0xFF7E57C2)) : null,
        ),
        title: Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: description.isNotEmpty ? Text(description) : null,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF7E57C2)),
              onPressed: () => _showEditCategoryDialog(context, category),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _showDeleteDialog(context, category.id, name),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final imageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Add New Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Category Name', border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()), maxLines: 3),
            SizedBox(height: 16),
            TextField(controller: imageController, decoration: InputDecoration(labelText: 'Image URL (Optional)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                firestoreService.addCategory(
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                  imageController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category added successfully'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF7C9D1)),
            child: Text('Add Category'),
          ),
        ],
      ),
    );
  }

  void _showEditCategoryDialog(BuildContext context, QueryDocumentSnapshot category) {
    final data = category.data() as Map<String, dynamic>;
    final nameController = TextEditingController(text: data['name'] ?? '');
    final descriptionController = TextEditingController(text: data['description'] ?? '');
    final imageController = TextEditingController(text: data['image'] ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Category'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: InputDecoration(labelText: 'Category Name', border: OutlineInputBorder())),
            SizedBox(height: 16),
            TextField(controller: descriptionController, decoration: InputDecoration(labelText: 'Description (Optional)', border: OutlineInputBorder()), maxLines: 3),
            SizedBox(height: 16),
            TextField(controller: imageController, decoration: InputDecoration(labelText: 'Image URL (Optional)', border: OutlineInputBorder())),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                firestoreService.updateCategory(
                  category.id,
                  nameController.text.trim(),
                  descriptionController.text.trim(),
                  imageController.text.trim(),
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category updated successfully'), backgroundColor: Colors.green));
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF7C9D1)),
            child: Text('Update Category'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String categoryId, String categoryName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Category'),
        content: Text('Are you sure you want to delete "$categoryName"?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              firestoreService.deleteCategory(categoryId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Category deleted successfully'), backgroundColor: Colors.green));
            },
            style: ElevatedButton.styleFrom(backgroundColor: Color(0xFFF7C9D1)),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
