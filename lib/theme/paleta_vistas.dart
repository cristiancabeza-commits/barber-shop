import 'package:flutter/material.dart';

Color colorVista(
  BuildContext context,
  int original, {
  bool sobreColor = false,
}) {
  if (Theme.of(context).brightness == Brightness.dark) return Color(original);
  if (sobreColor && original == 0xFFFFFFFF) return Colors.white;
  return Color(switch (original) {
    0xFF0B0C0E => 0xFFF6F5F2,
    0xFF16181D || 0xFF15181D || 0xFF0F1115 => 0xFFFFFFFF,
    0xFF21242C || 0xFF23262D || 0xFF1A1D24 => 0xFFECEAE5,
    0xFF1D1C16 => 0xFFF5EBCF,
    0xFF2C2F36 => 0xFFD3D0C9,
    0xFFFFFFFF => 0xFF202126,
    0xFF6B7280 => 0xFF59606C,
    0xFF9CA3AF => 0xFF505762,
    0xFFD4AF37 => 0xFF84620A,
    0xFF10B981 || 0xFF00BE9C => 0xFF007D5B,
    0xFFF59E0B => 0xFF976009,
    _ => original,
  });
}
