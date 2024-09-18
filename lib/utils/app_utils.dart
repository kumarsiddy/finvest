import 'package:flutter/material.dart';

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
}

Color hexToColor(String hexString) {
  hexString = hexString.replaceAll('#', '');
  return Color(int.parse('FF$hexString', radix: 16));
}
