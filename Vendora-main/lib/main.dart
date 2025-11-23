import 'package:flutter/material.dart';
import 'dart:io' show File;
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app_routes.dart';

// Common
import 'modules/common/splash_screen.dart';
import 'modules/common/firebase_setup_required_screen.dart';

// Auth
import 'modules/auth/role_select_screen.dart';
import 'modules/auth/login_screen.dart';
import 'modules/auth/register_screen.dart';
import 'modules/auth/forgot_password_screen.dart';
import 'modules/auth/request_otp_screen.dart';
import 'modules/auth/reset_with_otp_screen.dart';

// Buyer
import 'modules/buyer/home/buyer_home_screen.dart';

// Seller
import 'modules/seller/dashboard/seller_dashboard_screen.dart';
import 'modules/seller/dashboard/seller_analytics_screen.dart';
import 'modules/seller/products/add_product_screen.dart';
import 'modules/seller/products/edit_product_screen.dart';
import 'modules/seller/products/seller_product_detail_screen.dart';

// Negotiations
import 'modules/seller/negotiation/negotiation_chat_screen.dart';
import 'modules/negotiations/negotiations_screen.dart';

// Orders
import 'modules/seller/orders/seller_orders_screen.dart';

// Guest
import 'modules/guest_home_screen.dart';

// Services
import 'models/product_model.dart';
import 'services/auth_service.dart';
import 'services/product_service.dart';
import 'services/order_service.dart';
import 'services/negotiation_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppInitializer());
}

class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Detect common Firebase config artifacts to avoid calling initializeApp
    // when no configuration is present (developer hasn't run flutterfire configure
    // or added platform files). This helps the app fail gracefully during dev.
    final hasLibOptions = File('lib/firebase_options.dart').existsSync();
    final hasAndroidGoogle = File('android/app/google-services.json').existsSync();
    final hasiOSPlist = File('ios/Runner/GoogleService-Info.plist').existsSync();

    if (!hasLibOptions && !hasAndroidGoogle && !hasiOSPlist) {
      // No local Firebase config detected — show setup guidance screen
      return MaterialApp(home: FirebaseSetupRequiredScreen(error: 'No firebase options or native config found'));
    }

    return FutureBuilder<FirebaseApp>(
      future: Firebase.initializeApp(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(home: Scaffold(body: Center(child: CircularProgressIndicator())));
        }

        if (snapshot.hasError) {
          // Show a friendly screen instructing the developer to configure Firebase
          return MaterialApp(home: FirebaseSetupRequiredScreen(error: snapshot.error.toString()));
        }

        // Firebase initialized successfully
        return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) {
              final svc = AuthService();
              // Optional: set this to your deployed Cloud Functions base URL so
              // the app can call the password-reset HTTP endpoint automatically.
              // Example:
              // svc.setFunctionsBaseUrl('https://us-central1-yourproject.cloudfunctions.net');
              return svc;
            }),
            ChangeNotifierProvider(create: (_) => ProductService()),
            ChangeNotifierProvider(create: (_) => OrderService()),
            ChangeNotifierProvider(create: (_) => NegotiationService()),
          ],
          child: const WholesaleApp(),
        );
      },
    );
  }
}

class WholesaleApp extends StatelessWidget {
  const WholesaleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Wholesale Procurement",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),

      initialRoute: AppRoutes.splash,

      routes: {
        // ----------------------
        // Common
        // ----------------------
        AppRoutes.splash: (_) => const SplashScreen(),

        // ----------------------
        // Auth
        // ----------------------
    AppRoutes.roleSelect: (_) => const RoleSelectScreen(),
  AppRoutes.login: (_) => const LoginScreen(),
  AppRoutes.forgotPassword: (_) => const ForgotPasswordScreen(),
  AppRoutes.forgotRequestOtp: (_) => const RequestOtpScreen(),
  AppRoutes.forgotEnterOtp: (_) => const ResetWithOtpScreen(),
    AppRoutes.register: (_) => const RegisterScreen(),

        // ----------------------
        // Buyer
        // ----------------------
        AppRoutes.buyerHome: (_) => const BuyerHomeScreen(),

        // ----------------------
        // Guest
        // ----------------------
        AppRoutes.guestHome: (_) => const GuestHomeScreen(),

        // ----------------------
        // Seller Dashboard
        // ----------------------
        AppRoutes.sellerDashboard: (_) => const SellerDashboardScreen(),

        // ----------------------
        // Seller: Add Product
        // ----------------------
        AppRoutes.addProduct: (_) => const AddProductScreen(),

        // ----------------------
        // Seller: Edit Product
        // ----------------------
        AppRoutes.editProduct: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          Product? product;

          if (args is Product) {
            product = args;
          } else if (args is Map && args["productId"] != null) {
            final id = args["productId"].toString();
            product = Provider.of<ProductService>(
              ctx,
              listen: false,
            ).getById(id);
          }

          product ??= Product(
            id: '',
            name: '',
            category: '',
            description: '',
            price: 0.0,
            moq: 1,
            stock: 0,
          );

          return EditProductScreen(product: product);
        },

        // ----------------------
        // Seller: Product Details
        // ----------------------
        AppRoutes.productDetails: (ctx) {
          final args = ModalRoute.of(ctx)?.settings.arguments;
          Product? product;

          if (args is Product) {
            product = args;
          } else if (args is Map && args["productId"] != null) {
            final id = args["productId"].toString();
            product = Provider.of<ProductService>(
              ctx,
              listen: false,
            ).getById(id);
          }

          product ??= Product(
            id: '',
            name: '',
            category: '',
            description: '',
            price: 0.0,
            moq: 1,
            stock: 0,
          );

          return SellerProductDetailScreen(product: product);
        },

        // ----------------------
        // Negotiations (Buyer & Seller)
        // ----------------------
        AppRoutes.negotiations: (_) => const NegotiationsScreen(),

        // ----------------------
        // Negotiation Chat
        // ----------------------
        AppRoutes.negotiationChat: (ctx) {
          // Negotiation chat screen can read ModalRoute arguments itself.
          return const NegotiationChatScreen();
        },

        // ----------------------
        // Orders
        // ----------------------
        AppRoutes.orders: (_) => const SellerOrdersScreen(),

        // ----------------------
        // Seller analytics
        // ----------------------
        AppRoutes.sellerAnalytics: (_) => const SellerAnalyticsScreen(),
      },
    );
  }
}
