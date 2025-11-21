class ProductModel {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final int stock;

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.stock,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      image: map['image'],
      category: map['category'],
      stock: map['stock'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'image': image,
      'category': category,
      'stock': stock,
    };
  }
}
