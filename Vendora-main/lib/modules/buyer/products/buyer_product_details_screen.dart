// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/product_model.dart';
import '../../../services/auth_service.dart';
import '../../../services/negotiation_service.dart';
import '../../buyer/orders/order_placement_screen.dart';
import 'dart:math';

class BuyerProductDetailsScreen extends StatefulWidget {
  final Product product;
  const BuyerProductDetailsScreen({super.key, required this.product});

  @override
  State<BuyerProductDetailsScreen> createState() => _BuyerProductDetailsScreenState();
}

class _BuyerProductDetailsScreenState extends State<BuyerProductDetailsScreen> {
  Product get product => widget.product;

  List<String> _safeImages() {
    final dynamic raw = (product as dynamic).images;
    if (raw == null) return [];
    if (raw is List<String>) return raw;
    if (raw is List) return raw.whereType<String>().toList();
    try {
      return List<String>.from(raw);
    } catch (_) {
      return [];
    }
  }

  List<Map<String, dynamic>> _safeSlabs() {
    final dynamic raw = (product as dynamic).slabPricing;
    if (raw == null) return [];
    if (raw is List<Map<String, dynamic>>) return raw;
    if (raw is List) {
      return raw
          .map((e) {
            if (e is Map) {
              try {
                return Map<String, dynamic>.from(e);
              } catch (_) {
                return <String, dynamic>{};
              }
            }
            return <String, dynamic>{};
          })
          .where((m) => m.isNotEmpty)
          .toList();
    }
    return [];
  }

  Widget _buildImageCarousel() {
    final images = _safeImages();
    if (images.isEmpty) {
      return Container(
        height: 220,
        color: Colors.grey[100],
        child: const Center(child: Icon(Icons.image_not_supported, size: 56)),
      );
    }
    return SizedBox(
      height: 260,
      child: PageView(
        children: images.map((u) {
          final url = u.toString();
          if (url.startsWith('http')) {
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image, size: 56),
                );
              },
            );
          }
          return Container(
            color: Colors.grey[100],
            child: const Icon(Icons.broken_image, size: 56),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlabRows() {
    final slabs = _safeSlabs();
    if (slabs.isEmpty) return const Text("No slab pricing configured.");

    return Column(
      children: slabs.map((s) {
        final min = s['min']?.toString() ?? '-';
        final max = s['max']?.toString() ?? '-';
        final price = (s['price'] is num)
            ? s['price']
            : double.tryParse(s['price']?.toString() ?? '') ?? 0;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('$min - $max pcs'),
              Text('₹${price.toString()} / unit'),
            ],
          ),
        );
      }).toList(),
    );
  }

  void _askLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text("Login required"),
        content: const Text(
          "Please login as Buyer to place orders or negotiate.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pushReplacementNamed(
                dialogContext,
                '/roleSelect',
              ); // or AppRoutes.roleSelect
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          // preview/edit only if seller owns it; kept minimal
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageCarousel(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    product.category,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '₹${product.price}',
                        style: TextStyle(
                          fontSize: 22,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Chip(label: Text('MOQ ${product.moq}')),
                      const SizedBox(width: 8),
                      product.negotiable
                          ? const Chip(label: Text('Negotiable'))
                          : const SizedBox.shrink(),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Stock: ${product.stock}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Description',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product.description.isNotEmpty
                        ? product.description
                        : 'No description provided',
                  ),
                  const SizedBox(height: 18),
                  if (_safeSlabs().isNotEmpty) ...[
                    const Text(
                      'Slab Pricing',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildSlabRows(),
                    const SizedBox(height: 12),
                  ],
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (auth.role == AppRole.guest) {
                              _askLogin(context);
                              return;
                            }

                            // simple qty dialog and add to cart
                            final qtyCtrl = TextEditingController(
                              text: product.moq.toString(),
                            );
                            final added = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Add to Cart'),
                                content: TextField(
                                  controller: qtyCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    labelText: 'Quantity',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, false),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () =>
                                        Navigator.pop(dialogContext, true),
                                    child: const Text('Add'),
                                  ),
                                ],
                              ),
                            );

                            if (added != true) return;

                            final qty = int.tryParse(qtyCtrl.text) ?? product.moq;

                            if (!mounted) return;
                            // Navigate to order placement screen to continue checkout for this item
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => OrderPlacementScreen(
                                  product: product,
                                  qty: qty,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text('Place Order'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            if (auth.role == AppRole.guest) {
                              _askLogin(context);
                              return;
                            }

                            if (!product.negotiable) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Negotiation not available for this product',
                                  ),
                                ),
                              );
                              return;
                            }

                            // show negotiate dialog
                            final priceCtrl = TextEditingController(
                              text: product.price.toStringAsFixed(0),
                            );
                            final qtyCtrl = TextEditingController(
                              text: product.moq.toString(),
                            );
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Send Negotiation Request'),
                                content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TextField(
                                      controller: qtyCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Quantity',
                                      ),
                                    ),
                                    TextField(
                                      controller: priceCtrl,
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(
                                        labelText: 'Offer per unit',
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Cancel'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      final qty = int.tryParse(qtyCtrl.text) ?? product.moq;
                                      final price = double.tryParse(priceCtrl.text) ?? product.price;
                                      final svc = Provider.of<NegotiationService>(
                                        dialogContext,
                                        listen: false,
                                      );
                                      final id = 'n\$${Random().nextInt(1 << 30)}';
                                      svc.addRequest(
                                        NegotiationRequest(
                                          id: id,
                                          productId: product.id,
                                          buyerId: Provider.of<AuthService>(
                                            dialogContext,
                                            listen: false,
                                          ).userId ?? 'buyer_demo',
                                          qty: qty,
                                          offeredPrice: price,
                                          message: 'Buyer offer',
                                        ),
                                      );
                                      Navigator.pop(dialogContext);
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Negotiation request sent',
                                          ),
                                        ),
                                      );
                                    },
                                    child: const Text('Send'),
                                  ),
                                ],
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline),
                          label: const Text('Negotiate'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
