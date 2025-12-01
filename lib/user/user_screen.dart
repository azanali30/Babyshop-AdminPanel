import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/services/firestore_service.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({super.key});

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState  extends State<UserScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  final FirestoreService firestoreService = FirestoreService();

  // Sample product data
  final List<Map<String, dynamic>> featuredProducts = [
    {
      'name': 'Nike Air Max',
      'price': 'PKR 1200',
      'image': '👟',
      'category': 'Shoes',
      'rating': 4.8,
    },
    {
      'name': 'Wireless Headphones',
      'price': 'PKR 1200',
      'image': '🎧',
      'category': 'Electronics',
      'rating': 4.5,
    },
    {
      'name': 'Summer Dress',
      'price': 'PKR 1200',
      'image': '👗',
      'category': 'Clothing',
      'rating': 4.7,
    },
    {
      'name': 'Smart Watch',
      'price': 'PKR 1200',
      'image': '⌚',
      'category': 'Electronics',
      'rating': 4.6,
    },
  ];

  // New products for carousel
  final List<Map<String, dynamic>> carouselProducts = [
    {
      'name': 'Baby Romper',
      'price': 'PKR 899',
      'image': '👶',
      'category': 'Clothing',
      'rating': 4.9,
      'isFavorite': false,
    },
    {
      'name': 'Kids Sneakers',
      'price': 'PKR 1499',
      'image': '👟',
      'category': 'Shoes',
      'rating': 4.7,
      'isFavorite': false,
    },
    {
      'name': 'Toy Set',
      'price': 'PKR 699',
      'image': '🧸',
      'category': 'Toys',
      'rating': 4.8,
      'isFavorite': false,
    },
    {
      'name': 'Baby Bottle',
      'price': 'PKR 499',
      'image': '🍼',
      'category': 'Essentials',
      'rating': 4.6,
      'isFavorite': false,
    },
    {
      'name': 'Kids Backpack',
      'price': 'PKR 1299',
      'image': '🎒',
      'category': 'Accessories',
      'rating': 4.5,
      'isFavorite': false,
    },
  ];

  final List<Map<String, dynamic>> categories = [];

  // Slider banners data
  final List<Map<String, dynamic>> banners = [
    {
      'title': 'Summer Collection',
      'subtitle': 'Up to 50% OFF',
      'image': '🌞',
      'color': Colors.orange,
      'gradient': [Colors.orangeAccent, Colors.deepOrange],
    },
    {
      'title': 'New Arrivals',
      'subtitle': 'Fresh styles for kids',
      'image': '🆕',
      'color': Color(0xFFF7C9D1),
      'gradient': [Color(0xFFFFDCE4), Color(0xFFF7C9D1)],
    },
    {
      'title': 'Baby Essentials',
      'subtitle': 'Everything you need',
      'image': '👶',
      'color': Colors.pink,
      'gradient': [Colors.pinkAccent, Colors.purple],
    },
  ];

  @override
  void initState() {
    super.initState();
    // Auto-scroll the banner
    _startAutoScroll();
  }

  void _startAutoScroll() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_pageController.hasClients) {
        int nextPage = _currentPage + 1;
        if (nextPage >= banners.length) {
          nextPage = 0;
        }
        _pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        _startAutoScroll();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              _buildHeader(),
              
              // Search Bar
              _buildSearchBar(),
              _searchQuery.isNotEmpty 
                  ? _buildSearchResults() 
                  : const SizedBox.shrink(),
              
              // Banner Slider
              if (_searchQuery.isEmpty) _buildBannerSlider(),
              
              // Categories Section
              if (_searchQuery.isEmpty) _buildCategories(),
              
              // Featured Products Section
              if (_searchQuery.isEmpty) _buildFeaturedProducts(),
              
              // Static Summer Sale Banner
              if (_searchQuery.isEmpty) _buildStaticSummerBanner(),
              
              // Product Carousel
              if (_searchQuery.isEmpty) _buildProductCarousel(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Welcome! 👋',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Babyshop Hub',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: FutureBuilder<User?>(
              future: Future.value(FirebaseAuth.instance.currentUser),
              builder: (context, userSnap) {
                if (userSnap.data == null) {
                  return IconButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                    },
                    icon: const Icon(Icons.shopping_cart_outlined),
                    color: Theme.of(context).colorScheme.tertiary,
                  );
                }
                final safeEmail = userSnap.data!.email!.replaceAll('.', ',');
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(safeEmail)
                      .collection('cart')
                      .snapshots(),
                  builder: (context, snap) {
                    final count = snap.hasData ? snap.data!.docs.length : 0;
                    return IconButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                      },
                      icon: Badge(
                        backgroundColor: Colors.red,
                        label: Text('$count', style: const TextStyle(color: Colors.white, fontSize: 10)),
                        child: const Icon(Icons.shopping_cart_outlined),
                      ),
                      color: Theme.of(context).colorScheme.tertiary,
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (v) {
            setState(() {
              _searchQuery = v.trim();
            });
          },
          decoration: InputDecoration(
            hintText: 'Search products...',
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                'No products found',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          final q = _searchQuery.toLowerCase();
          final docs = snapshot.data!.docs.where((d) {
            final data = d.data() as Map<String, dynamic>;
            final name = (data['name'] ?? '').toString().toLowerCase();
            final category = (data['category'] ?? '').toString().toLowerCase();
            return name.contains(q) || category.contains(q);
          }).toList();

          if (docs.isEmpty) {
            return Center(
              child: Text(
                'No matches for "$_searchQuery"',
                style: TextStyle(color: Colors.grey[600]),
              ),
            );
          }

          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75,
            ),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = (data['name'] ?? '').toString();
              final price = (data['price'] ?? 0).toString();
              final image = (data['image'] ?? '').toString();
              final category = (data['category'] ?? '').toString();

                  final idCandidate = (data['id'] ?? '').toString();
                  final productId = idCandidate.isNotEmpty ? idCandidate : (docs[index].id);
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId)));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                        child: image.isNotEmpty
                            ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover)
                            : Icon(Icons.image, color: Colors.grey[400], size: 40),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'PKR $price',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF773D44),
                                ),
                              ),
                              const Icon(Icons.chevron_right, color: Colors.grey)
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
            },
          );
        },
      ),
    );
  }
 
  Widget _buildBannerSlider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Column(
        children: [
          Container(
            height: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: banners.length,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemBuilder: (context, index) {
                final banner = banners[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: banner['gradient'],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Stack(
                    children: [
                      // Background circles
                      Positioned(
                        right: -30,
                        top: -30,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      Positioned(
                        right: 40,
                        bottom: -40,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    banner['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    banner['subtitle'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Shop Now',
                                      style: TextStyle(
                                        color: banner['color'],
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  banner['image'],
                                  style: const TextStyle(fontSize: 40),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Dots indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(banners.length, (index) {
              return Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index 
                      ? Theme.of(context).colorScheme.primary 
                      : Colors.grey.withOpacity(0.5),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Categories',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: StreamBuilder<QuerySnapshot>(
              stream: firestoreService.getCategories(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final docs = snapshot.data!.docs.take(4).toList();
                if (docs.isEmpty) {
                  return Center(
                    child: Text('No categories', style: TextStyle(color: Colors.grey[600])),
                  );
                }
                return ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    final title = (data['title'] ?? data['name'] ?? '').toString();
                    final image = (data['image'] ?? '').toString();
                    final Color bg = Theme.of(context).colorScheme.primary.withOpacity(0.1);
                    return Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      child: Column(
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: bg,
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Center(
                              child: image.isNotEmpty
                                  ? Image.network(image, width: 40, height: 40, fit: BoxFit.cover)
                                  : Icon(Icons.category, color: Theme.of(context).colorScheme.secondary),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[700],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
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

  Widget _buildFeaturedProducts() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Featured Products',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'See all',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection('products')
                .orderBy('createdAt', descending: true)
                .limit(6)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              final docs = snapshot.data!.docs;
              if (docs.isEmpty) {
                return Center(child: Text('No products yet', style: TextStyle(color: Colors.grey[600])));
              }
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  final name = (data['name'] ?? '').toString();
                  final price = (data['price'] ?? 0).toString();
                  final image = (data['image'] ?? '').toString();
                  final category = (data['category'] ?? '').toString();
                  final ratingSum = (data['ratingSum'] ?? 0).toDouble();
                  final reviews = (data['reviews'] ?? 0);
                  final rating = reviews > 0 ? (ratingSum / reviews) : 0.0;
                  final idCandidate = (data['id'] ?? '').toString();
                  final productId = idCandidate.isNotEmpty ? idCandidate : docs[index].id;
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId)));
                    },
                    child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Image
                    Container(
                      height: 120,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Center(
                        child: image.isNotEmpty
                            ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover)
                            : Icon(Icons.image, color: Colors.grey[400], size: 40),
                      ),
                    ),
                    
                    // Product Details
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                          category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                          name,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                              'PKR $price',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF773D44),
                              ),
                              ),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber[400],
                                    size: 16,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    rating.toStringAsFixed(1),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStaticSummerBanner() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF4CAF50), Color(0xFF8BC34A)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Background decorative elements
            Positioned(
              left: -20,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: -30,
              bottom: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            
            // Content
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'SUMMER SALE!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Get 50% OFF on all summer\ncollections for kids',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          child: const Text(
                            'Shop Now',
                            style: TextStyle(
                              color: Color(0xFF4CAF50),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '☀️',
                        style: TextStyle(fontSize: 40),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCarousel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Popular Products',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 220,
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .limit(200)
                  .snapshots(),
              builder: (context, ordersSnap) {
                final counts = <String, int>{};
                if (ordersSnap.hasData) {
                  for (final o in ordersSnap.data!.docs) {
                    final data = o.data() as Map<String, dynamic>? ?? const {};
                    final itemsRaw = data['items'];
                    if (itemsRaw is List) {
                      for (final it in itemsRaw) {
                        final id = (it['productId'] ?? '').toString();
                        if (id.isEmpty) continue;
                        counts[id] = (counts[id] ?? 0) + 1;
                      }
                    } else if (itemsRaw is Map<String, dynamic>) {
                      final id = (itemsRaw['productId'] ?? '').toString();
                      if (id.isNotEmpty) counts[id] = (counts[id] ?? 0) + 1;
                    }
                  }
                }
                final topIds = counts.entries.toList()
                  ..sort((a, b) => b.value.compareTo(a.value));
                final ids = topIds.take(10).map((e) => e.key).toList();
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance.collection('products').snapshots(),
                  builder: (context, productsSnap) {
                    if (!productsSnap.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = productsSnap.data!.docs;
                    final list = all.where((d) => ids.contains(d.id) || ids.contains((d.data() as Map<String, dynamic>)['id']?.toString() ?? '')).toList();
                    if (list.isEmpty) {
                      return Center(child: Text('No popular products yet', style: TextStyle(color: Colors.grey[600])));
                    }
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: list.length,
                      itemBuilder: (context, index) {
                        final data = list[index].data() as Map<String, dynamic>;
                        final name = (data['name'] ?? '').toString();
                        final price = (data['price'] ?? 0).toString();
                        final image = (data['image'] ?? '').toString();
                        final category = (data['category'] ?? '').toString();
                        final idCandidate = (data['id'] ?? '').toString();
                        final productId = idCandidate.isNotEmpty ? idCandidate : list[index].id;
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(productId: productId)));
                          },
                          child: Container(
                          width: 160,
                          margin: EdgeInsets.only(
                            right: index == list.length - 1 ? 0 : 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                      // Product Image with Favorite Icon
                      Stack(
                        children: [
                          Container(
                            height: 120,
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: Center(
                              child: image.isNotEmpty
                                  ? Image.network(image, width: 80, height: 80, fit: BoxFit.cover)
                                  : Icon(Icons.image, color: Colors.grey[400], size: 40),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.9),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: Icon(
                                  Icons.favorite_border,
                                  color: Colors.grey,
                                  size: 20,
                                ),
                                onPressed: () {
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      
                      // Product Details
                      Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              category,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'PKR $price',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF773D44),
                                  ),
                                ),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: Colors.amber[400],
                                      size: 16,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      '4.8',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                          ),
                        );
                      },
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
