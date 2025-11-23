import 'package:flutter/material.dart';
import '../../buyer/products/buyer_product_details_screen.dart';
import 'edit_product_screen.dart';
import 'package:wholesale_pro_app/models/product_model.dart';

class SellerProductDetailScreen extends StatelessWidget {
  final Product product;
  const SellerProductDetailScreen({required this.product, super.key});

  // Defensive helpers: coerce possibly-invalid fields into safe, expected types
  List<String> _safeImages() {
    // Read via dynamic to allow defending against mis-typed data at runtime
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
        child: Center(child: Icon(Icons.image_not_supported, size: 56)),
      );
    }
    return SizedBox(
      height: 260,
      child: PageView(
        children: images.map((u) {
          if (u.toString().trim().isEmpty) {
            return Container(
              color: Colors.grey[100],
              child: Center(child: Icon(Icons.broken_image, size: 56)),
            );
          }
          final url = u.toString();
          // If the url looks like a network url, show Image.network, else fallback
          if (url.startsWith('http')) {
            return Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return Container(
                  color: Colors.grey[100],
                  child: Center(child: Icon(Icons.broken_image, size: 56)),
                );
              },
            );
          }
          return Container(
            color: Colors.grey[100],
            child: Center(child: Icon(Icons.broken_image, size: 56)),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSlabRows() {
    final slabs = _safeSlabs();
    if (slabs.isEmpty) {
      return Text("No slab pricing configured.");
    }

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
              Text("$min - $max pcs"),
              Text("₹${price.toString()} / unit"),
            ],
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        actions: [
          IconButton(
            icon: Icon(Icons.edit_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProductScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(16),
        children: [
          _buildImageCarousel(),
          SizedBox(height: 16),

          Text(
            product.name,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 6),
          Text(
            "Category: ${product.category}",
            style: TextStyle(color: Colors.grey[700]),
          ),

          SizedBox(height: 12),
          Row(
            children: [
              Text(
                "₹${product.price.toStringAsFixed(0)}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
              SizedBox(width: 12),
              Chip(label: Text("MOQ ${product.moq}")),
              SizedBox(width: 8),
              product.negotiable
                  ? Chip(label: Text("Negotiable"))
                  : SizedBox.shrink(),
            ],
          ),

          SizedBox(height: 16),
          Text(
            "Stock: ${product.stock}",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),

          SizedBox(height: 16),
          Text(
            "Slab Pricing",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          _buildSlabRows(),

          Divider(height: 28),

          Text(
            "Description",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 8),
          Text(product.description),

          SizedBox(height: 24),

          // ---------------------------------------------------------
          // FIXED: Now passing the Product object, not a Map
          // ---------------------------------------------------------
          ElevatedButton.icon(
            icon: Icon(Icons.open_in_new),
            label: Text("Preview as Buyer"),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => BuyerProductDetailsScreen(product: product),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
