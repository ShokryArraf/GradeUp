import 'package:flutter/material.dart';
import 'package:grade_up/utilities/build_image.dart';
import 'package:grade_up/utilities/open_file.dart';
import 'package:url_launcher/url_launcher.dart';

bool isHebrew(String text) {
  final hebrewRegex = RegExp(r'[\u0590-\u05FF]'); // Hebrew Unicode range
  return hebrewRegex.hasMatch(text);
}

Widget buildContentCard(Map<String, dynamic> element) {
  String? textData = element['data'];
  String? fileName = element['filename'];

  bool useRTL = textData != null && isHebrew(textData);

  Widget buildTextWidget(String text, {TextStyle? style}) {
    return Directionality(
      textDirection: useRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Text(text, style: style),
    );
  }

  switch (element['type']) {
    case 'title':
      return ListTile(
        title: buildTextWidget(
          textData!,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            decoration: TextDecoration.underline,
          ),
        ),
      );
    case 'image':
      return buildImage(textData!);
    case 'text':
      return ListTile(title: buildTextWidget(textData!));
    case 'pdf':
      return ListTile(
        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
        title: buildTextWidget(fileName ?? 'שם קובץ לא זמין'),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => openFile(textData!),
        ),
      );
    case 'doc':
    case 'docx':
      return ListTile(
        leading: const Icon(Icons.description, color: Colors.blue),
        title: buildTextWidget(fileName!),
        trailing: IconButton(
          icon: const Icon(Icons.open_in_new),
          onPressed: () => openFile(textData!),
        ),
      );
    case 'link':
      final url = textData;
      if (url == null || url.isEmpty) {
        return buildTextWidget('קישור לא תקין',
            style: const TextStyle(color: Colors.red));
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
