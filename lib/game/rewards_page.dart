import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/service/game_service.dart';

class RewardsPage extends StatefulWidget {
  final Student student;
  const RewardsPage({super.key, required this.student});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  final GameService _gameService = GameService();

  Map<String, int> lessonPoints = {};
  Map<String, String> lessonBadges = {};

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
  ];

  void loadLessonRewards(Student student) async {
    try {
      Map<String, Map<String, dynamic>> lessonRewards =
          await _gameService.fetchAllLessonRewards(student);

      setState(() {
        lessonPoints = lessonRewards['pointsData'] as Map<String, int>;
        lessonBadges = lessonRewards['badgesData'] as Map<String, String>;
      });
    } catch (_) {
      throw ErrorFetchingLessonsException;
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
    loadLessonRewards(widget.student);
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
                    color: Colors.white.withValues(alpha: 0.9),
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
                    color: Colors.white.withValues(alpha: 0.9),
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
