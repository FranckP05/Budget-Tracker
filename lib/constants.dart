// lib/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Gradients inspired by sudo_cash/ existing design
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF45EE67), Color(0xFF389F09)], // Login button style
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF0968E5), Color(0xFF091970)], // Wallet add button style
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient categoryGradient = LinearGradient(
    colors: [Color(0xFFFC4A1A), Color(0xFFF7B733)], // Category add button
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Base colors for text and backgrounds
  static const Color backgroundWhite = Colors.white;
  static const Color textBlack = Colors.black;

  // Default expense limit
  static const double defaultExpenseLimit = 10000;
}