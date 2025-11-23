import 'package:flutter/material.dart';
import '../products/buyer_product_category_screen.dart';

class BuyerCategoriesScreen extends StatelessWidget {
  const BuyerCategoriesScreen({super.key});

  final List<Map<String, String>> categories = const [
    {"id": "wh1", "title": "Wholesaler 1"},
    {"id": "wh2", "title": "Wholesaler 2"},
    {"id": "electronics", "title": "Electronics"},
    {"id": "clothes", "title": "Clothes & Apparel"},
    {"id": "packaging", "title": "Packaging"},
    {"id": "stationery", "title": "Stationery"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Categories")),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 3 / 2,
          ),
          itemBuilder: (context, i) {
            final c = categories[i];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BuyerProductCategoryScreen(
                      categoryId: c['id']!,
                      categoryTitle: c['title']!,
                    ),
                  ),
                );
              },
              child: Card(
                elevation: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.storefront, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      c['title']!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
