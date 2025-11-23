// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/order_service.dart';

class OrderPlacementScreen extends StatefulWidget {
  final Product product;
  final int qty;

  const OrderPlacementScreen({
    super.key,
    required this.product,
    required this.qty,
  });

  @override
  State<OrderPlacementScreen> createState() => _OrderPlacementScreenState();
}

class _OrderPlacementScreenState extends State<OrderPlacementScreen> {
  String? _selectedAddress;
  final _newAddrCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final svc = Provider.of<OrderService>(context, listen: false);
    if (svc.addresses.isNotEmpty) _selectedAddress = svc.addresses.first;
  }

  @override
  void dispose() {
    _newAddrCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderSvc = Provider.of<OrderService>(context);
    final auth = Provider.of<AuthService>(context, listen: false);

    final total = widget.product.price * widget.qty;

    return Scaffold(
      appBar: AppBar(title: const Text('Place Order')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.product.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text('Qty: ${widget.qty} • ₹${widget.product.price} per unit'),
            const SizedBox(height: 12),

            const Text(
              'Select delivery address',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            if (orderSvc.addresses.isNotEmpty)
              DropdownButton<String>(
                value: _selectedAddress,
                items: orderSvc.addresses
                    .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedAddress = v),
              ),

            const SizedBox(height: 8),
            TextField(
              controller: _newAddrCtrl,
              decoration: const InputDecoration(
                labelText: 'Or enter a new address',
              ),
            ),

            const Spacer(),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final address = (_newAddrCtrl.text.trim().isNotEmpty)
                          ? _newAddrCtrl.text.trim()
                          : _selectedAddress;
                      if (address == null || address.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please provide an address'),
                          ),
                        );
                        return;
                      }

                      // Save new address if provided
                      if (_newAddrCtrl.text.trim().isNotEmpty) {
                        orderSvc.addAddress(_newAddrCtrl.text.trim());
                      }

                      final buyerId = auth.userId ?? 'guest_buyer';
                      await orderSvc.placeOrderNow(
                        buyerId,
                        address,
                        widget.product,
                        widget.qty,
                      );

                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Order placed successfully'),
                        ),
                      );
                      Navigator.popUntil(context, (route) => route.isFirst);
                    },
                    child: Text('Pay ₹${total.toStringAsFixed(0)}'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
