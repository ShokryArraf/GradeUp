import 'package:flutter/material.dart';

Widget buildGameButton(BuildContext context, String text, IconData icon,
    Color color, VoidCallback onPressed) {
  return ElevatedButton.icon(
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      elevation: 5,
      shadowColor: Colors.black54,
    ),
    icon: Icon(icon, size: 28, color: Colors.white),
    label: Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: Color.fromARGB(255, 254, 254, 253),
      ),
    ),
    onPressed: onPressed,
  );
}
