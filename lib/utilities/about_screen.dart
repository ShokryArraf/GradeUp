import 'package:flutter/material.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('אודות האפליקציה'),
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
              'GradeUp: Interactive Learning Platform',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text('Version: 1.0.0'),
            SizedBox(height: 8),
            Text('© 2024 GradeUp, All Rights Reserved.'),
            SizedBox(height: 16),
            Text(
              'GradeUp is an innovative platform that fosters learning and teaching in dynamic environments.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            Text(
              'GradeUp היא פלטפורמה חדשנית המטפחת למידה והוראה בסביבות דינמיות.',
              style: TextStyle(fontSize: 16),
              textDirection: TextDirection.rtl,
            ),
          ],
        ),
      ),
    );
  }
}
