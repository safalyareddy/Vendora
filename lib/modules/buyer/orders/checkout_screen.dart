import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/order_service.dart';
import '../../../services/auth_service.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String? _selectedAddress;
  final _newAddressCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final orderSvc = Provider.of<OrderService>(context);
    final auth = Provider.of<AuthService>(context, listen: false);

    final addresses = orderSvc.addresses;

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Delivery Address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            ...addresses.map(
              (a) => RadioListTile<String>(
                title: Text(a),
                value: a,
                groupValue: _selectedAddress,
                onChanged: (v) => setState(() => _selectedAddress = v),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _newAddressCtrl,
              decoration: const InputDecoration(labelText: 'Add new address'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () {
                    final v = _newAddressCtrl.text.trim();
                    if (v.isNotEmpty) {
                      orderSvc.addAddress(v);
                      setState(() {
                        _selectedAddress = v;
                        _newAddressCtrl.clear();
                      });
                    }
                  },
                  child: const Text('Add Address'),
                ),
                const SizedBox(width: 12),
                const Spacer(),
              ],
            ),
            const Spacer(),
            Text(
              'Total: ₹${orderSvc.cartTotal().toStringAsFixed(0)}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final addr =
                      _selectedAddress ??
                      (orderSvc.addresses.isNotEmpty
                          ? orderSvc.addresses.first
                          : null);
                  if (addr == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please add/select an address'),
                      ),
                    );
                    return;
                  }
                  await orderSvc.placeOrder(auth.userId ?? 'guest', addr);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Order placed (demo)')),
                  );
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                child: const Text('Place Order'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
