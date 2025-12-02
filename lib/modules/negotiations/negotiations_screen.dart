import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/negotiation_service.dart';
import '../../services/auth_service.dart';

class NegotiationsScreen extends StatelessWidget {
  const NegotiationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context);
    final svc = Provider.of<NegotiationService>(context);

    final asBuyer = svc.requestsForBuyer(auth.userId ?? '');
    final asSeller = svc.requests; // demo: seller sees all requests

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Negotiations'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'As Buyer'),
              Tab(text: 'As Seller'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // As Buyer
            asBuyer.isEmpty
                ? const Center(child: Text('No negotiations sent'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: asBuyer.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final n = asBuyer[i];
                      return ListTile(
                        title: Text('Product: ${n.productId}'),
                        subtitle: Text(
                          'Qty: ${n.qty} • Offer: ₹${n.offeredPrice}',
                        ),
                        trailing: Text(n.status.toUpperCase()),
                      );
                    },
                  ),

            // As Seller
            asSeller.isEmpty
                ? const Center(child: Text('No negotiation requests'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: asSeller.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (ctx, i) {
                      final n = asSeller[i];
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Buyer: ${n.buyerId} • Status: ${n.status}'),
                              const SizedBox(height: 6),
                              Text('Product: ${n.productId} • Qty: ${n.qty}'),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: () =>
                                        svc.updateStatus(n.id, 'accepted'),
                                    child: const Text('Accept'),
                                  ),
                                  const SizedBox(width: 8),
                                  OutlinedButton(
                                    onPressed: () =>
                                        svc.updateStatus(n.id, 'rejected'),
                                    child: const Text('Reject'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
