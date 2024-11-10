// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class LeaderboardPage extends StatefulWidget {
//   const LeaderboardPage({super.key});

//   @override
//   LeaderboardPageState createState() => LeaderboardPageState();
// }

// class LeaderboardPageState extends State<LeaderboardPage> {
//   List<Map<String, dynamic>> leaderboardData = [];
//
//
//   Future<void> fetchLeaderboardData() async {
//     try {
//       final List<Map<String, dynamic>> data = [];

//       // Query all users in the 'userprogress' collection
//       QuerySnapshot usersSnapshot =
//           await FirebaseFirestore.instance.collection('userprogress').get();

//       for (var userDoc in usersSnapshot.docs) {
//         final userId = userDoc.id;
//         int totalPoints = 0;

//         // Fetch all lessons for the user in the 'gameLesson' subcollection
//         QuerySnapshot lessonsSnapshot =
//             await userDoc.reference.collection('gameLesson').get();

//         // Add debug prints to check the lessons data
//         print('User: $userId, Lessons: ${lessonsSnapshot.docs.length}');

//         for (var lessonDoc in lessonsSnapshot.docs) {
//           final points = lessonDoc['points'];

//           // Check if points exist and are valid
//           if (points != null) {
//             print('Lesson Points for $userId: $points');
//             totalPoints += int.tryParse(points.toString()) ??
//                 0; // Convert points to int if needed
//           } else {
//             print('No points found for lesson: ${lessonDoc.id}');
//           }
//         }

//         // Add user data to the leaderboard list
//         data.add({
//           'userId': userId,
//           'totalPoints': totalPoints,
//         });
//       }

//       // Check data before sorting
//       print('Leaderboard data before sorting: $data');

//       // Sort users by total points in descending order and limit to top 10
//       data.sort((a, b) => b['totalPoints'].compareTo(a['totalPoints']));
//       setState(() {
//         leaderboardData = data.take(10).toList(); // Top 10 players
//         print('Leaderboard data after sorting: $leaderboardData');
//       });
//     } catch (e) {
//       print("Error fetching leaderboard data: $e");
//     }
//   }

//   @override
//   void initState() {
//     super.initState();
//     fetchLeaderboardData();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Leaderboard"),
//         flexibleSpace: Container(
//           decoration: const BoxDecoration(
//             gradient: LinearGradient(
//               colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
//               begin: Alignment.topLeft,
//               end: Alignment.bottomRight,
//             ),
//           ),
//         ),
//       ),
//       body: Container(
//         decoration: const BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//           ),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(24.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Top Players",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 20),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: leaderboardData.length,
//                   itemBuilder: (context, index) {
//                     final user = leaderboardData[index];
//                     final rank = index + 1;
//                     final userId = user['userId'];
//                     final points = user['totalPoints'];

//                     return Card(
//                       color: Colors.white.withOpacity(0.8),
//                       margin: const EdgeInsets.symmetric(vertical: 8.0),
//                       child: ListTile(
//                         leading: CircleAvatar(
//                           backgroundColor: Colors.blueAccent,
//                           child: Text(
//                             rank.toString(),
//                             style: const TextStyle(color: Colors.white),
//                           ),
//                         ),
//                         title: Text(
//                           "User: $userId", // Replace with a proper username if available
//                           style: const TextStyle(
//                             fontWeight: FontWeight.bold,
//                             fontSize: 18,
//                           ),
//                         ),
//                         subtitle: Text("Total Points: $points"),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

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

      // Query all users in the 'userprogress' collection
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('userprogress').get();

      for (var userDoc in usersSnapshot.docs) {
        final userId = userDoc.id;
        int totalPoints = 0;

        // Fetch all lessons for the user in the 'gameLesson' subcollection
        QuerySnapshot lessonsSnapshot =
            await userDoc.reference.collection('gameLesson').get();

        for (var lessonDoc in lessonsSnapshot.docs) {
          // Convert points to integer if it is stored as a string in Firestore
          final points = lessonDoc['points'];

          // If points is a string, convert it to an int. Otherwise, use it as is.
          totalPoints += points is String
              ? int.tryParse(points) ?? 0 // Convert string to int
              : points as int; // Handle if it's already an integer
        }

        // Add user data to the leaderboard list
        data.add({
          'userId': userId,
          'totalPoints': totalPoints,
        });
      }

      // Sort users by total points in descending order and limit to top 10
      data.sort((a, b) => b['totalPoints'].compareTo(a['totalPoints']));
      setState(() {
        leaderboardData = data.take(10).toList(); // Top 10 players
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
                          "User: $userId", // Replace with a proper username if available
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
