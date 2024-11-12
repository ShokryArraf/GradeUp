import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  Map<String, int> lessonPoints = {};
  Map<String, String> lessonBadges = {};
  String? userId = FirebaseAuth.instance.currentUser?.uid;

  // Mock badge data for upcoming rewards
  final List<Map<String, dynamic>> upcomingBadges = [
    {
      "badge": "images/beginner_badge.png",
      "name": "Beginner Badge",
      "points": 50
    },
    {
      "badge": "images/apprentice_badge.png",
      "name": "Apprentice Badge",
      "points": 150
    },
    {
      "badge": "images/intermediate_badge.png",
      "name": "Intermediate Badge",
      "points": 200
    },
    {
      "badge": "images/advanced_badge.png",
      "name": "Advanced Badge",
      "points": 250
    },
    {
      "badge": "images/champion_badge.png",
      "name": "Champion Badge",
      "points": 300
    },
    {"badge": "images/expert_badge.png", "name": "Expert Badge", "points": 350},
    {"badge": "images/master_badge.png", "name": "Master Badge", "points": 600},
    {"badge": "images/elite_badge.png", "name": "Elite Badge", "points": 850},
    {
      "badge": "images/legend_badge.png",
      "name": "Legend Badge",
      "points": 1300
    },

    // Add more badges here as needed
  ];

  // Fetch points and badges for all lessons in the 'gameLesson' subcollection
  Future<void> fetchAllLessonRewards(String userId) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('userprogress')
          .doc(userId)
          .collection('gameLesson')
          .get();

      Map<String, int> pointsData = {};
      Map<String, String> badgesData = {};

      for (var doc in snapshot.docs) {
        String lesson = doc.id;
        int points = doc['points'] ?? 0;
        String badge = getBadge(points);

        pointsData[lesson] = points;
        badgesData[lesson] = badge;
      }

      setState(() {
        lessonPoints = pointsData;
        lessonBadges = badgesData;
      });
    } catch (_) {
      throw ErrorFetchingLessonsException;
    }
  }

  // Determine badge based on points
  String getBadge(int points) {
    if (points >= 1300) {
      return "images/legend_badge.png";
    } else if (points >= 850) {
      return "images/elite_badge.png";
    } else if (points >= 600) {
      return "images/master_badge.png";
    } else if (points >= 350) {
      return "images/expert_badge.png";
    } else if (points >= 300) {
      return "images/champion_badge.png";
    } else if (points >= 250) {
      return "images/advanced_badge.png";
    } else if (points >= 200) {
      return "images/intermediate_badge.png";
    } else if (points >= 150) {
      return "images/apprentice_badge.png";
    } else if (points >= 50) {
      return "images/beginner_badge.png";
    } else {
      return "images/no_badge.png"; // Default "No Badge" image
    }
  }

  // Filter upcoming badges based on minimum points
  List<Map<String, dynamic>> getFilteredUpcomingBadges() {
    int minPoints = lessonPoints.isNotEmpty
        ? lessonPoints.values.reduce((a, b) => a < b ? a : b)
        : 0;
    return upcomingBadges
        .where((badge) => badge["points"] > minPoints)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    if (userId != null) fetchAllLessonRewards(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student's Rewards"),
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Current Rewards",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Display Current Rewards
              GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 3 / 4,
                ),
                itemCount: lessonPoints.length,
                itemBuilder: (context, index) {
                  String lesson = lessonPoints.keys.elementAt(index);
                  int points = lessonPoints[lesson] ?? 0;
                  String badge = lessonBadges[lesson] ?? "images/no_badge.png";

                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            badge,
                            width: 100,
                            height: 100,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            lesson,
                            style: const TextStyle(fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            "Points: $points",
                            style: const TextStyle(color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Upcoming Rewards",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              // Display Upcoming Rewards
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: getFilteredUpcomingBadges().length,
                itemBuilder: (context, index) {
                  final badge = getFilteredUpcomingBadges()[index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading: Image.asset(
                        badge["badge"],
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                      ),
                      title: Text(
                        badge["name"],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      subtitle: Text("Points: ${badge["points"]}"),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
