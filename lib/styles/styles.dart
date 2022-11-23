import 'package:flutter/material.dart';

class TextStyles {
  static const TextStyle title =
  TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
  static const TextStyle subtitle = TextStyle(
      fontSize: 12, color: AppColors.primarys, fontWeight: FontWeight.bold);

  static const TextStyle bigText = TextStyle(
      fontSize: 32);
  static const TextStyle bigTextBold = TextStyle(
      fontSize: 32, fontWeight: FontWeight.bold);

  static const TextStyle label = TextStyle(
      fontSize: 16, color:Colors.black);
}

class AppColors {
  static const Color primarys = Color(0xFF4D57C8);
  static const Color purplelow = Color(0xFF92A3FD);
  static const Color whites = Color(0x00ffffff);
}