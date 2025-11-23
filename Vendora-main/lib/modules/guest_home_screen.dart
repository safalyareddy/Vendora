import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../app/app_routes.dart';
import '../../services/auth_service.dart';
import '../../services/product_service.dart';
import 'buyer/products/buyer_product_category_screen.dart';
import 'buyer/products/buyer_product_details_screen.dart';

class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  // Example banners (use nicer URLs if you want)
  static const List<String> _banners = [
    "https://images.unsplash.com/photo-1542291026-7eec264c27ff?w=1200",
    "https://images.unsplash.com/photo-1512290923902-8a9f81dc236c?w=1200",
    "https://images.unsplash.com/photo-1503602642458-232111445657?w=1200",
  ];

  final List<Map<String, String>> _categories = const [
    {
      'id': 'electronics',
      'title': 'Electronics',
      'img':
          'https://images.unsplash.com/photo-1511707171634-5f897ff02aa9?w=600',
    },
    {
      'id': 'clothes',
      'title': 'Clothing',
      'img':
          'https://images.unsplash.com/photo-1520975681654-4b8f6e8f2c82?w=600',
    },
    {
      'id': 'home',
      'title': 'Home & Kitchen',
      'img':
          'https://images.unsplash.com/photo-1505691723518-36a1fb0eeb1a?w=600',
    },
    {
      'id': 'stationery',
      'title': 'Stationery',
      'img':
          'https://images.unsplash.com/photo-1515879218367-8466d910aaa4?w=600',
    },
    {
      'id': 'packaging',
      'title': 'Packaging',
      'img':
          'https://images.unsplash.com/photo-1541534401786-3f7bd1e1d1d9?w=600',
    },
    {
      'id': 'fashion',
      'title': 'Fashion',
      'img':
          'https://images.unsplash.com/photo-1521335629791-ce4aec67ddc5?w=600',
    },
  ];

  void _requireLogin(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Login required"),
        content: const Text(
          "Please login as Buyer to place orders or negotiate.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
            },
            child: const Text("Login"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final productService = Provider.of<ProductService>(context);
    final products =
        productService.products; // your ProductService should expose this

    // Trending: top 6 products by price desc (sample)
    final trending = [...products];
    trending.sort((a, b) => b.price.compareTo(a.price));
    final trendingShort = trending.take(6).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Wholesale Browse"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              if (auth.role == AppRole.guest) {
                // Guest → RoleSelect
                Navigator.pushNamed(context, AppRoutes.roleSelect);
              } else if (auth.role == AppRole.buyer) {
                // Buyer → BuyerHome
                Navigator.pushNamed(context, AppRoutes.buyerHome);
              } else if (auth.role == AppRole.seller) {
                // Seller → SellerDashboard
                Navigator.pushNamed(context, AppRoutes.sellerDashboard);
              }
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          // simple pull-to-refresh placeholder while we don't have backend
          await Future.delayed(const Duration(milliseconds: 400));
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banners carousel (PageView)
              SizedBox(
                height: 180,
                child: PageView.builder(
                  itemCount: _banners.length,
                  itemBuilder: (context, i) {
                    final url = _banners[i];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          url,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          loadingBuilder: (ctx, child, progress) {
                            if (progress == null) return child;
                            return Container(
                              color: Colors.grey[200],
                              child: const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey[100],
                            child: const Center(
                              child: Icon(Icons.broken_image, size: 40),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Categories horizontal
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Categories",
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 120,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (ctx, idx) {
                    final c = _categories[idx];
                    return GestureDetector(
                      onTap: () {
                        // go to category product screen (BuyerProductCategoryScreen)
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
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 6),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: Image.network(
                                  c['img']!,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => Container(
                                    color: Colors.grey[100],
                                    child: const Icon(Icons.image, size: 40),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                c['title']!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: _categories.length,
                ),
              ),

              const SizedBox(height: 14),

              // Trending horizontal cards
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  "Trending Products",
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemCount: trendingShort.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (ctx, idx) {
                    final p = trendingShort[idx];
                    final img = p.images.isNotEmpty ? p.images.first : null;
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuyerProductDetailsScreen(product: p),
                          ),
                        );
                      },
                      child: SizedBox(
                        width: 220,
                        child: Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: img != null
                                      ? Image.network(
                                          img,
                                          width: double.infinity,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) =>
                                              Container(
                                                color: Colors.grey[100],
                                                child: const Center(
                                                  child: Icon(
                                                    Icons.broken_image,
                                                    size: 48,
                                                  ),
                                                ),
                                              ),
                                        )
                                      : Container(
                                          color: Colors.grey[100],
                                          child: const Icon(
                                            Icons.image,
                                            size: 48,
                                          ),
                                        ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      p.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      "MOQ ${p.moq} • ₹${p.price.toStringAsFixed(0)}",
                                      style: const TextStyle(fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Product grid (all products or category-specific)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    Text(
                      "All Products",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () {
                        // Could open full products list
                        Navigator.pushNamed(context, AppRoutes.guestHome);
                      },
                      child: const Text("See all"),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                itemCount: products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: .68,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (ctx, idx) {
                  final p = products[idx];
                  final img = p.images.isNotEmpty ? p.images.first : null;
                  return Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                BuyerProductDetailsScreen(product: p),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: img != null
                                    ? Image.network(
                                        img,
                                        width: double.infinity,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: Colors.grey[100],
                                          child: const Center(
                                            child: Icon(
                                              Icons.broken_image,
                                              size: 48,
                                            ),
                                          ),
                                        ),
                                      )
                                    : Container(
                                        color: Colors.grey[100],
                                        child: const Icon(
                                          Icons.image,
                                          size: 48,
                                        ),
                                      ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "₹${p.price.toStringAsFixed(0)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  "MOQ ${p.moq}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () {
                                  // If guest -> ask login
                                  if (auth.role == AppRole.guest) {
                                    _requireLogin(context);
                                    return;
                                  }
                                  // Buyer logged in -> proceed to order flow (TODO)
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          BuyerProductDetailsScreen(product: p),
                                    ),
                                  );
                                },
                                child: const Text("Order / Negotiate"),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
