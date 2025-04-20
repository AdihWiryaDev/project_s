import 'package:flutter/material.dart';

class ButtonHomeStyle extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const ButtonHomeStyle({
    super.key,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28),
          side: const BorderSide(color: Colors.black, width: 2),
        ),
      ),
      onPressed: onPressed,
      child: Row(
        children: [
          const Icon(Icons.android, size: 60, color: Colors.black),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
