import 'package:flutter/material.dart';

ButtonStyle buttonStyle(BuildContext context) {
  return ButtonStyle(
      backgroundColor: MaterialStatePropertyAll<Color>(Colors.purple),
      foregroundColor: MaterialStateProperty.all<Color>(Colors.white));
}
