import 'package:flutter/material.dart';

class BuyerOrderDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> order;
  const BuyerOrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order ${order['id']}')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Product: ${order['product']}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            Text('Seller: ${order['seller']}'),
            SizedBox(height: 8),
            Text('Quantity: ${order['qty']}'),
            SizedBox(height: 8),
            Text('Total price: ₹${order['price']}'),
            SizedBox(height: 8),
            Text('Status: ${order['status']}'),
            SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
