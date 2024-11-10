// import 'package:flutter/material.dart';
// import 'package:grade_up/game/game_page.dart';
// import 'package:grade_up/utilities/build_game_button.dart';

// class GameOptionsPage extends StatelessWidget {
//   const GameOptionsPage({super.key});

//   void navigateToGamePage(BuildContext context, String lesson) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => GamePage(lesson: lesson),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Choose Your Game"),
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
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24.0),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Text(
//                   "Select a Game",
//                   style: TextStyle(
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.white,
//                   ),
//                 ),
//                 const SizedBox(height: 40),
//                 buildGameButton(
//                   context,
//                   "Play Math Game",
//                   Icons.calculate,
//                   Colors.greenAccent,
//                   () => navigateToGamePage(context, "math"),
//                 ),
//                 const SizedBox(height: 20),
//                 buildGameButton(
//                   context,
//                   "Play English Game",
//                   Icons.menu_book,
//                   Colors.amberAccent,
//                   () => navigateToGamePage(context, "english"),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:grade_up/game/game_page.dart';
import 'package:grade_up/game/leaderboard_page.dart';
import 'package:grade_up/utilities/build_game_button.dart';
import 'rewards_page.dart';

class GameOptionsPage extends StatelessWidget {
  const GameOptionsPage({super.key});

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
                buildGameButton(
                  context,
                  "Play Math Game",
                  Icons.calculate,
                  Colors.greenAccent,
                  () => navigateToGamePage(context, "math"),
                ),
                const SizedBox(height: 20),
                buildGameButton(
                  context,
                  "Play English Game",
                  Icons.menu_book,
                  Colors.amberAccent,
                  () => navigateToGamePage(context, "english"),
                ),
                const SizedBox(height: 40),
                // New "View Rewards" Button
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
