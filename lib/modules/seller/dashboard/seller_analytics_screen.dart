import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';
// product_service import not required here

class SellerAnalyticsScreen extends StatelessWidget {
  const SellerAnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final orderSvc = Provider.of<OrderService>(context);
    final sellerId = auth.userId ?? 'seller_123';

    // Aggregate sales for this seller
    int totalItemsSold = 0;
    double totalRevenue = 0.0;
    final Map<String, int> unitsByProduct = {};
    final Map<String, double> revenueByCategory = {};

    for (final order in orderSvc.orders) {
      for (final item in order.items) {
        final p = item.product;
        if (p.sellerId != null && p.sellerId == sellerId) {
          totalItemsSold += item.qty;
          final revenue = (p.price * item.qty).toDouble();
          totalRevenue += revenue;
          unitsByProduct.update(
            p.name,
            (v) => v + item.qty,
            ifAbsent: () => item.qty,
          );
          revenueByCategory.update(
            p.category,
            (v) => v + revenue,
            ifAbsent: () => revenue,
          );
        }
      }
    }

    final topProducts = unitsByProduct.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topCategories = revenueByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Scaffold(
      appBar: AppBar(title: const Text('Seller Analytics')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total items sold: $totalItemsSold',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Total revenue: ₹${totalRevenue.toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),

            const Text(
              'Top Products (by units sold)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (topProducts.isEmpty)
              const Text('No sales yet')
            else
              ...topProducts
                  .take(5)
                  .map(
                    (e) => ListTile(
                      title: Text(e.key),
                      trailing: Text('${e.value} pcs'),
                    ),
                  ),

            const SizedBox(height: 12),
            const Text(
              'Top Categories (by revenue)',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            if (topCategories.isEmpty)
              const Text('No sales yet')
            else
              ...topCategories
                  .take(5)
                  .map(
                    (e) => ListTile(
                      title: Text(e.key),
                      trailing: Text('₹${e.value.toStringAsFixed(0)}'),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
