import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/product_service.dart';
import '../products/buyer_product_category_screen.dart';

class BuyerOffersScreen extends StatelessWidget {
  const BuyerOffersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final productService = Provider.of<ProductService>(context, listen: false);

    // Example: compute top bulk deals (you can replace with real logic)
    final bulkDeals = productService.products
        .where((p) => p.slabPricing.isNotEmpty)
        .take(6)
        .toList();
    final flashDeals = productService.products
        .where((p) => p.price < 500)
        .take(6)
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Offers & Deals")),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // Exclusive from top wholesalers
          _sectionTitle("Exclusive Deals from Top Wholesalers"),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: bulkDeals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = bulkDeals[i];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BuyerProductCategoryScreen(
                          categoryId: p.category,
                          categoryTitle: "Deals — ${p.name}",
                        ),
                      ),
                    );
                  },
                  child: Card(
                    child: Container(
                      width: 220,
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            p.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            "From ${p.slabPricing.first['min']} pcs • Best bulk price",
                          ),
                          const Spacer(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "₹${p.price.toStringAsFixed(0)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BuyerProductCategoryScreen(
                                            categoryId: p.category,
                                            categoryTitle: p.name,
                                          ),
                                    ),
                                  );
                                },
                                child: const Text("View"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 14),
          _sectionTitle("Flash Deals — Limited Time"),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: flashDeals.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final p = flashDeals[i];
                return Card(
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 6),
                        Text("Up to 20% off • Limited time"),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "₹${p.price.toStringAsFixed(0)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => BuyerProductCategoryScreen(
                                      categoryId: p.category,
                                      categoryTitle: p.name,
                                    ),
                                  ),
                                );
                              },
                              child: const Text("Buy"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 18),
          _sectionTitle("Seasonal Offers"),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: [
                  const Text(
                    "Festival Ready Bulk Packs",
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Top packs specially curated for festivals — fast delivery and slab pricing.",
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      // show curated list
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BuyerProductCategoryScreen(
                            categoryId: "packaging",
                            categoryTitle: "Festival Packs",
                          ),
                        ),
                      );
                    },
                    child: const Text("Explore Packs"),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _sectionTitle(String t) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Text(
      t,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
    ),
  );
}
