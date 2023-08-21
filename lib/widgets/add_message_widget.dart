import 'package:flutter/material.dart';

class AddMessageWidget extends StatefulWidget {
  Function(String) onPressed;
  AddMessageWidget({required this.onPressed, super.key});

  @override
  State<AddMessageWidget> createState() => _AddMessageWidgetState();
}

class _AddMessageWidgetState extends State<AddMessageWidget> {
  TextEditingController controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(border: Border.all()),
      child: SizedBox(
        height: 50,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(
                    hintText: 'add message to send!!',
                    border: OutlineInputBorder()),
                controller: controller,
                onChanged: (value) {
                  if (value.isNotEmpty) {
                    setState(() {});
                  }
                },
              ),
            ),
            IconButton(
                onPressed: () {
                  widget.onPressed(controller.text);
                  controller.text = '';
                },
                icon: Icon(
                  controller.text.isEmpty ? Icons.message : Icons.send,
                )),
          ],
        ),
      ),
    );
  }
}
