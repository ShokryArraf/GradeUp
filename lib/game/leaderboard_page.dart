import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

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

      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('userprogress').get();
      if (usersSnapshot.docs.isEmpty) {
        throw NoDocumentsFoundException;
      }

      for (var userDoc in usersSnapshot.docs) {
        //final userId = userDoc.id;
        int totalPoints = 0;

        try {
          QuerySnapshot lessonsSnapshot =
              await userDoc.reference.collection('gameLesson').get();
          if (lessonsSnapshot.docs.isEmpty) {
            continue;
          }
          final name = lessonsSnapshot.docs[0]['name'] ??
              'Unknown User'; // Fetch the user's name

          for (var lessonDoc in lessonsSnapshot.docs) {
            final points = lessonDoc['points'];
            totalPoints +=
                points is String ? int.tryParse(points) ?? 0 : points as int;
          }

          data.add({
            'name': name,
            'totalPoints': totalPoints,
          });
        } catch (e) {
          continue;
        }
      }

      data.sort((a, b) => b['totalPoints'].compareTo(a['totalPoints']));
      setState(() {
        leaderboardData = data.take(10).toList();
      });
    } catch (e) {
      throw ErrorFetchingLeaderboardDataException;
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
        title: const Text(
          "Leaderboard",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Top Players",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: leaderboardData.length,
                  itemBuilder: (context, index) {
                    final user = leaderboardData[index];
                    final rank = index + 1;
                    final studentName = user['name'];
                    final points = user['totalPoints'];

                    return Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 22,
                          backgroundColor: rank == 1
                              ? Colors.amber
                              : (rank == 2 ? Colors.grey : Colors.brown),
                          child: Text(
                            rank.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        title: Text(
                          "$studentName",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF333333),
                          ),
                        ),
                        subtitle: Text(
                          "Total Points: $points",
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF777777),
                          ),
                        ),
                        trailing: Icon(
                          Icons.star,
                          color: rank == 1
                              ? Colors.amber
                              : (rank == 2 ? Colors.grey : Colors.brown),
                          size: 28,
                        ),
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
