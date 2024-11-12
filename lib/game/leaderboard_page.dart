import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> leaderboardData = [];

  Future<void> fetchLeaderboardData() async {
    try {
      final List<Map<String, dynamic>> data = [];

      // Fetch all user documents in 'userprogress'
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('userprogress').get();
      print("Number of documents retrieved: ${usersSnapshot.docs.length}");

      if (usersSnapshot.docs.isEmpty) {
        print("No documents found in 'userprogress' collection.");
        return;
      }

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        int totalPoints = 0;

        try {
          // Check if 'gameLesson' exists for this user, skip if it doesn’t
          QuerySnapshot lessonsSnapshot =
              await userDoc.reference.collection('gameLesson').get();
          if (lessonsSnapshot.docs.isEmpty) {
            print("No 'gameLesson' data for user $userId, skipping.");
            continue;
          }

          for (var lessonDoc in lessonsSnapshot.docs) {
            final points = lessonDoc['points'];

            // Convert points to integer if stored as a string in Firestore
            totalPoints +=
                points is String ? int.tryParse(points) ?? 0 : points as int;
          }

          // Add user data to the leaderboard list
          data.add({
            'userId': userId,
            'totalPoints': totalPoints,
          });
        } catch (e) {
          print("Error processing user $userId: $e");
          continue;
        }
      }

      // Sort by points in descending order and display the top 10 players
      data.sort((a, b) => b['totalPoints'].compareTo(a['totalPoints']));
      setState(() {
        leaderboardData = data.take(10).toList();
        print("Leaderboard data after sorting: $leaderboardData");
      });
    } catch (e) {
      print("Error fetching leaderboard data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Leaderboard"),
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
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Top Players",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardData.length,
                  itemBuilder: (context, index) {
                    final user = leaderboardData[index];
                    final rank = index + 1;
                    final userId = user['userId'];
                    final points = user['totalPoints'];

                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: Colors.blueAccent,
                          child: Text(
                            rank.toString(),
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                        title: Text(
                          "User: $userId",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text("Total Points: $points"),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
