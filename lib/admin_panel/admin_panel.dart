import 'package:flutter/material.dart';
import '/services/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../auth/login_screen.dart';



class AdminPanel extends StatefulWidget {
  @override
  _AdminPanelState createState() => _AdminPanelState();
}

class _AdminPanelState extends State<AdminPanel> {
  final FirestoreService firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;  // <- Ye line honi chahiye
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    ProductsTab(firestoreService: FirestoreService()),
    OrdersTab(firestoreService: FirestoreService()),
    UsersTab(firestoreService: FirestoreService()),
    ReviewsTab(firestoreService: FirestoreService()),
    SupportTab(firestoreService: FirestoreService()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F4),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.child_care, color: Colors.white),
            SizedBox(width: 8),
            Text('BabyShop Admin',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20)),
          ],
        ),
        backgroundColor: Color(0xFF6A8EAE),
        elevation: 0,
        actions: [
          // Logout Button
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _showLogoutDialog(context),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F6F4),
              Color(0xFFE8F4F8),
            ],
          ),
        ),
        child: _tabs[_currentIndex],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

void _showLogoutDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Row(
        children: [
          Icon(Icons.logout, color: Colors.orange),
          SizedBox(width: 8),
          Text('Logout Confirmation'),
        ],
      ),
      content: Text('Are you sure you want to logout from Admin Panel?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel', style: TextStyle(color: Colors.grey)),
        ),
        ElevatedButton(
          onPressed: () async {
            try {
              await _auth.signOut();  // Firebase se logout
              
              // Dialog close
              Navigator.pop(context);

              // Navigate to LoginScreen and remove all previous routes
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
              );

            } catch (e) {
              // Agar koi error aaye to show snackbar
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Logout failed: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          style: ElevatedButton.styleFrom(backgroundColor: Color(0xFF6A8EAE)),
          child: Text('Logout'),
        ),
      ],
    ),
  );
}




  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Color(0xFF6A8EAE),
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        unselectedLabelStyle: TextStyle(fontSize: 11),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_basket),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Reviews',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.support_agent),
            label: 'Support',
          ),
        ],
      ),
    );
  }
}

// ---------------- Products Tab ----------------
class ProductsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  ProductsTab({required this.firestoreService});

  // Common Widgets for ProductsTab only
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6A8EAE))),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Color(0xFF6A8EAE))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Color(0xFF6A8EAE).withOpacity(0.5)),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFD6DC),
                child: Icon(Icons.shopping_basket, color: Color(0xFF6A8EAE)),
              ),
              title: Text('Product Management',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Add, edit or remove baby products'),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              // Navigate to Add Product Page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddEditProductPage(firestoreService: firestoreService),
                ),
              );
            },
            icon: Icon(Icons.add_circle_outline),
            label: Text('Add New Product'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF6A8EAE),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getProducts(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No products found');
                
                final products = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return _buildProductCard(p, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(QueryDocumentSnapshot p, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE8F4F8),
          backgroundImage: p['image'] != null && p['image'].isNotEmpty 
              ? NetworkImage(p['image']) 
              : null,
          child: p['image'] == null || p['image'].isEmpty 
              ? Icon(Icons.child_care, color: Color(0xFF6A8EAE))
              : null,
        ),
        title: Text(p['name'], style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('₹${p['price']}', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            Text('Stock: ${p['stock']} • ${p['category']}', style: TextStyle(fontSize: 12)),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Color(0xFF6A8EAE)),
              onPressed: () {
                // Navigate to Edit Product Page
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
              icon: Icon(Icons.delete, color: Colors.redAccent),
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
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
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
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Add/Edit Product PAGE (Not Dialog) ----------------
class AddEditProductPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String? productId;
  final Map<String, dynamic>? existingData;

  AddEditProductPage({required this.firestoreService, this.productId, this.existingData});

  @override
  _AddEditProductPageState createState() => _AddEditProductPageState();
}

class _AddEditProductPageState extends State<AddEditProductPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameController;
  late TextEditingController priceController;
  late TextEditingController stockController;
  late TextEditingController categoryController;
  late TextEditingController imageController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.existingData?['name'] ?? '');
    priceController = TextEditingController(text: widget.existingData?['price']?.toString() ?? '');
    stockController = TextEditingController(text: widget.existingData?['stock']?.toString() ?? '');
    categoryController = TextEditingController(text: widget.existingData?['category'] ?? '');
    imageController = TextEditingController(text: widget.existingData?['image'] ?? '');
    descriptionController = TextEditingController(text: widget.existingData?['description'] ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F6F4),
      appBar: AppBar(
        title: Text(
          widget.productId == null ? 'Add New Product' : 'Edit Product',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF6A8EAE),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.productId != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.white),
              onPressed: () => _showDeleteDialog(context),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Header Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Color(0xFFFFD6DC),
                        child: Icon(Icons.child_care, color: Color(0xFF6A8EAE), size: 30),
                        radius: 25,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.productId == null ? 'Add New Product' : 'Edit Product',
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Fill in the product details below',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              SizedBox(height: 20),
              
              // Product Image Preview
              if (imageController.text.isNotEmpty)
                Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: NetworkImage(imageController.text),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              
              if (imageController.text.isNotEmpty) SizedBox(height: 16),
              
              // Form Fields
              _buildTextField(nameController, 'Product Name', Icons.toys),
              _buildTextField(priceController, 'Price', Icons.attach_money, TextInputType.number),
              _buildTextField(stockController, 'Stock Quantity', Icons.inventory_2, TextInputType.number),
              _buildTextField(categoryController, 'Category', Icons.category),
              _buildTextField(imageController, 'Image URL', Icons.image),
              _buildTextField(descriptionController, 'Description', Icons.description, TextInputType.multiline, 3),
              
              SizedBox(height: 30),
              
              // Save Button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A8EAE),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    widget.productId == null ? 'Add Product' : 'Update Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, 
                        [TextInputType? keyboardType, int maxLines = 1]) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12),
        child: TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            prefixIcon: Icon(icon, color: Color(0xFF6A8EAE)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
          ),
          validator: (v) => v!.isEmpty ? 'This field is required' : null,
          onChanged: (value) {
            if (label == 'Image URL') {
              setState(() {}); // Refresh to update image preview
            }
          },
        ),
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': nameController.text,
        'price': double.parse(priceController.text),
        'stock': int.parse(stockController.text),
        'category': categoryController.text,
        'image': imageController.text,
        'description': descriptionController.text,
      };

      if (widget.productId == null) {
        final id = DateTime.now().millisecondsSinceEpoch.toString();
        widget.firestoreService.addProduct(
          id,
          data['name'] as String,
          (data['price'] as num).toDouble(),
          data['image'] as String,
          data['category'] as String,
          (data['stock'] as num).toInt(),
        );
      } else {
        widget.firestoreService.updateProduct(widget.productId!, data);
      }

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.productId == null ? 'Product added successfully!' : 'Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Product'),
          ],
        ),
        content: Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              widget.firestoreService.deleteProduct(widget.productId!);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to products list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Product deleted successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Orders Tab ----------------
class OrdersTab extends StatelessWidget {
  final FirestoreService firestoreService;
  OrdersTab({required this.firestoreService});

  // Common Widgets for OrdersTab only
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6A8EAE))),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Color(0xFF6A8EAE))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Color(0xFF6A8EAE).withOpacity(0.5)),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFD6DC),
                child: Icon(Icons.receipt_long, color: Color(0xFF6A8EAE)),
              ),
              title: Text('Order Management', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Manage customer orders and status'),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getOrders(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No orders found');
                
                final orders = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final o = orders[index];
                    return _buildOrderCard(o);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

Widget _buildOrderCard(QueryDocumentSnapshot o) {
  Color statusColor = Colors.orange;
  if (o['status'] == 'shipped') statusColor = Colors.blue;
  if (o['status'] == 'delivered') statusColor = Colors.green;

  // Safe value for dropdown
  String currentStatus = o['status'] ?? 'pending';
  if (!['pending', 'shipped', 'delivered'].contains(currentStatus)) {
    currentStatus = 'pending';
  }

  return Card(
    margin: EdgeInsets.symmetric(vertical: 6),
    elevation: 2,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Color(0xFFE8F4F8),
        child: Icon(Icons.shopping_cart, color: Color(0xFF6A8EAE)),
      ),
      title: Text('Order #${o.id.substring(0, 8)}', style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Total: ₹${o['total']}', style: TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Text(
                  currentStatus.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
      trailing: DropdownButton<String>(
        value: currentStatus,
        items: ['pending', 'shipped', 'delivered']
            .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status, style: TextStyle(color: Color(0xFF6A8EAE))),
                ))
            .toList(),
        onChanged: (value) => firestoreService.updateOrderStatus(o.id, value!),
      ),
    ),
  );
}

}

// ---------------- Users Tab ----------------
class UsersTab extends StatelessWidget {
  final FirestoreService firestoreService;
  UsersTab({required this.firestoreService});

  // Common Widgets for UsersTab only
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6A8EAE))),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Color(0xFF6A8EAE))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Color(0xFF6A8EAE).withOpacity(0.5)),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFD6DC),
                child: Icon(Icons.people, color: Color(0xFF6A8EAE)),
              ),
              title: Text('Customer Management', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('View registered customers'),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getUsers(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No users found');
                
                final users = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final u = users[index];
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 6),
                      elevation: 2,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Color(0xFFE8F4F8),
                          child: Icon(Icons.person, color: Color(0xFF6A8EAE)),
                        ),
                        title: Text(u['name'], style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(u['email']),
                        trailing: Icon(Icons.chevron_right, color: Color(0xFF6A8EAE)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------- Reviews Tab ----------------
class ReviewsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  ReviewsTab({required this.firestoreService});

  // Common Widgets for ReviewsTab only
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6A8EAE))),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Color(0xFF6A8EAE))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Color(0xFF6A8EAE).withOpacity(0.5)),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFD6DC),
                child: Icon(Icons.star, color: Color(0xFF6A8EAE)),
              ),
              title: Text('Reviews Management', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Manage customer reviews and ratings'),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getAllReviews(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No reviews found');
                
                final reviews = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: reviews.length,
                  itemBuilder: (context, index) {
                    final r = reviews[index];
                    return _buildReviewCard(r, context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(QueryDocumentSnapshot r, BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFFFF9C4),
          child: Text('${r['rating']}', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
        ),
        title: Row(
          children: List.generate(5, (index) => Icon(
            index < r['rating'] ? Icons.star : Icons.star_border,
            color: Colors.amber,
            size: 16,
          )),
        ),
        subtitle: Text(r['comment'] ?? 'No comment'),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: Colors.redAccent),
          onPressed: () => _showDeleteReviewDialog(context, r.id),
        ),
      ),
    );
  }

  void _showDeleteReviewDialog(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.reviews, color: Colors.orange),
            SizedBox(width: 8),
            Text('Delete Review'),
          ],
        ),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreService.deleteReview(reviewId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ---------------- Support Tab ----------------
class SupportTab extends StatelessWidget {
  final FirestoreService firestoreService;
  SupportTab({required this.firestoreService});

  // Common Widgets for SupportTab only
  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFF6A8EAE))),
          SizedBox(height: 16),
          Text('Loading...', style: TextStyle(color: Color(0xFF6A8EAE))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Color(0xFF6A8EAE).withOpacity(0.5)),
          SizedBox(height: 16),
          Text(message, style: TextStyle(color: Colors.grey, fontSize: 16)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: Color(0xFFFFD6DC),
                child: Icon(Icons.support_agent, color: Color(0xFF6A8EAE)),
              ),
              title: Text('Support Tickets', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('Manage customer support requests'),
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getAllSupportTickets(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return _buildLoadingIndicator();
                if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No support tickets found');
                
                final tickets = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: tickets.length,
                  itemBuilder: (context, index) {
                    final t = tickets[index];
                    return _buildSupportCard(t);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportCard(QueryDocumentSnapshot t) {
    Color statusColor = Colors.orange;
    if (t['status'] == 'in_progress') statusColor = Colors.blue;
    if (t['status'] == 'closed') statusColor = Colors.green;

    return Card(
      margin: EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(0xFFE8F4F8),
          child: Icon(Icons.help_outline, color: Color(0xFF6A8EAE)),
        ),
        title: Text(t['subject'], style: TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t['description'] ?? 'No description', maxLines: 1, overflow: TextOverflow.ellipsis),
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: statusColor.withOpacity(0.3)),
              ),
              child: Text(
                t['status'].toString().toUpperCase().replaceAll('_', ' '),
                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        trailing: DropdownButton<String>(
          value: t['status'],
          items: ['open', 'in_progress', 'closed']
              .map((s) => DropdownMenuItem(
                    value: s,
                    child: Text(s.replaceAll('_', ' '), style: TextStyle(color: Color(0xFF6A8EAE))),
                  ))
              .toList(),
          onChanged: (value) => firestoreService.updateTicketStatus(t.id, value!),
        ),
      ),
    );
  }
}