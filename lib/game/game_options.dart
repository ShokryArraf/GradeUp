import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_up/game/game_page.dart';
import 'package:grade_up/game/leaderboard_page.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/utilities/build_game_button.dart';
import 'rewards_page.dart';

class GameOptionsPage extends StatefulWidget {
  const GameOptionsPage({super.key});

  @override
  GameOptionsPageState createState() => GameOptionsPageState();
}

class GameOptionsPageState extends State<GameOptionsPage> {
  List<String> enrolledLessons = [];

  @override
  void initState() {
    super.initState();
    fetchEnrolledLessons();
  }

  Future<void> fetchEnrolledLessons() async {
    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
      if (userId.isNotEmpty) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('students')
            .doc(userId)
            .get();

        setState(() {
          enrolledLessons = List<String>.from(userDoc['enrolledLessons'] ?? []);
        });
      }
    } catch (_) {
      throw ErrorFetchingEnrolledLessonsException;
    }
  }

  void navigateToGamePage(BuildContext context, String lesson) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GamePage(lesson: lesson),
      ),
    );
  }

  void navigateToRewardsPage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RewardsPage(),
      ),
    );
  }

  IconData getLessonIcon(String lesson) {
    switch (lesson.toLowerCase()) {
      case 'math':
        return Icons.calculate;
      case 'english':
        return Icons.menu_book;
      case 'hebrew':
        return Icons.language;
      case 'geography':
        return Icons.public;
      case 'biology':
        return Icons.biotech;
      case 'chemistry':
        return Icons.science;
      default:
        return Icons.games; // Default icon if no match
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Choose Your Game"),
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
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Select a Game",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),
                // Dynamically generate game buttons based on enrolled lessons
                for (String lesson in enrolledLessons) ...[
                  buildGameButton(
                    context,
                    "Play $lesson Game",
                    getLessonIcon(lesson), // Adjust icon as needed per lesson
                    Colors.greenAccent,
                    () => navigateToGamePage(context, lesson.toLowerCase()),
                  ),
                  const SizedBox(height: 20),
                ],
                const SizedBox(height: 40),
                buildGameButton(
                  context,
                  "View Rewards",
                  Icons.emoji_events,
                  Colors.purpleAccent,
                  () => navigateToRewardsPage(context),
                ),
                const SizedBox(height: 40),
                buildGameButton(
                  context,
                  "View Leaderboard",
                  Icons.leaderboard,
                  Colors.purpleAccent,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const LeaderboardPage(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
