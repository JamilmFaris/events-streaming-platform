import 'package:flutter/material.dart';

import '../models/message.dart';

class MessageWidget extends StatelessWidget {
  MessageWidget({required this.message, super.key});
  Message message;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: ListTile(
        title: Text(message.content),
      ),
    );
  }
}
