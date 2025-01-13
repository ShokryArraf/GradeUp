import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class DownloadTemplate extends StatelessWidget {
  const DownloadTemplate({super.key});

  Future<void> downloadTemplate() async {
    try {
      // Define the CSV content
      const csvContent = '''
lesson,grade,Level,questionText,correctAnswer,option1,option2,option3,option4
math,7,1,What is 2+2?,4,4,3,5,2
english,2,2,What is the synonym of 'happy'?,joyful,joyful,sad,angry,tired
chimestry,3,3,What is H2O?,Water,Water,Air,Fire,Earth
''';

      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final filePath = '${directory.path}/template.csv';

      // Write the CSV content to a file
      final file = File(filePath);
      await file.writeAsString(csvContent);

      // Open the file to prompt download or open with a compatible app
      await OpenFile.open(filePath);
    } catch (e) {
      debugPrint(':שגיאה בהורדת טמפלט $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: downloadTemplate,
      icon: const Icon(Icons.download),
      label: const Text("CSV הורדת טמפלט"),
    );
  }
}
