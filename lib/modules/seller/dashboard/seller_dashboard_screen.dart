// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import '../../../app/app_routes.dart';
import '../../../services/product_service.dart';

class SellerDashboardScreen extends StatelessWidget {
  const SellerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    final products = Provider.of<ProductService>(context).products;

    return WillPopScope(
      onWillPop: () async {
        final exit = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text("Exit app?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text("No"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text("Yes"),
              ),
            ],
          ),
        );
        return exit ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Seller Dashboard"),
          actions: [
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                auth.logout();
                Navigator.pushReplacementNamed(context, AppRoutes.roleSelect);
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: EdgeInsets.all(14),
            child: Column(
              children: [
                Text(
                  "Welcome, Wholesaler",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 12),

                // TOP TILES (Add Product, Negotiations, Orders, Analytics)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      child: _DashboardTile(
                        title: "Add Product",
                        icon: Icons.add_box,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.addProduct);
                        },
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      child: _DashboardTile(
                        title: "Negotiations",
                        icon: Icons.chat_bubble_outline,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.negotiations);
                        },
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      child: _DashboardTile(
                        title: "Orders",
                        icon: Icons.shopping_cart,
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.orders);
                        },
                      ),
                    ),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 60) / 3,
                      child: _DashboardTile(
                        title: "Analytics",
                        icon: Icons.analytics,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            AppRoutes.sellerDashboard,
                          );
                        },
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                // PRODUCT LIST
                Expanded(
                  child: ListView.separated(
                    itemCount: products.length,
                    separatorBuilder: (_, __) => SizedBox(height: 10),
                    itemBuilder: (context, i) {
                      final p = products[i];
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(p.name.isNotEmpty ? p.name[0] : "P"),
                        ),
                        title: Text(
                          p.name.isNotEmpty ? p.name : "Product ${i + 1}",
                        ),
                        subtitle: Text(
                          "MOQ: ${p.moq} · Slab pricing available",
                        ),
                        trailing: Wrap(
                          spacing: 6,
                          children: [
                            // EDIT BUTTON
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () {
                                // Pass the Product object directly
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.editProduct,
                                  arguments: p,
                                );
                              },
                            ),

                            // VIEW BUTTON
                            IconButton(
                              icon: Icon(Icons.visibility),
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  AppRoutes.productDetails,
                                  arguments: p,
                                );
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _DashboardTile({
    required this.title,
    required this.icon,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 28),
              SizedBox(height: 8),
              Text(title, style: TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
