import 'package:flutter/foundation.dart';
import '../models/product_model.dart';

class CartItem {
  final Product product;
  int qty;

  CartItem({required this.product, required this.qty});
}

class Order {
  final String id;
  final String buyerId;
  final List<CartItem> items;
  final String address;
  final double total;

  Order({
    required this.id,
    required this.buyerId,
    required this.items,
    required this.address,
    required this.total,
  });
}

class OrderService extends ChangeNotifier {
  final List<CartItem> _cart = [];
  final List<Order> _orders = [];
  final List<String> _addresses = [
    "123 Market Lane, Mumbai",
    "456 Trade Street, Delhi",
  ];

  List<CartItem> get cart => List.unmodifiable(_cart);
  List<Order> get orders => List.unmodifiable(_orders);
  List<String> get addresses => List.unmodifiable(_addresses);

  void addToCart(Product p, int qty) {
    final idx = _cart.indexWhere((c) => c.product.id == p.id);
    if (idx >= 0) {
      _cart[idx].qty += qty;
    } else {
      _cart.add(CartItem(product: p, qty: qty));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _cart.removeWhere((c) => c.product.id == productId);
    notifyListeners();
  }

  double cartTotal() {
    return _cart.fold(0.0, (s, c) => s + c.product.price * c.qty);
  }

  void addAddress(String addr) {
    _addresses.insert(0, addr);
    notifyListeners();
  }

  Future<void> placeOrder(String buyerId, String address) async {
    final total = cartTotal();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final order = Order(
      id: id,
      buyerId: buyerId,
      items: List.from(_cart),
      address: address,
      total: total,
    );
    _orders.insert(0, order);
    _cart.clear();
    notifyListeners();
  }

  /// Place an order immediately for a single product (without using the cart)
  Future<void> placeOrderNow(
    String buyerId,
    String address,
    Product p,
    int qty,
  ) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final item = CartItem(product: p, qty: qty);
    final total = (p.price * qty).toDouble();
    final order = Order(
      id: id,
      buyerId: buyerId,
      items: [item],
      address: address,
      total: total,
    );
    _orders.insert(0, order);
    notifyListeners();
  }
}
