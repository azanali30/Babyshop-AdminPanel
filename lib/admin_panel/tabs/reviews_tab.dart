import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';

class ReviewsTab extends StatelessWidget {
  final FirestoreService firestoreService;
  ReviewsTab({required this.firestoreService});

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(valueColor: AlwaysStoppedAnimation(Color(0xFFF7C9D1))),
          SizedBox(height: 16),
          Text('Loading Reviews...', style: TextStyle(color: Color(0xFFF7C9D1))),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, size: 64, color: Colors.grey[400]),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reviews Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Manage customer reviews and ratings',
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        
        // Reviews List
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: firestoreService.getAllReviews(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return _buildLoadingIndicator();
              if (snapshot.data!.docs.isEmpty) return _buildEmptyState('No reviews found');
              
              final reviews = snapshot.data!.docs;
              return ListView.builder(
                padding: EdgeInsets.all(16),
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
    );
  }

  Widget _buildReviewCard(QueryDocumentSnapshot r, BuildContext context) {
    final productId = r['productId']?.toString() ?? '';
    final user = r['user']?.toString() ?? '';
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: productId.isNotEmpty
                  ? FirebaseFirestore.instance.collection('products').doc(productId).get()
                  : Future.value(null),
              builder: (context, snap) {
                String image = '';
                if (snap.hasData && snap.data?.data() != null) {
                  final data = snap.data!.data() as Map<String, dynamic>;
                  image = (data['image'] ?? '').toString();
                }
                return Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
                  child: image.isNotEmpty
                      ? Image.network(image, fit: BoxFit.cover)
                      : Icon(Icons.image, color: Colors.grey[400]),
                );
              },
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: List.generate(5, (index) => Icon(
                          index < (r['rating'] ?? 0).round() ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 16,
                        )),
                  ),
                  SizedBox(height: 6),
                  Text(r['comment']?.toString() ?? 'No comment'),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        label: Text('Product: ${productId.isNotEmpty ? productId : 'N/A'}'),
                        backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
                      ),
                      Chip(
                        label: Text('User: ${user.isNotEmpty ? user : 'N/A'}'),
                        backgroundColor: Colors.grey[100],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.secondary),
              onPressed: () => _showDeleteReviewDialog(context, r.id),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteReviewDialog(BuildContext context, String reviewId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Review'),
        content: Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              firestoreService.deleteReview(reviewId);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.secondary),
            child: Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
