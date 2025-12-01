import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/firestore_service.dart';
import '../add_edit_product_page.dart';

class DashboardTab extends StatefulWidget {
  final FirestoreService firestoreService;

  DashboardTab({required this.firestoreService});

  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  // Baby Shop Palette
  final Color _babyBlue = Color(0xFFF7C9D1);
  final Color _softPink = Color(0xFFF7C9D1);

  int totalProducts = 0;
  int totalOrders = 0;
  int totalUsers = 0;
  int pendingOrders = 0;
  List<Map<String, dynamic>> recentActivity = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    setState(() => isLoading = true);
    try {
      // Fetch all data in parallel
      final results = await Future.wait([
        widget.firestoreService.getTotalProducts(),
        widget.firestoreService.getTotalOrders(),
        widget.firestoreService.getTotalUsers(),
        widget.firestoreService.getPendingOrders(),
        widget.firestoreService.getRecentActivity(),
      ]);

      setState(() {
        totalProducts = results[0] as int;
        totalOrders = results[1] as int;
        totalUsers = results[2] as int;
        pendingOrders = results[3] as int;
        recentActivity = results[4] as List<Map<String, dynamic>>;
      });
    } catch (e) {
      print('Error fetching dashboard data: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Dashboard Overview',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.tertiary),
          ),
          SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildStatCard('Total Products', totalProducts.toString(), Icons.shopping_basket, Theme.of(context).colorScheme.primary),
              _buildStatCard('Total Orders', totalOrders.toString(), Icons.receipt_long, Colors.green),
              _buildStatCard('Total Users', totalUsers.toString(), Icons.people, Theme.of(context).colorScheme.secondary),
              _buildStatCard('Pending Orders', pendingOrders.toString(), Icons.pending_actions, Colors.orange),
            ],
          ),
          SizedBox(height: 24),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: color, size: 24),
              ),
              Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
            ]),
            SizedBox(height: 8),
            Text(title, style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Recent Activity', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.tertiary)),
            SizedBox(height: 16),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('orders')
                  .orderBy('createdAt', descending: true)
                  .limit(10)
                  .snapshots(),
              builder: (context, ordersSnap) {
                final orders = ordersSnap.hasData ? ordersSnap.data!.docs : const [];
                return StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activity')
                      .orderBy('timestamp', descending: true)
                      .limit(10)
                      .snapshots(),
                  builder: (context, actSnap) {
                    final acts = actSnap.hasData ? actSnap.data!.docs : const [];
                    final List<_DashAct> items = [];
                    for (final d in orders) {
                      final data = d.data() as Map<String, dynamic>? ?? const {};
                      final ts = data['createdAt'];
                      final total = (data['total'] ?? 0).toString();
                      final status = (data['status'] ?? 'pending').toString();
                      final idShort = d.id.substring(0, 8);
                      items.add(_DashAct('Order #$idShort • $status • Rs $total', ts));
                    }
                    for (final d in acts) {
                      final data = d.data() as Map<String, dynamic>? ?? const {};
                      final ts = data['timestamp'];
                      final title = (data['title'] ?? data['message'] ?? 'Activity').toString();
                      items.add(_DashAct(title, ts));
                    }
                    items.sort((a, b) => _dashTs(b.ts).compareTo(_dashTs(a.ts)));
                    if (items.isEmpty) {
                      return Text('No recent activity', style: TextStyle(color: Colors.grey[600]));
                    }
                    return Column(
                      children: items.map((it) => _dashActivityRow(it.title, it.ts)).toList(),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityItem(String title, String time) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: _babyBlue, shape: BoxShape.circle)),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: TextStyle(color: Colors.grey, fontSize: 12)),
    );
  }
}

class _DashAct {
  final String title;
  final dynamic ts;
  _DashAct(this.title, this.ts);
}

DateTime _dashTs(dynamic t) {
  if (t is Timestamp) return t.toDate();
  if (t is DateTime) return t;
  return DateTime.fromMillisecondsSinceEpoch(0);
}

Widget _dashActivityRow(String title, dynamic ts) {
  final dt = _dashTs(ts);
  final diff = DateTime.now().difference(dt);
  String ago;
  if (diff.inMinutes < 1) {
    ago = 'just now';
  } else if (diff.inHours < 1) {
    ago = '${diff.inMinutes} min ago';
  } else if (diff.inDays < 1) {
    ago = '${diff.inHours} hr ago';
  } else {
    ago = '${diff.inDays} days ago';
  }
  return ListTile(
    contentPadding: EdgeInsets.zero,
    leading: Container(width: 8, height: 8, decoration: BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
    title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
    subtitle: Text(ago, style: const TextStyle(color: Colors.grey, fontSize: 12)),
  );
}
