import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Product Details'),
        backgroundColor: const Color(0xFFF7C9D1),
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('products')
            .doc(productId)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString();
          final price = (data['price'] ?? 0).toString();
          final image = (data['image'] ?? '').toString();
          final List<String> images = ((data['images'] ?? []) as List)
              .map((e) => e.toString())
              .where((e) => e.isNotEmpty)
              .toList();
          if (images.isEmpty && image.isNotEmpty) {
            images.add(image);
          }
          final category = (data['category'] ?? '').toString();
          final description = (data['description'] ?? '').toString();
          final ratingSum = (data['ratingSum'] ?? 0).toDouble();
          final reviews = (data['reviews'] ?? 0);
          final rating = reviews > 0 ? (ratingSum / reviews) : 0.0;

          final service = FirestoreService();
          final numPrice = num.tryParse(price) ?? 0;

          final oldPriceCandidate =
              (data['oldPrice'] ?? data['comparePrice'] ?? data['mrp'] ?? '')
                  .toString();
          final oldPrice = num.tryParse(oldPriceCandidate);
          num? discountPercent;
          if (oldPrice != null && oldPrice > 0 && oldPrice > numPrice) {
            discountPercent =
                (((oldPrice - numPrice) / oldPrice) * 100).round();
          } else {
            final dp = (data['discountPercent'] ?? 0);
            if (dp is num && dp > 0) discountPercent = dp;
          }

          List<String> sizes = [];
          final rawSizes = data['sizes'];
          if (rawSizes is List) {
            sizes = rawSizes
                .map((e) => e.toString())
                .where((e) => e.isNotEmpty)
                .toList();
          }
          if (sizes.isEmpty) {
            final catLower = category.toLowerCase();
            if (catLower.contains('cloth') ||
                catLower.contains('apparel') ||
                catLower.contains('wear')) {
              sizes = [
                '1 Year',
                '2 Years',
                '3 Years',
                '4 Years',
                '5-6 Years',
                '6-7 Years'
              ];
            } else {
              sizes = ['NB', '0-3M', '3-6M', '6-9M', '9-12M'];
            }
          }

          String selectedSize = sizes.first;
          int qty = 1;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ImageGallery(images: images),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: StatefulBuilder(
                    builder: (context, setState) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(category,
                            style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.star,
                                color: Colors.amber[400], size: 18),
                            const SizedBox(width: 4),
                            Text(rating.toStringAsFixed(1)),
                            const SizedBox(width: 8),
                            Text('($reviews reviews)',
                                style: TextStyle(color: Colors.grey[600]))
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () {
                            _showReviewSheet(context, productId, name);
                          },
                          icon: Icon(Icons.rate_review,
                              color: Theme.of(context).colorScheme.tertiary),
                          label: Text('Write review',
                              style: TextStyle(
                                  color:
                                      Theme.of(context).colorScheme.tertiary)),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (oldPrice != null && oldPrice > numPrice)
                              Text('PKR $oldPrice',
                                  style: TextStyle(
                                      color: Colors.grey[500],
                                      decoration: TextDecoration.lineThrough)),
                            const SizedBox(width: 8),
                            Text('PKR $price',
                                style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF773D44))),
                            if ((discountPercent ?? 0) > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                    borderRadius: BorderRadius.circular(12)),
                                child: Text(
                                    'SAVE Rs.${((discountPercent! / 100) * (oldPrice ?? numPrice)).round()}',
                                    style:
                                        const TextStyle(color: Colors.white)),
                              ),
                            ]
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Select Size',
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.tertiary,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        Wrap(
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
                            OutlinedButton.icon(
                              onPressed: () async {
                                await service.toggleWishlist(
                                    productId: productId,
                                    name: name,
                                    price: numPrice,
                                    image: image.isNotEmpty
                                        ? image
                                        : (images.isNotEmpty
                                            ? images.first
                                            : ''),
                                    add: true);
                                ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Added to wishlist')));
                              },
                              icon: const Icon(Icons.favorite_border),
                              label: const Text('Wishlist'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (description.isNotEmpty) ...[
                          const Text('Description',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 6),
                          Text(
                            description,
                            style:
                                TextStyle(color: Colors.grey[800], height: 1.4),
                          ),
                        ],
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  await service.addToCart(
                                      productId: productId,
                                      name: name,
                                      price: numPrice,
                                      image: image.isNotEmpty
                                          ? image
                                          : (images.isNotEmpty
                                              ? images.first
                                              : ''),
                                      size: selectedSize,
                                      quantity: qty);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Added to cart')));
                                },
                                icon: const Icon(Icons.add_shopping_cart),
                                label: const Text('Add to Cart'),
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFF7C9D1),
                                    foregroundColor: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(child: SizedBox.shrink()),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

void _showReviewSheet(BuildContext context, String productId, String name) {
  final service = FirestoreService();
  double rating = 5;
  final controller = TextEditingController();
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    isScrollControlled: true,
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: StatefulBuilder(
            builder: (context, setState) => SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Review $name',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: 12),
                    Row(
                      children: List.generate(5, (i) {
                        return IconButton(
                          icon: Icon(
                              i < rating ? Icons.star : Icons.star_border,
                              color: Theme.of(context).colorScheme.secondary),
                          onPressed: () => setState(() => rating = i + 1),
                          padding: EdgeInsets.zero,
                        );
                      }),
                    ),
                    TextField(
                      controller: controller,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        hintText: 'Write your review...',
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12))),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          await service.addReview(
                              productId: productId,
                              rating: rating,
                              comment: controller.text.trim());
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Review submitted')));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Submit',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

class _ImageGallery extends StatefulWidget {
  final List<String> images;
  const _ImageGallery({required this.images});

  @override
  State<_ImageGallery> createState() => _ImageGalleryState();
}

class _ImageGalleryState extends State<_ImageGallery> {
  int index = 0;
  final PageController _controller = PageController();

  @override
  Widget build(BuildContext context) {
    final imgs = widget.images;
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: PageView.builder(
            controller: _controller,
            itemCount: imgs.isNotEmpty ? imgs.length : 1,
            onPageChanged: (i) => setState(() => index = i),
            itemBuilder: (_, i) {
              final url = imgs.isNotEmpty ? imgs[i] : '';
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(
                  child: url.isNotEmpty
                      ? Image.network(url, fit: BoxFit.cover)
                      : Icon(Icons.image, size: 64, color: Colors.grey[400]),
                ),
              );
            },
          ),
        ),
        if (imgs.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
                imgs.length,
                (i) => Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 6),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == index
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.withOpacity(0.5),
                      ),
                    )),
          ),
      ],
    );
  }
}
