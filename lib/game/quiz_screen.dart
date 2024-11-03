import 'package:flutter/material.dart';
import 'package:grade_up/game/badge_modal.dart';

class QuizScreen extends StatelessWidget {
  static const String question = "What is 2 + 2?";
  static const List<String> answers = ["3", "4", "5", "6"];
  static const String correctAnswer = "4";
  //static FirestoreService firestoreService = FirestoreService();

  const QuizScreen({super.key});

  void checkAnswer(BuildContext context, String answer) {
    if (answer == correctAnswer) {
      showDialog(
        context: context,
        builder: (_) => const BadgeModal(
          badgeName: 'Math Whiz',
          badgeDescription: 'Awarded for answering the math quiz correctly!',
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('Try Again'),
          content: const Text('Keep learning!'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Try Again'),
            ),
          ],
        ),
      );
    }
  }

  // void checkAnswer(BuildContext context, String answer) async {
  //   if (answer == correctAnswer) {
  //     // Save game progress to Firestore
  //     await firestoreService.saveGameProgress(100, 'Math Whiz');

  //     // Show the badge modal
  //     showDialog(
  //       // ignore: use_build_context_synchronously
  //       context: context,
  //       builder: (_) => const BadgeModal(
  //         badgeName: 'Math Whiz',
  //         badgeDescription: 'Awarded for answering the math quiz correctly!',
  //       ),
  //     );
  //   } else {
  //     showDialog(
  //       context: context,
  //       builder: (_) => AlertDialog(
  //         title: const Text('Try Again'),
  //         content: const Text('Keep learning!'),
  //         actions: [
  //           TextButton(
  //             onPressed: () => Navigator.pop(context),
  //             child: const Text('Try Again'),
  //           ),
  //         ],
  //       ),
  //     );
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Level')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              question,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ...answers.map((answer) => ElevatedButton(
                  onPressed: () => checkAnswer(context, answer),
                  child: Text(answer),
                )),
          ],
        ),
      ),
    );
  }
}
