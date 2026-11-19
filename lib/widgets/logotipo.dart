import 'package:flutter/material.dart';

class Logotipo extends StatelessWidget {
  const Logotipo({super.key, this.size = 130});
  final double size;
  @override
  Widget build(BuildContext context) => Center(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    ),
  );
}
