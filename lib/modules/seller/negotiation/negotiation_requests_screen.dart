import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../app/app_routes.dart';
import '../../../services/negotiation_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/product_service.dart';

/// Shows negotiation requests - separated into tabs for "As Seller" and "As Buyer".
class NegotiationRequestsScreen extends StatelessWidget {
  const NegotiationRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final negotiationSvc = Provider.of<NegotiationService>(context);
    final auth = Provider.of<AuthService>(context);
    final productSvc = Provider.of<ProductService>(context, listen: false);

    final asBuyer = auth.userId == null
        ? <NegotiationRequest>[]
        : negotiationSvc.requestsForBuyer(auth.userId!);

    // As seller: requests for any product (in a simple demo we show all requests),
    // ideally we would filter to products owned by this seller.
    final asSeller = negotiationSvc.requests;

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Negotiations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'As Seller'),
              Tab(text: 'As Buyer'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _NegotiationListView(items: asSeller, productSvc: productSvc),
            _NegotiationListView(items: asBuyer, productSvc: productSvc),
          ],
        ),
      ),
    );
  }
}

class _NegotiationListView extends StatelessWidget {
  final List<NegotiationRequest> items;
  final ProductService productSvc;
  const _NegotiationListView({required this.items, required this.productSvc});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(child: Text('No negotiations found'));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: items.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (context, i) {
        final r = items[i];
        final product = productSvc.getById(r.productId);
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${r.buyerId} • ${r.status}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text('${product?.name ?? r.productId} • Qty: ${r.qty}'),
                const SizedBox(height: 8),
                Text(
                  'Offer: ₹${r.offeredPrice} per unit',
                  style: TextStyle(
                    color: Colors.green[800],
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(r.message),
                const SizedBox(height: 12),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Provider.of<NegotiationService>(
                          context,
                          listen: false,
                        ).updateStatus(r.id, 'accepted');
                      },
                      child: const Text('Accept'),
                    ),
                    const SizedBox(width: 8),
                    OutlinedButton(
                      onPressed: () {
                        Provider.of<NegotiationService>(
                          context,
                          listen: false,
                        ).updateStatus(r.id, 'rejected');
                      },
                      child: const Text('Reject'),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => Navigator.pushNamed(
                        context,
                        AppRoutes.negotiationChat,
                        arguments: r,
                      ),
                      child: const Text('Chat'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
