import 'package:flutter/foundation.dart';
import 'package:wholesale_pro_app/models/product_model.dart';
import 'dart:math';

class ProductService extends ChangeNotifier {
  final List<Product> _products = [
    Product(
      id: "p1",
      name: "Premium Rice 10kg",
      category: "Groceries",
      description: "Aromatic long-grain rice, perfect for restaurants & shops.",
      price: 1200,
      moq: 5,
      stock: 150,
      negotiable: true,
      sellerId: 'seller_001',
      images: [
        "https://images.unsplash.com/photo-1560807707-8cc77767d783?auto=format&fit=crop&w=1200&q=80",
        "https://images.unsplash.com/photo-1505577058444-a3dab55d2b4f?auto=format&fit=crop&w=1200&q=80",
      ],
      slabPricing: [
        {"min": 1, "max": 9, "price": 1300},
        {"min": 10, "max": 49, "price": 1250},
        {"min": 50, "max": 9999, "price": 1200},
      ],
    ),
    Product(
      id: "p2",
      name: "Sunflower Oil 5L",
      category: "Cooking Oil",
      description: "Refined sunflower oil, trusted brand for eateries.",
      price: 600,
      moq: 2,
      stock: 80,
      negotiable: false,
      sellerId: 'seller_002',
      images: [
        "https://images.unsplash.com/photo-1582719478188-7a7a5d2b3b6f?auto=format&fit=crop&w=1200&q=80",
      ],
      slabPricing: [
        {"min": 1, "max": 4, "price": 650},
        {"min": 5, "max": 19, "price": 620},
      ],
    ),
    Product(
      id: "p3",
      name: "Granulated Sugar 5kg",
      category: "Groceries",
      description: "High-quality granulated sugar for retail and foodservice.",
      price: 420,
      moq: 3,
      stock: 200,
      negotiable: true,
      sellerId: 'seller_001',
      images: [
        "https://images.unsplash.com/photo-1567574167972-6c3a0b8a8e8a?auto=format&fit=crop&w=1200&q=80",
      ],
      slabPricing: [
        {"min": 1, "max": 9, "price": 450},
        {"min": 10, "max": 49, "price": 430},
      ],
    ),
    Product(
      id: "p4",
      name: "Liquid Detergent 2L",
      category: "Household",
      description: "Concentrated liquid detergent for laundry and cleaning.",
      price: 250,
      moq: 4,
      stock: 120,
      negotiable: false,
      sellerId: 'seller_003',
      images: [
        "https://images.unsplash.com/photo-1616628185487-c2d8b4b2a8f9?auto=format&fit=crop&w=1200&q=80",
      ],
      slabPricing: [
        {"min": 1, "max": 9, "price": 270},
        {"min": 10, "max": 99, "price": 240},
      ],
    ),
    Product(
      id: "p5",
      name: "Assorted Biscuits Case",
      category: "Snacks",
      description: "Mixed biscuits case pack for retail outlets.",
      price: 980,
      moq: 2,
      stock: 60,
      negotiable: true,
      sellerId: 'seller_002',
      images: [
        "https://images.unsplash.com/photo-1601924582971-9be2f7d5f4d8?auto=format&fit=crop&w=1200&q=80",
      ],
      slabPricing: [
        {"min": 1, "max": 4, "price": 1050},
        {"min": 5, "max": 19, "price": 1000},
      ],
    ),
  ];

  // Expose unmodifiable list
  List<Product> get products => List.unmodifiable(_products);

  // FIXED: Safe null-return
  Product? getById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> addProduct(Product p) async {
    _products.insert(0, p);
    notifyListeners();
    // TODO: persist to backend
  }

  Future<void> updateProduct(Product updated) async {
    final idx = _products.indexWhere((p) => p.id == updated.id);
    if (idx >= 0) {
      _products[idx] = updated;
      notifyListeners();
    }
    // TODO: backend update
  }

  Future<void> removeProduct(String id) async {
    _products.removeWhere((p) => p.id == id);
    notifyListeners();
    // TODO: backend delete
  }

  String generateId() {
    final r = Random().nextInt(1 << 30);
    return "p$r";
  }
}
