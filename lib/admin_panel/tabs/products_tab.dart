import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';
import '../add_edit_product_page.dart';

class ProductsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  ProductsTab({required this.firestoreService});

  // Updated to match login screen color theme
  final Color _primaryColor = Color(0xFF773D44);
  final Color _backgroundColor = Colors.white;
  final Color _accentColor = Color(0xFF773D44).withOpacity(0.1);
  final Color _iconColor = Color(0xFF773D44);
  final Color _textColor = Color(0xFF773D44);
  final Color _cardColor = Colors.white;

  Widget _buildLoadingIndicator(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(scheme.secondary)),
          SizedBox(height: 16),
          Text('Loading Products...', style: TextStyle(color: scheme.tertiary)),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inventory_2, size: 64, color: Colors.grey[400]),
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
            color: _cardColor,
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
                    'Product Management',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Manage your product inventory',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditProductPage(firestoreService: firestoreService),
                    ),
                  );
                },
                icon: Icon(Icons.add, size: 20),
                label: Text('Add Product'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // Products List
        Expanded(
          child: Container(
            color: _backgroundColor,
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator(context);
                if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No products found');
                
                final products = snapshot.data!.docs;
                return ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return _buildProductCard(p, context);
                  },
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot p, BuildContext context) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            image: p['image'] != null && p['image'].isNotEmpty 
                ? DecorationImage(
                    image: NetworkImage(p['image']),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: p['image'] == null || p['image'].isEmpty 
              ? Icon(Icons.inventory_2, color: Theme.of(context).colorScheme.secondary)
              : null,
        ),
        title: Text(
          p['name'],
          style: TextStyle(fontWeight: FontWeight.w600, color: Theme.of(context).colorScheme.tertiary),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${p['price']}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            SizedBox(height: 4),
            Row(
              children: [
                Chip(
                  label: Text('Stock: ${p['stock']}'),
                  backgroundColor: Colors.green[50],
                  labelStyle: TextStyle(color: Colors.green, fontSize: 12),
                ),
                SizedBox(width: 8),
                Chip(
                  label: Text(p['category']),
                  backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.secondary),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddEditProductPage(
                      firestoreService: firestoreService,
                      productId: p.id,
                      existingData: p.data() as Map<String, dynamic>,
                    ),
                  ),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red.shade600),
              onPressed: () => _showDeleteDialog(context, p.id, p['name']),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, String productId, String productName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Product', style: TextStyle(color: Theme.of(context).colorScheme.tertiary)),
        content: Text('Are you sure you want to delete "$productName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreService.deleteProduct(productId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.shade600),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
