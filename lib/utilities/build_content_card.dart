import 'package:flutter/material.dart';
import 'package:grade_up/utilities/build_image.dart';
import 'package:grade_up/utilities/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

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
        title: Text(element['filename'] ?? 'שם קובץ לא זמין'),
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
    case 'link': // Handle link type
      final url = element['data'];
      if (url == null || url.isEmpty) {
        return const Text(
          'קישור לא תקין',
          style: TextStyle(color: Colors.red),
        );
      }
      return GestureDetector(
        onTap: () async {
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        },
        child: Text(
          url,
          style: const TextStyle(
              color: Colors.blue, decoration: TextDecoration.underline),
        ),
      );
    default:
      return const SizedBox.shrink();
  }
}
