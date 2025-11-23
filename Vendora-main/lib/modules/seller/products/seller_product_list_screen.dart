import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../services/product_service.dart';
import 'add_product_screen.dart';
import 'edit_product_screen.dart';
import 'seller_product_detail_screen.dart';

class SellerProductListScreen extends StatelessWidget {
  const SellerProductListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context);
    final products = productService.products;

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Catalog"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            tooltip: "Add Product",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddProductScreen()),
              );
            },
          ),
        ],
      ),

      body: products.isEmpty
          ? const Center(
              child: Text(
                "No products added yet.\nTap + to add your first product.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final p = products[index];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),

                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: SizedBox(
                        width: 64,
                        height: 64,
                        child: p.images.isNotEmpty
                            ? Image.network(
                                p.images[0],
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.broken_image, size: 32),
                              )
                            : const Icon(Icons.image_not_supported, size: 32),
                      ),
                    ),

                    title: Text(
                      p.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),

                    subtitle: Text(
                      "₹${p.price.toStringAsFixed(0)}  •  MOQ ${p.moq}  •  Stock ${p.stock}",
                    ),

                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == "view") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  SellerProductDetailScreen(product: p),
                            ),
                          );
                        } else if (value == "edit") {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProductScreen(product: p),
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: "view", child: Text("View")),
                        const PopupMenuItem(value: "edit", child: Text("Edit")),
                      ],
                    ),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SellerProductDetailScreen(product: p),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
