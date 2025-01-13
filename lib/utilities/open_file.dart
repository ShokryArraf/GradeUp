// lib/utils/file_utils.dart
import 'package:url_launcher/url_launcher.dart';

Future<void> openFile(String url) async {
  final Uri uri = Uri.parse(url);

  if (await canLaunchUrl(uri)) {
    await launchUrl(uri,
        mode: LaunchMode
            .externalApplication); // Launch using the external application
  } else {
    throw 'לא הצלחנו לפתוח $url';
  }
}
