class AppRoutes {
  static const String splash = "/";

  // Auth
  static const String roleSelect = "/roleSelect";
  static const String login = "/login";
  static const String register = "/register";
  static const String forgotPassword = "/forgot";
  static const String forgotRequestOtp = "/forgot/requestOtp";
  static const String forgotEnterOtp = "/forgot/enterOtp";

  // Buyer / Guest
  static const String buyerHome = "/buyerHome";
  static const String guestHome = "/guestHome";

  // Seller
  static const String sellerDashboard = "/sellerDashboard";

  // Seller product flows
  static const String addProduct = "/seller/addProduct";
  static const String editProduct = "/seller/editProduct";
  static const String productDetails = "/seller/productDetails";

  // Negotiations
  static const String negotiations = "/negotiations";
  static const String negotiationChat = "/negotiationChat";

  // Seller analytics
  static const String sellerAnalytics = "/seller/analytics";

  // Orders
  static const String orders = "/orders";
}
