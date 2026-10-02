import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.favorite,
          size: 18,
          color: const Color(0xFFFFB6D0),
        ),
        const SizedBox(width: 4),
        Text(
          'echo',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: const Color(0xFFFF9FC2),
          ),
        ),
      ],
    );
  }
}