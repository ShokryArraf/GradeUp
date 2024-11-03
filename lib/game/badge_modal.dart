import 'package:flutter/material.dart';

class BadgeModal extends StatelessWidget {
  final String badgeName;
  final String badgeDescription;

  const BadgeModal({
    super.key,
    required this.badgeName,
    required this.badgeDescription,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Congratulations!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Display badge icon or image here
          const Icon(Icons.star, size: 60, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            badgeName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            badgeDescription,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Close the modal
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
