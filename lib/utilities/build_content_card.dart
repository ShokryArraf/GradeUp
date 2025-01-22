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
    case 'link': // Handle link type
      final url = element['data'];
      if (url == null || url.isEmpty) {
        return const Text(
          'Invalid URL',
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

// import 'package:flutter/material.dart';
// import 'package:grade_up/utilities/build_image.dart';
// import 'package:grade_up/utilities/open_file.dart';
// import 'package:url_launcher/url_launcher.dart';

// Widget buildContentCard(Map<String, dynamic> element) {
//   switch (element['type']) {
//     case 'title':
//       return ListTile(
//         title: Text(
//           element['data'],
//           style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               decoration: TextDecoration.underline),
//         ),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // Add your edit functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 // Add your delete functionality here
//               },
//             ),
//           ],
//         ),
//       );
//     case 'image': // Handle image type
//       return ListTile(
//         contentPadding: EdgeInsets.zero,
//         title: buildImage(element['data']),
//         trailing: IconButton(
//           icon: const Icon(Icons.delete),
//           onPressed: () {
//             // Add your delete functionality for image here
//           },
//         ),
//       );
//     case 'text':
//       return ListTile(
//         title: Text(element['data']),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // Add your edit functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 // Add your delete functionality here
//               },
//             ),
//           ],
//         ),
//       );
//     case 'pdf': // Handle PDF type
//       return ListTile(
//         leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
//         title: Text(element['filename'] ?? 'No filename available'),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // Add your edit functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 // Add your delete functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.open_in_new),
//               onPressed: () => openFile(element['data']),
//             ),
//           ],
//         ),
//       );
//     case 'doc':
//     case 'docx':
//       return ListTile(
//         leading: const Icon(Icons.description, color: Colors.blue),
//         title: Text(element['filename']),
//         trailing: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // Add your edit functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 // Add your delete functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.open_in_new),
//               onPressed: () => openFile(element['data']),
//             ),
//           ],
//         ),
//       );
//     case 'link': // Handle link type
//       final url = element['data'];
//       if (url == null || url.isEmpty) {
//         return const Text(
//           'Invalid URL',
//           style: TextStyle(color: Colors.red),
//         );
//       }
//       return GestureDetector(
//         onTap: () async {
//           final uri = Uri.parse(url);
//           if (await canLaunchUrl(uri)) {
//             await launchUrl(uri, mode: LaunchMode.externalApplication);
//           }
//         },
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Text(
//               url,
//               style: const TextStyle(
//                   color: Colors.blue, decoration: TextDecoration.underline),
//             ),
//             IconButton(
//               icon: const Icon(Icons.edit),
//               onPressed: () {
//                 // Add your edit functionality here
//               },
//             ),
//             IconButton(
//               icon: const Icon(Icons.delete),
//               onPressed: () {
//                 // Add your delete functionality here
//               },
//             ),
//           ],
//         ),
//       );
//     default:
//       return const SizedBox.shrink();
//   }
// }
