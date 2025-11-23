import 'package:flutter/material.dart';

class SellerOrdersScreen extends StatefulWidget {
  const SellerOrdersScreen({super.key});

  @override
  State<SellerOrdersScreen> createState() => _SellerOrdersScreenState();
}

class _SellerOrdersScreenState extends State<SellerOrdersScreen> {
  String _filter = "All";

  final List<Map<String, dynamic>> _orders = [
    {
      "id": "o1",
      "product": "Premium Rice 10kg",
      "qty": 20,
      "price": 1180,
      "buyer": "Kumar Stores",
      "status": "Pending",
      "time": "2h ago",
    },
    {
      "id": "o2",
      "product": "Sunflower Oil 5L",
      "qty": 5,
      "price": 620,
      "buyer": "Shree Traders",
      "status": "Packed",
      "time": "1d ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    final filtered = _filter == "All"
        ? _orders
        : _orders.where((o) => o['status'] == _filter).toList();
    return Scaffold(
      appBar: AppBar(title: Text("Manage Orders")),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(12),
            child: Row(
              children: [
                Text("Filter:"),
                SizedBox(width: 12),
                DropdownButton<String>(
                  value: _filter,
                  items:
                      [
                            "All",
                            "Pending",
                            "Packed",
                            "Shipped",
                            "Delivered",
                            "Cancelled",
                          ]
                          .map(
                            (s) => DropdownMenuItem(value: s, child: Text(s)),
                          )
                          .toList(),
                  onChanged: (v) => setState(() => _filter = v!),
                ),
                Spacer(),
                Text("${filtered.length} orders"),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: filtered.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, i) {
                final o = filtered[i];
                return Card(
                  child: ListTile(
                    title: Text("${o['product']} • ${o['qty']} pcs"),
                    subtitle: Text("Buyer: ${o['buyer']} • ${o['time']}"),
                    trailing: PopupMenuButton<String>(
                      onSelected: (val) {
                        setState(() => o['status'] = val);
                      },
                      itemBuilder: (_) =>
                          [
                                "Pending",
                                "Packed",
                                "Shipped",
                                "Delivered",
                                "Cancelled",
                              ]
                              .map(
                                (s) => PopupMenuItem(value: s, child: Text(s)),
                              )
                              .toList(),
                      child: Chip(label: Text(o['status'])),
                    ),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Order ${o['id']}",
                                style: TextStyle(fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 8),
                              Text(
                                "${o['product']} • Qty: ${o['qty']} • ₹${o['price']}",
                              ),
                              SizedBox(height: 8),
                              Text("Buyer: ${o['buyer']}"),
                              SizedBox(height: 12),
                              Text("Status: ${o['status']}"),
                              SizedBox(height: 12),
                              ElevatedButton(
                                onPressed: () {
                                  /* contact buyer */
                                },
                                child: Text("Contact Buyer"),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
