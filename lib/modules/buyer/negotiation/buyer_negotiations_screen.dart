import 'package:flutter/material.dart';
import '../../../modules/seller/negotiation/negotiation_chat_screen.dart';

class BuyerNegotiationsScreen extends StatelessWidget {
  const BuyerNegotiationsScreen({super.key});

  // sample negotiation list - replace with provider data
  final List<Map<String, dynamic>> _negotiations = const [
    {
      "id": "n1",
      "seller": "Wholesaler 1",
      "product": "Premium Rice 10kg",
      "lastMsg": "Can do 1190 for 30",
      "status": "countered",
    },
    {
      "id": "n2",
      "seller": "Shree Traders",
      "product": "Sunflower Oil 5L",
      "lastMsg": "Accepted. Place order.",
      "status": "accepted",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Negotiations")),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemCount: _negotiations.length,
        separatorBuilder: (_, __) => const Divider(),
        itemBuilder: (context, i) {
          final n = _negotiations[i];
          return ListTile(
            title: Text(
              n['seller'],
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text("${n['product']} • ${n['lastMsg']}"),
            trailing: Text(n['status']),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => NegotiationChatScreen()),
              );
            },
          );
        },
      ),
    );
  }
}
