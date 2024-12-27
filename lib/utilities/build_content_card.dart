import 'package:flutter/material.dart';
import 'package:grade_up/utilities/build_image.dart';
import 'package:grade_up/utilities/open_file.dart';

Widget buildContentCard(Map<String, dynamic> element) {
  switch (element['type']) {
    case 'title':
      return ListTile(
        title: Text(
          element['data'],
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline),
        ),
      );
    case 'image': // Handle image type
      return buildImage(element['data']);
    case 'text':
      return ListTile(
        title: Text(element['data']),
      );
    case 'pdf': // Handle PDF type

      return ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: Text(element['filename'] ?? 'No filename available'),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => openFile(element['data']),
        ),
      );
    // Handle Word file type
    case 'doc':
    case 'docx':
      return ListTile(
        leading: const Icon(Icons.description, color: Colors.blue),
        title: Text(element['filename']),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => openFile(element['data']),
        ),
      );
    default:
      return const SizedBox.shrink();
  }
}
