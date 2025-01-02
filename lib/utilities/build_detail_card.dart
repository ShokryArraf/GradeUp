import 'package:flutter/material.dart';

Widget buildDetailCard(
    String title, String value, IconData icon, Color iconColor) {
  return Card(
    elevation: 5,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      leading: Icon(icon, color: iconColor, size: 30),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
      subtitle: Text(value,
          style: TextStyle(fontSize: 16, color: Colors.grey.shade700)),
    ),
  );
}
