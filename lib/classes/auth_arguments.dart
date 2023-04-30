import 'package:events_streaming_platform/design/styles.dart';
import 'package:flutter/material.dart';

import './helper.dart';

abstract class AuthArguments {
  static const Size accountImageMaxSize = Size(128.0, 128.0);
  static const double appbarPadding = 8.0;
  static const double bottomPadding = 8.0;
  static const double circular = 20.0;
  static const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.all(
      Radius.circular(circular),
    ),
  );

  static Widget authTextField(
      {bool autofocus = false,
      required TextEditingController controller,
      required String textType,
      String label = "",
      bool obscureText = false,
      TextInputType textInputType = TextInputType.text,
      TextInputAction? textInputAction}) {
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
            hintText: "input your $textType",
            border: outlineInputBorder,
            hintStyle: Styles.hintStyle,
          ),
          keyboardType: textInputType,
          textInputAction: textInputAction,
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
