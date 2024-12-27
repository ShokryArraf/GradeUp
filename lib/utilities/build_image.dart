// New helper method to build images dynamically based on platform
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

Widget buildImage(String url) {
  if (kIsWeb) {
    // For web: Use Image.network with loading and error handling
    return Image.network(
      url,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, color: Colors.red, size: 100);
      },
      fit: BoxFit.cover,
    );
  } else {
    // For mobile: Use the same approach
    return Image.network(
      url,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(child: CircularProgressIndicator());
      },
      errorBuilder: (context, error, stackTrace) {
        return const Icon(Icons.error, color: Colors.red, size: 100);
      },
      fit: BoxFit.cover,
    );
  }
}
