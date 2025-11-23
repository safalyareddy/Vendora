import 'package:flutter/material.dart';

class NegotiationChatScreen extends StatefulWidget {
  const NegotiationChatScreen({super.key});

  @override
  State<NegotiationChatScreen> createState() => _NegotiationChatScreenState();
}

class _NegotiationChatScreenState extends State<NegotiationChatScreen> {
  final _messages = <Map<String, dynamic>>[
    {"author": "buyer", "text": "Can you do 1180/unit for 20?", "time": "2h"},
    {
      "author": "seller",
      "text": "I can do 1190, but need 30 qty to go to 1180.",
      "time": "2h",
    },
  ];
  final _ctrl = TextEditingController();

  void _sendText() {
    if (_ctrl.text.trim().isEmpty) return;
    setState(
      () => _messages.add({
        "author": "seller",
        "text": _ctrl.text.trim(),
        "time": "now",
      }),
    );
    _ctrl.clear();
    // TODO: push to backend chat
  }

  Widget _msgBubble(Map<String, dynamic> m) {
    final isBuyer = m['author'] == 'buyer';
    return Row(
      mainAxisAlignment: isBuyer
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      children: [
        Container(
          margin: EdgeInsets.symmetric(vertical: 6, horizontal: 8),
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isBuyer ? Colors.grey[200] : Colors.indigo[100],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Column(
            crossAxisAlignment: isBuyer
                ? CrossAxisAlignment.start
                : CrossAxisAlignment.end,
            children: [
              Text(m['text']),
              SizedBox(height: 6),
              Text(
                m['time'],
                style: TextStyle(fontSize: 10, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Negotiation Chat")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (_, i) => _msgBubble(_messages[i]),
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: InputDecoration(hintText: "Type your message…"),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendText),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
