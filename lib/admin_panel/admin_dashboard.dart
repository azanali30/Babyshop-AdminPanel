import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';


class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int totalUsers = 0;
  int totalOrders = 0;
  int totalProducts = 0;

  List<int> weeklySales = List.filled(7, 0);

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    // USERS COUNT
    var usersSnap = await FirebaseFirestore.instance.collection('users').get();
    totalUsers = usersSnap.size;

    // ORDERS COUNT
    var orderSnap = await FirebaseFirestore.instance.collection('orders').get();
    totalOrders = orderSnap.size;

    // PRODUCTS COUNT
    var productSnap =
        await FirebaseFirestore.instance.collection('products').get();
    totalProducts = productSnap.size;

    // WEEKLY SALES
    weeklySales = List.filled(7, 0);

    for (var doc in orderSnap.docs) {
      DateTime date = (doc['date'] as Timestamp).toDate();
      int weekday = date.weekday - 1;
      int amount = (doc['total'] ?? 0).toInt();
      weeklySales[weekday] = weeklySales[weekday].toInt() + amount;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("Admin Dashboard", style: TextStyle(color: Colors.white)),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                dashboardCard(Icons.person, "Users", totalUsers),
                dashboardCard(Icons.shopping_cart, "Orders", totalOrders),
                dashboardCard(Icons.store, "Products", totalProducts),
              ],
            ),
            const SizedBox(height: 40),

            const Text("Weekly Sales", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),

            SizedBox(
              height: 250,
              child: LineChart(
                LineChartData(
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
                        const days = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"];
                        if (value.toInt() >= 0 && value.toInt() < 7) {
                          return Text(days[value.toInt()]);
                        }
                        return const Text('');
                      }),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 3,
                      spots: List.generate(7, (i) => FlSpot(i.toDouble(), weeklySales[i].toDouble())),
                    )
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget dashboardCard(IconData icon, String title, int value) {
    return Container(
      width: 110,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 5)],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blue),
          const SizedBox(height: 10),
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 5),
          Text(value.toString(), style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}