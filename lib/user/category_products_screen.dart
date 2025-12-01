import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart';
import '../auth/user_login_screen.dart';
import 'cart_screen.dart';
import 'wishlist_screen.dart';
import 'product_detail_screen.dart';

class CategoryProductsScreen extends StatelessWidget {
  final String categoryTitle;
  const CategoryProductsScreen({super.key, required this.categoryTitle});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(categoryTitle,
            style: Theme.of(context).textTheme.headlineSmall),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: Theme.of(context).colorScheme.tertiary),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
          stream: firestore.getProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text(
                  'No products found in this category',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              );
            }
            final normTitle = categoryTitle.toLowerCase().trim();
            final allDocs = snapshot.data!.docs;
            final docs = allDocs.where((d) {
              final data = d.data() as Map<String, dynamic>;
              final cat =
                  (data['category'] ?? '').toString().toLowerCase().trim();
              return cat == normTitle || cat.contains(normTitle);
            }).toList();
            if (docs.isEmpty) {
              return Center(
                child: Text('No products found in $categoryTitle',
                    style: TextStyle(color: Colors.grey[600])),
              );
            }
            return GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.72,
              ),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                final doc = docs[index];
                final data = doc.data() as Map<String, dynamic>;
                final idCandidate = (data['id'] ?? '').toString();
                final id = idCandidate.isNotEmpty ? idCandidate : doc.id;
                final name = (data['name'] ?? '').toString();
                final price = (data['price'] ?? 0);
                final image = (data['image'] ?? '').toString();
                final ratingSum = (data['ratingSum'] ?? 0).toDouble();
                final reviews = (data['reviews'] ?? 0);
                final rating = reviews > 0 ? (ratingSum / reviews) : 0.0;
                final oldPriceCandidate = (data['oldPrice'] ??
                        data['comparePrice'] ??
                        data['mrp'] ??
                        '')
                    .toString();
                final oldPrice = num.tryParse(oldPriceCandidate);
                num? discountPercent;
                if (oldPrice != null && oldPrice > 0 && oldPrice > price) {
                  final p = (((oldPrice - price) / oldPrice) * 100).round();
                  discountPercent = p;
                } else {
                  final dp = (data['discountPercent'] ?? 0);
                  if (dp is num && dp > 0) discountPercent = dp;
                }

                return _ProductCard(
                  productId: id,
                  name: name,
                  price: price,
                  imageUrl: image,
                  rating: rating,
                  reviewCount: reviews,
                  oldPrice: oldPrice,
                  discountPercent: discountPercent,
                  onAddToCart: () async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserLoginScreen()));
                      return;
                    }
                    await firestore.addToCart(
                        productId: id, name: name, price: price, image: image);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                  onToggleWishlist: (add) async {
                    final user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const UserLoginScreen()));
                      return;
                    }
                    await firestore.toggleWishlist(
                        productId: id,
                        name: name,
                        price: price,
                        image: image,
                        add: add);
                    if (add) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const WishlistScreen()));
                    }
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ProductCard extends StatefulWidget {
  final String productId;
  final String name;
  final num price;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final num? oldPrice;
  final num? discountPercent;
  final VoidCallback onAddToCart;
  final void Function(bool add) onToggleWishlist;

  const _ProductCard({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    this.oldPrice,
    this.discountPercent,
    required this.onAddToCart,
    required this.onToggleWishlist,
  });

  @override
  State<_ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<_ProductCard> {
  bool wishlisted = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) =>
                      ProductDetailScreen(productId: widget.productId)));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
                color: Theme.of(context).colorScheme.secondary, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with wishlist overlay
              Stack(
                children: [
                  Container(
                    height: 120,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Center(
                      child: widget.imageUrl.isNotEmpty
                          ? Image.network(widget.imageUrl,
                              width: 90, height: 90, fit: BoxFit.cover)
                          : Icon(Icons.image,
                              color: Colors.grey[400], size: 40),
                    ),
                  ),
                  if ((widget.discountPercent ?? 0) > 0)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          shape: BoxShape.circle,
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 6)
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          '-${(widget.discountPercent!).round()}%',
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: InkWell(
                      onTap: () {
                        setState(() => wishlisted = !wishlisted);
                        widget.onToggleWishlist(wishlisted);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          wishlisted ? Icons.favorite : Icons.favorite_border,
                          color: wishlisted
                              ? Theme.of(context).colorScheme.secondary
                              : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        _buildStars(context, widget.rating),
                        const SizedBox(width: 6),
                        Text('(${widget.reviewCount})',
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 12)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (widget.oldPrice != null &&
                            widget.oldPrice! > widget.price)
                          Text(
                            'PKR ${widget.oldPrice}',
                            style: TextStyle(
                                color: Colors.grey[500],
                                decoration: TextDecoration.lineThrough),
                          ),
                        const SizedBox(width: 6),
                        Text(
                          'PKR ${widget.price}',
                          style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF773D44)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          height: 34,
                          child: OutlinedButton(
                            onPressed: () {
                              _showQuickShopSheet(context);
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color:
                                      Theme.of(context).colorScheme.secondary),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                            ),
                            child: const Text('Quick Shop'),
                          ),
                        ),
                        SizedBox(
                          height: 34,
                          width: 44,
                          child: ElevatedButton(
                            onPressed: widget.onAddToCart,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(context).colorScheme.secondary,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              padding: EdgeInsets.zero,
                            ),
                            child: const Icon(Icons.shopping_bag_outlined,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ));
  }

  void _showQuickShopSheet(BuildContext context) {
    final service = FirestoreService();
    int qty = 1;
    String? selectedSize;
    List<String> sizes = [];
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Padding(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.name,
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        if (widget.oldPrice != null &&
                            widget.oldPrice! > widget.price)
                          Text('PKR ${widget.oldPrice}',
                              style: TextStyle(
                                  color: Colors.grey[500],
                                  decoration: TextDecoration.lineThrough)),
                        const SizedBox(width: 8),
                        Text('PKR ${widget.price}',
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF773D44))),
                        if ((widget.discountPercent ?? 0) > 0) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(12)),
                            child: Text(
                                'SAVE ${((widget.discountPercent!) / 100 * (widget.oldPrice ?? widget.price)).round()}'),
                          )
                        ]
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('Select Size',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.tertiary,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('products')
                          .doc(widget.productId)
                          .get(),
                      builder: (context, snap) {
                        sizes = [];
                        if (snap.hasData && snap.data!.exists) {
                          final data =
                              snap.data!.data() as Map<String, dynamic>;
                          final raw = data['sizes'];
                          if (raw is List) {
                            sizes = raw.map((e) => e.toString()).toList();
                          }
                          if (sizes.isEmpty) {
                            final cat = (data['category'] ?? '')
                                .toString()
                                .toLowerCase();
                            if (cat.contains('cloth') ||
                                cat.contains('apparel') ||
                                cat.contains('wear')) {
                              sizes = const [
                                '1 Year',
                                '2 Years',
                                '3 Years',
                                '4 Years',
                                '5-6 Years',
                                '6-7 Years'
                              ];
                            } else {
                              sizes = const [
                                'NB',
                                '0-3M',
                                '3-6M',
                                '6-9M',
                                '9-12M'
                              ];
                            }
                          }
                        } else {
                          sizes = const ['NB', '0-3M', '3-6M', '6-9M', '9-12M'];
                        }
                        selectedSize ??= sizes.first;
                        return Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: sizes.map((s) {
                            final isSelected = selectedSize == s;
                            return ChoiceChip(
                              label: Text(s),
                              selected: isSelected,
                              onSelected: (_) =>
                                  setState(() => selectedSize = s),
                              selectedColor:
                                  Theme.of(context).colorScheme.secondary,
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey[300]!),
                              borderRadius: BorderRadius.circular(30)),
                          child: Row(
                            children: [
                              IconButton(
                                  onPressed: () => setState(
                                      () => qty = qty > 1 ? qty - 1 : 1),
                                  icon: const Icon(Icons.remove)),
                              Text('$qty'),
                              IconButton(
                                  onPressed: () =>
                                      setState(() => qty = qty + 1),
                                  icon: const Icon(Icons.add)),
                            ],
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          onPressed: () async {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const UserLoginScreen()));
                              return;
                            }
                            await service.toggleWishlist(
                                productId: widget.productId,
                                name: widget.name,
                                price: widget.price,
                                image: widget.imageUrl,
                                add: true);
                            ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Added to wishlist')));
                          },
                          icon: const Icon(Icons.favorite_border),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (_) => const UserLoginScreen()));
                            return;
                          }
                          await service.addToCart(
                              productId: widget.productId,
                              name: widget.name,
                              price: widget.price,
                              image: widget.imageUrl,
                              size: selectedSize,
                              quantity: qty);
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Added to cart')));
                        },
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30))),
                        child: const Text('Add to Cart'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStars(BuildContext context, double rating) {
    int full = rating.floor();
    bool half = (rating - full) >= 0.5;
    return Row(
      children: List.generate(5, (i) {
        if (i < full)
          return Icon(Icons.star,
              size: 14, color: Theme.of(context).colorScheme.secondary);
        if (i == full && half)
          return Icon(Icons.star_half,
              size: 14, color: Theme.of(context).colorScheme.secondary);
        return const Icon(Icons.star_border, size: 14, color: Colors.grey);
      }),
    );
  }
}

// removed inline review sheet; review now handled in ProductDetailScreen
