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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: const Center(
        child: Text(
          '🎉 Congratulations!',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Badge icon with a circular background
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star,
              size: 60,
              color: Colors.amber,
            ),
          ),
          const SizedBox(height: 16),
          // Badge name with larger text
          Text(
            badgeName,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          // Badge description with subtle styling
          Text(
            badgeDescription,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
      actions: [
        Center(
          child: TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the modal
            },
            child: const Text(
              'Continue',
              style: TextStyle(fontSize: 16, color: Colors.blue),
            ),
          ),
        ),
      ],
    );
  }
}
