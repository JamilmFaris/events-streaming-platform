import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageWidget extends StatelessWidget {
  MessageWidget({required this.message, super.key});
  Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            message.sender,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            message.content,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
