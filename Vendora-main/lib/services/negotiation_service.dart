import 'package:flutter/foundation.dart';

class NegotiationRequest {
  final String id;
  final String productId;
  final String buyerId;
  final int qty;
  final double offeredPrice;
  final String message;
  String status; // pending / accepted / rejected

  NegotiationRequest({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.qty,
    required this.offeredPrice,
    required this.message,
    this.status = 'pending',
  });
}

class NegotiationService extends ChangeNotifier {
  final List<NegotiationRequest> _requests = [];

  List<NegotiationRequest> get requests => List.unmodifiable(_requests);

  void addRequest(NegotiationRequest r) {
    _requests.insert(0, r);
    notifyListeners();
  }

  List<NegotiationRequest> requestsForProduct(String productId) {
    return _requests.where((r) => r.productId == productId).toList();
  }

  List<NegotiationRequest> requestsForBuyer(String buyerId) {
    return _requests.where((r) => r.buyerId == buyerId).toList();
  }

  void updateStatus(String id, String status) {
    final idx = _requests.indexWhere((r) => r.id == id);
    if (idx >= 0) {
      _requests[idx].status = status;
      notifyListeners();
    }
  }
}
