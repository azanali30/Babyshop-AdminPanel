import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class AddEditProductPage extends StatefulWidget {
  final FirestoreService firestoreService;
  final String? productId;
  final Map<String, dynamic>? existingData;

  AddEditProductPage(
      {required this.firestoreService, this.productId, this.existingData});

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
  late TextEditingController image2Controller;
  late TextEditingController image3Controller;
  late TextEditingController image4Controller;
  late TextEditingController descriptionController;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();
    nameController =
        TextEditingController(text: widget.existingData?['name'] ?? '');
    priceController = TextEditingController(
        text: widget.existingData?['price']?.toString() ?? '');
    stockController = TextEditingController(
        text: widget.existingData?['stock']?.toString() ?? '');
    categoryController =
        TextEditingController(text: widget.existingData?['category'] ?? '');
    imageController =
        TextEditingController(text: widget.existingData?['image'] ?? '');
    final List<dynamic> imgs =
        (widget.existingData?['images'] ?? const []) as List<dynamic>;
    image2Controller = TextEditingController(
        text:
            imgs.isNotEmpty ? (imgs.length > 1 ? imgs[1].toString() : '') : '');
    image3Controller = TextEditingController(
        text:
            imgs.isNotEmpty ? (imgs.length > 2 ? imgs[2].toString() : '') : '');
    image4Controller = TextEditingController(
        text:
            imgs.isNotEmpty ? (imgs.length > 3 ? imgs[3].toString() : '') : '');
    descriptionController =
        TextEditingController(text: widget.existingData?['description'] ?? '');
    selectedCategory =
        categoryController.text.isNotEmpty ? categoryController.text : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          widget.productId == null ? 'Add New Product' : 'Edit Product',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color(0xFFF7C9D1),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Product Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),

              // Form Fields
              _buildTextField(nameController, 'Product Name'),
              _buildTextField(priceController, 'Price', TextInputType.number),
              _buildTextField(
                  stockController, 'Stock Quantity', TextInputType.number),
              _buildCategoryDropdown(),
              _buildTextField(imageController, 'Image URL'),
              _buildTextField(image2Controller, 'Image URL 2 (optional)'),
              _buildTextField(image3Controller, 'Image URL 3 (optional)'),
              _buildTextField(image4Controller, 'Image URL 4 (optional)'),
              _buildTextField(descriptionController, 'Description',
                  TextInputType.multiline, 3),

              SizedBox(height: 30),

              // Save Button
              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _saveProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFF7C9D1),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    widget.productId == null ? 'Add Product' : 'Update Product',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      [TextInputType? keyboardType, int maxLines = 1]) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.w500)),
          SizedBox(height: 8),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            maxLines: maxLines,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
            validator: (v) => v!.isEmpty ? 'This field is required' : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryDropdown() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Category', style: TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          StreamBuilder<QuerySnapshot>(
            stream: widget.firestoreService.getCategories(),
            builder: (context, snapshot) {
              final items = <String>[];
              if (snapshot.hasData) {
                for (final d in snapshot.data!.docs) {
                  final m = d.data() as Map<String, dynamic>;
                  final t = (m['title'] ?? m['name'] ?? '').toString();
                  if (t.isNotEmpty) items.add(t);
                }
              }
              final current = selectedCategory;
              return DropdownButtonFormField<String>(
                value: items.contains(current) ? current : null,
                items: items
                    .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedCategory = v;
                    categoryController.text = v ?? '';
                  });
                },
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'This field is required' : null,
                decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 12, vertical: 12)),
              );
            },
          ),
        ],
      ),
    );
  }

  void _saveProduct() {
    if (_formKey.currentState!.validate()) {
      final data = {
        'name': nameController.text,
        'price': double.parse(priceController.text),
        'stock': int.parse(stockController.text),
        'category': selectedCategory ?? categoryController.text,
        'image': imageController.text,
        'images': [
          imageController.text,
          if (image2Controller.text.trim().isNotEmpty)
            image2Controller.text.trim(),
          if (image3Controller.text.trim().isNotEmpty)
            image3Controller.text.trim(),
          if (image4Controller.text.trim().isNotEmpty)
            image4Controller.text.trim(),
        ],
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
        widget.firestoreService.updateProduct(id, {'images': data['images']});
      } else {
        widget.firestoreService.updateProduct(widget.productId!, data);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.productId == null
              ? 'Product added successfully!'
              : 'Product updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
