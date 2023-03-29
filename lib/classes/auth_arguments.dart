import 'package:flutter/material.dart';

import './helper.dart';

abstract class AuthArguments {
  static const double bottomPadding = 20.0;
  static const double circular = 20.0;
  static const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(circular),
    ),
  );

  static Widget authTextField({
    bool autofocus = false,
    required TextEditingController controller,
    required String textType,
    String label = "",
    bool obscureText = false,
    TextInputType textInputType = TextInputType.text,
  }) {
    if (label.isEmpty) {
      label = textType;
    }
    label = Helper.capitalize(label);
    return Column(
      children: [
        TextField(
          obscureText: obscureText,
          autofocus: autofocus,
          controller: controller,
          decoration: InputDecoration(
            hintText: "input your $textType..",
            border: outlineInputBorder,
          ),
          keyboardType: textInputType,
        ),
      ],
    );
  }

  static authFilledButton({
    required Function() onPressed,
    required Widget child,
  }) {
    return FilledButton(
      onPressed: onPressed,
      child: child,
    );
  }
}
