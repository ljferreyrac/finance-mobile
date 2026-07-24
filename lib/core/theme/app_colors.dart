import 'package:flutter/material.dart';

/// Design token palette (Navy + Teal), the single source of truth for every
/// color in the app. To retheme, change values here only; never use raw hex
/// values elsewhere.
abstract final class AppColors {
  static const navy900 = Color(0xFF0B1F3A); // dark background, primary card surface
  static const navy800 = Color(0xFF0F2F5C); // elevated surfaces in dark mode
  static const navy600 = Color(0xFF1D4E89); // secondary actions, borders
  static const navy400 = Color(0xFF1D6FA8); // primary interactive (buttons, links)
  static const navy200 = Color(0xFF7BAFD4); // muted text on dark surfaces, icons
  static const navy100 = Color(0xFFB8CDE6); // subtle labels, disabled states
  static const navy50  = Color(0xFFE4EEF8); // light background tint, hover states

  static const teal400 = Color(0xFF1D9E75); // primary accent, CTAs, positive indicators
  static const teal200 = Color(0xFF7DCFC4); // muted accent, icons on dark
  static const teal100 = Color(0xFF9FE1CB); // light accent fills
  static const teal50  = Color(0xFFE0F5F1); // accent background tint, success chips

  static const income  = Color(0xFF1D9E75); // positive amounts, income transactions
  static const expense = Color(0xFFE24B4A); // negative amounts, expense transactions
  static const pending = Color(0xFFEF9F27); // pending transactions, warnings
  static const link    = Color(0xFF1D6FA8); // interactive text, links

  static const neutral900 = Color(0xFF2C2C2A); // primary text (light mode)
  static const neutral600 = Color(0xFF5F5E5A); // secondary text
  static const neutral400 = Color(0xFF888780); // placeholder, disabled text
  static const neutral200 = Color(0xFFD3D1C7); // borders, dividers
  static const neutral100 = Color(0xFFEBEBED); // surface backgrounds
  static const neutral50  = Color(0xFFF5F8FC); // page background (light mode)
}
