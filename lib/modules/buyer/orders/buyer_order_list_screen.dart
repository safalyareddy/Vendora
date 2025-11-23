import 'package:flutter/material.dart';
import 'buyer_order_details_screen.dart';

class BuyerOrderListScreen extends StatefulWidget {
  const BuyerOrderListScreen({super.key});

  @override
  State<BuyerOrderListScreen> createState() => _BuyerOrderListScreenState();
}

class _BuyerOrderListScreenState extends State<BuyerOrderListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // mock orders — replace with real provider data later
  final List<Map<String, dynamic>> _orders = [
    {
      "id": "B1001",
      "product": "Premium Rice 10kg",
      "qty": 20,
      "price": 1180,
      "seller": "Wholesaler 1",
      "status": "Pending",
      "time": "2h ago",
    },
    {
      "id": "B1002",
      "product": "Sunflower Oil 5L",
      "qty": 5,
      "price": 620,
      "seller": "Shree Traders",
      "status": "Delivered",
      "time": "2d ago",
    },
    {
      "id": "B1003",
      "product": "Packaging Box",
      "qty": 200,
      "price": 30,
      "seller": "PackCo",
      "status": "Cancelled",
      "time": "1w ago",
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  List<Map<String, dynamic>> _filtered(String status) {
    if (status == "All") return _orders;
    return _orders.where((o) => o['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Orders"),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: "Active"),
            Tab(text: "Completed"),
            Tab(text: "Cancelled"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ordersTab(
            _filtered("Pending") + _filtered("Packed") + _filtered("Shipped"),
          ),
          _ordersTab(_filtered("Delivered")),
          _ordersTab(_filtered("Cancelled")),
        ],
      ),
    );
  }

  Widget _ordersTab(List<Map<String, dynamic>> list) {
    if (list.isEmpty) {
      return const Center(child: Text("No orders here"));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, i) {
        final o = list[i];
        return Card(
          child: ListTile(
            title: Text("${o['product']} • ${o['qty']} pcs"),
            subtitle: Text("${o['seller']} • ${o['time']}"),
            trailing: Chip(label: Text(o['status'])),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BuyerOrderDetailsScreen(order: o),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
