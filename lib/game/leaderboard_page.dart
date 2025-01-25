import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/service/game_service.dart';

class LeaderboardPage extends StatefulWidget {
  final Student student;
  const LeaderboardPage({super.key, required this.student});

  @override
  LeaderboardPageState createState() => LeaderboardPageState();
}

class LeaderboardPageState extends State<LeaderboardPage> {
  final GameService _gameService = GameService();
  List<Map<String, dynamic>> leaderboardData = [];

  void loadLeaderboard() async {
    try {
      List<Map<String, dynamic>> leaderboardData =
          await _gameService.fetchLeaderboardData(widget.student);
      setState(() {
        this.leaderboardData = leaderboardData;
      });
    } catch (_) {
      throw ErrorFetchingLeaderboardDataException;
    }
  }

  @override
  void initState() {
    super.initState();
    loadLeaderboard();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "לוח מתחרים",
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
                "מתחרים מובילים",
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
                        color: Colors.white.withValues(alpha: 0.9),
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
                          'סה"כ נקודות :$points',
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
