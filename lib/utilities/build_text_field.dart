import 'package:flutter/material.dart';

Widget buildTextField(String label, {void Function(String?)? onSaved}) {
  return TextFormField(
    decoration: InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey.shade200,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
    onSaved: onSaved,
    validator: (value) =>
        value == null || value.isEmpty ? 'בבקשה הכנס $label' : null,
  );
}
