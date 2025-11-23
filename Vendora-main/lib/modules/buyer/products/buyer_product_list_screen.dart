import 'package:flutter/material.dart';
import 'package:wholesale_pro_app/models/product_model.dart';
import 'buyer_product_details_screen.dart';

class BuyerProductListScreen extends StatelessWidget {
  final List<Product> products;

  const BuyerProductListScreen({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),

      body: products.isEmpty
          ? Center(child: Text("No products available"))
          : ListView.builder(
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];

                final String? imageUrl = product.images.isNotEmpty
                    ? product.images.first
                    : null;

                return Card(
                  margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    leading: Container(
                      width: 55,
                      height: 55,
                      color: Colors.grey.shade200,
                      child: imageUrl != null
                          ? Image.network(
                              imageUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.broken_image,
                                color: Colors.grey,
                              ),
                            )
                          : Icon(Icons.image, color: Colors.grey),
                    ),

                    title: Text(
                      product.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),

                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          "₹${product.price}",
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "MOQ: ${product.moq}",
                          style: TextStyle(fontSize: 13),
                        ),
                      ],
                    ),

                    trailing: Icon(Icons.arrow_forward_ios, size: 16),

                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              BuyerProductDetailsScreen(product: product),
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
