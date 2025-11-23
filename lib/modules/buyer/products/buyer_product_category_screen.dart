import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/product_service.dart';
import '../../../models/product_model.dart';
import 'buyer_product_details_screen.dart';

class BuyerProductCategoryScreen extends StatelessWidget {
  final String categoryId;
  final String categoryTitle;

  const BuyerProductCategoryScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  Widget build(BuildContext context) {
    final service = Provider.of<ProductService>(context);

    // FIX: match lower-case for filtering
    final List<Product> items = service.products
        .where((p) => p.category.toLowerCase() == categoryId.toLowerCase())
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text(categoryTitle)),
      body: items.isEmpty
          ? Center(child: Text('No products found in this category'))
          : ListView.separated(
              padding: EdgeInsets.all(12),
              itemCount: items.length,
              separatorBuilder: (_, __) => SizedBox(height: 10),
              itemBuilder: (context, i) {
                final p = items[i];

                return Card(
                  elevation: 2,
                  child: ListTile(
                    title: Text(p.name),
                    subtitle: Text(
                      "MOQ ${p.moq}  •  ₹${p.price.toStringAsFixed(0)}",
                    ),
                    trailing: Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerProductDetailsScreen(product: p),
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
