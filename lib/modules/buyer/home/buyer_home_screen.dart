// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wholesale_pro_app/services/auth_service.dart';
import 'package:wholesale_pro_app/modules/auth/role_select_screen.dart';
import 'package:wholesale_pro_app/app/app_routes.dart';
import '../categories/buyer_category_screen.dart';
import '../offers/buyer_offers_screen.dart';

class BuyerHomeScreen extends StatelessWidget {
  const BuyerHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

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
          title: Text("Buyer Home"),
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                /// ⭐ NEW BUTTON: Navigate to Role Select Screen
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.switch_account),
                    label: Text("Change Role"),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => RoleSelectScreen()),
                      );
                    },
                  ),
                ),

                SizedBox(height: 12),

                Text(
                  "Welcome, Buyer",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),

                SizedBox(height: 12),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _ActionCard(
                      title: "Categories",
                      icon: Icons.category,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuyerCategoriesScreen(),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      title: "Offers",
                      icon: Icons.local_offer,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const BuyerOffersScreen(),
                          ),
                        );
                      },
                    ),
                    _ActionCard(
                      title: "Orders",
                      icon: Icons.inventory_2,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.orders);
                      },
                    ),
                    _ActionCard(
                      title: "Negotiations",
                      icon: Icons.chat_bubble_outline,
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.negotiations);
                      },
                    ),
                  ],
                ),

                SizedBox(height: 18),

                Expanded(
                  child: ListView.builder(
                    itemCount: 6,
                    itemBuilder: (context, i) => Card(
                      child: ListTile(
                        title: Text("Wholesaler ${i + 1}"),
                        subtitle: Text("Top categories · MOQ info · Verified"),
                        trailing: ElevatedButton(
                          child: Text("View"),
                          onPressed: () {},
                        ),
                      ),
                    ),
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

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Card(
          elevation: 2,
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
      ),
    );
  }
}
