import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart'; // Adjust as needed

class GamePage extends StatelessWidget {
  final int points = 100; // This should be dynamically tracked in your app
  static final List<String> badges = ["Beginner", "Intermediate"];

  const GamePage({super.key}); // Example badges

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Game'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Your Points: $points',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              'Badges Collected:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              children:
                  badges.map((badge) => Chip(label: Text(badge))).toList(),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(quizRoute);
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text('Start Quiz Level'),
            ),
          ],
        ),
      ),
    );
  }
}
