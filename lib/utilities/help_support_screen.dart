import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Help & Support'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Frequently Asked Questions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '1. How do I reset my password?\nGo to Settings > Privacy and Security > Reset Password.',
            ),
            SizedBox(height: 16),
            Text(
              '2. How can I contact support?\nSend an email to support@gradeup.com.',
            ),
            SizedBox(height: 16),
            Text(
              '3. Where can I find tutorials?\nVisit the Tutorials section in the app menu.',
            ),
          ],
        ),
      ),
    );
  }
}
