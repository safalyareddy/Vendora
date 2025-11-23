import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';
import 'checkout_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orderSvc = Provider.of<OrderService>(context);
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Expanded(
              child: ListView.separated(
                itemCount: orderSvc.cart.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (ctx, i) {
                  final c = orderSvc.cart[i];
                  return ListTile(
                    title: Text(c.product.name),
                    subtitle: Text('Qty: ${c.qty} • ₹${c.product.price}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () => orderSvc.removeFromCart(c.product.id),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ₹${orderSvc.cartTotal().toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (auth.role == AppRole.guest) {
                      Navigator.pushReplacementNamed(context, '/roleSelect');
                      return;
                    }
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CheckoutScreen()),
                    );
                  },
                  child: const Text('Checkout'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
