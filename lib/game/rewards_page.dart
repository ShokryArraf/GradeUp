// // rewards_page.dart
// import 'package:flutter/material.dart';

// class RewardsPage extends StatelessWidget {
//   const RewardsPage({super.key});

//   @override
//   Widget build(BuildContext context) {
//     // This is a placeholder; replace with your actual data retrieval logic
//     final List<String> badges = ["Badge 1", "Badge 2", "Badge 3"];
//     const int points = 120;

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Rewards"),
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
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Your Badges",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               ...badges.map((badge) => Text(
//                     badge,
//                     style: const TextStyle(fontSize: 18, color: Colors.white),
//                   )),
//               const SizedBox(height: 40),
//               const Text(
//                 "Total Points: $points",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class RewardsPage extends StatefulWidget {
//   const RewardsPage({super.key});

//   @override
//   // ignore: library_private_types_in_public_api
//   _RewardsPageState createState() => _RewardsPageState();
// }

// class _RewardsPageState extends State<RewardsPage> {
//   int points = 0;
//   String badge = "No Badge";
//   String? userId = FirebaseAuth.instance.currentUser?.uid;

//   // Retrieve points and determine badge based on Firestore data
//   Future<void> fetchPointsAndBadge(String userId, String lesson) async {
//     try {
//       // Reference to the specific document in Firestore
//       DocumentSnapshot snapshot = await FirebaseFirestore.instance
//           .collection('userprogress')
//           .doc(userId)
//           .collection('gameLesson')
//           .doc(lesson)
//           .get();

//       if (snapshot.exists && snapshot.data() != null) {
//         setState(() {
//           points = snapshot['points'] ?? 0;
//           badge = getBadge(points);
//         });
//       } else {
//         print("No points data found for lesson $lesson");
//       }
//     } catch (e) {
//       print("Error fetching points: $e");
//     }
//   }
//
// // Determine the badge based on points
// String getBadge(int points) {
//   if (points >= 180) {
//     return "Champion Badge";
//   } else if (points >= 300) {
//     return "Legend Badge";
//   } else if (points >= 250) {
//     return "Elite Badge";
//   } else if (points >= 220) {
//     return "Master Badge";
//   } else if (points >= 200) {
//     return "Expert Badge";
//   } else if (points >= 170) {
//     return "Advanced Badge";
//   } else if (points >= 130) {
//     return "Intermediate Badge";
//   } else if (points >= 100) {
//     return "Apprentice Badge";
//   } else if (points >= 50) {
//     return "Beginner Badge";
//   } else {
//     return "No Badge";
//   }
// }
//
//   @override
//   void initState() {
//     super.initState();
//     // Replace 'userId' and 'lesson' with actual user ID and lesson name
//     fetchPointsAndBadge(
//         "userId", "math"); // For example, fetch points for Math lesson
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Rewards"),
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
//             mainAxisAlignment: MainAxisAlignment.start,
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const Text(
//                 "Your Badge",
//                 style: TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//               const SizedBox(height: 16),
//               Text(
//                 badge,
//                 style: const TextStyle(
//                   fontSize: 28,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.yellow,
//                 ),
//               ),
//               const SizedBox(height: 40),
//               Text(
//                 "Total Points: $points",
//                 style: const TextStyle(
//                   fontSize: 24,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key});

  @override
  RewardsPageState createState() => RewardsPageState();
}

class RewardsPageState extends State<RewardsPage> {
  Map<String, int> lessonPoints = {};
  Map<String, String> lessonBadges = {};
  String? userId = FirebaseAuth.instance.currentUser?.uid;

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
    } catch (e) {
      print("Error fetching lessons: $e");
    }
  }

  // Determine the badge based on points
  String getBadge(int points) {
    if (points >= 180) {
      return "Champion Badge";
    } else if (points >= 300) {
      return "Legend Badge";
    } else if (points >= 250) {
      return "Elite Badge";
    } else if (points >= 220) {
      return "Master Badge";
    } else if (points >= 200) {
      return "Expert Badge";
    } else if (points >= 170) {
      return "Advanced Badge";
    } else if (points >= 130) {
      return "Intermediate Badge";
    } else if (points >= 100) {
      return "Apprentice Badge";
    } else if (points >= 50) {
      return "Beginner Badge";
    } else {
      return "No Badge";
    }
  }

  @override
  void initState() {
    super.initState();
    // Replace 'userId' with the actual user ID
    fetchAllLessonRewards(userId!);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Rewards"),
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
                "Your Rewards",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: lessonPoints.keys.length,
                  itemBuilder: (context, index) {
                    String lesson = lessonPoints.keys.elementAt(index);
                    int points = lessonPoints[lesson] ?? 0;
                    String badge = lessonBadges[lesson] ?? "No Badge";
                    return Card(
                      color: Colors.white.withOpacity(0.8),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: const Icon(Icons.star, color: Colors.amber),
                        title: Text(
                          lesson,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text("Points: $points\nBadge: $badge"),
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
