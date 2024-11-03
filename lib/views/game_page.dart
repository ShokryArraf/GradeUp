// import 'package:flutter/material.dart';
// import 'package:grade_up/constants/routes.dart'; // Adjust as needed

// class GamePage extends StatelessWidget {
//   final int points = 100; // This should be dynamically tracked in your app
//   static final List<String> badges = ["Beginner", "Intermediate"];

//   const GamePage({super.key}); // Example badges

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Learning Game'),
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
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Text(
//               'Your Points: $points',
//               style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),
//             const Text(
//               'Badges Collected:',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
//             ),
//             const SizedBox(height: 10),
//             Wrap(
//               spacing: 10,
//               children:
//                   badges.map((badge) => Chip(label: Text(badge))).toList(),
//             ),
//             const SizedBox(height: 30),
//             ElevatedButton(
//               onPressed: () {
//                 Navigator.of(context).pushNamed(quizRoute);
//               },
//               style: ElevatedButton.styleFrom(
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                 textStyle: const TextStyle(fontSize: 18),
//               ),
//               child: const Text('Start Quiz Level'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// class GamePage extends StatefulWidget {
//   const GamePage({super.key});

//   @override
//   _GamePageState createState() => _GamePageState();
// }

// class _GamePageState extends State<GamePage> {
//   // Track positions of the student and opponent cars
//   double studentCarPosition = 0.0;
//   double opponentCarPosition = 0.0;

//   // Define distances for moves
//   static const double correctAnswerDistance =
//       0.15; // Student's advancement for a correct answer
//   static const double incorrectAnswerDistance =
//       0.05; // Both cars' advancement for an incorrect answer
//   static const double finishLine = 1.0; // Finish line distance

//   // Sample question
//   final String question = "What is 5 + 3?";
//   final List<String> answers = ["6", "7", "8", "9"];
//   final String correctAnswer = "8";

//   void checkAnswer(String answer) {
//     setState(() {
//       if (answer == correctAnswer) {
//         // Correct answer - student car moves further
//         studentCarPosition += correctAnswerDistance;
//       } else {
//         // Incorrect answer - both cars move a little
//         studentCarPosition += incorrectAnswerDistance;
//         opponentCarPosition += incorrectAnswerDistance +
//             0.03; // Opponent moves a bit further on incorrect
//       }

//       // Check for win/loss
//       if (studentCarPosition >= finishLine) {
//         showResultDialog("You Win!");
//       } else if (opponentCarPosition >= finishLine) {
//         showResultDialog("You Lost!");
//       }
//     });
//   }

//   void showResultDialog(String result) {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: Text(result),
//         content:
//             const Text("Great effort! Try again or advance to the next level."),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               resetGame();
//             },
//             child: const Text('Play Again'),
//           ),
//         ],
//       ),
//     );
//   }

//   void resetGame() {
//     setState(() {
//       studentCarPosition = 0.0;
//       opponentCarPosition = 0.0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Car Racing Quiz Game"),
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
//       body: Column(
//         children: [
//           // Racing track representation
//           Expanded(
//             child: Stack(
//               children: [
//                 // Student's car with animation
//                 AnimatedPositioned(
//                   duration: const Duration(milliseconds: 500),
//                   left: MediaQuery.of(context).size.width * studentCarPosition,
//                   bottom: 100,
//                   child: const Icon(Icons.directions_car,
//                       color: Colors.blue, size: 50),
//                 ),
//                 // Opponent's car with animation
//                 AnimatedPositioned(
//                   duration: const Duration(milliseconds: 500),
//                   left: MediaQuery.of(context).size.width * opponentCarPosition,
//                   bottom: 200,
//                   child: const Icon(Icons.directions_car,
//                       color: Colors.red, size: 50),
//                 ),
//               ],
//             ),
//           ),
//           // Question and answers section
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 Text(
//                   question,
//                   style: const TextStyle(
//                       fontSize: 20, fontWeight: FontWeight.bold),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 20),
//                 // Display answer buttons
//                 ...answers.map((answer) => ElevatedButton(
//                       onPressed: () => checkAnswer(answer),
//                       child: Text(answer),
//                     )),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  _GamePageState createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  double studentCarPosition = 0.0;
  double opponentCarPosition = 0.0;

  static const double correctAnswerDistance = 0.15;
  static const double incorrectAnswerDistance = 0.05;
  static const double finishLine = 1.0;

  final String question = "What is 5 + 3?";
  final List<String> answers = ["6", "7", "8", "9"];
  final String correctAnswer = "8";

  void checkAnswer(String answer) {
    setState(() {
      if (answer == correctAnswer) {
        studentCarPosition += correctAnswerDistance;
      } else {
        studentCarPosition += incorrectAnswerDistance;
        opponentCarPosition += incorrectAnswerDistance + 0.03;
      }

      if (studentCarPosition >= finishLine) {
        showResultDialog("You Win!");
      } else if (opponentCarPosition >= finishLine) {
        showResultDialog("You Lost!");
      }
    });
  }

  void showResultDialog(String result) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(result),
        content:
            const Text("Great effort! Try again or advance to the next level."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetGame();
            },
            child: const Text('Play Again'),
          ),
        ],
      ),
    );
  }

  void resetGame() {
    setState(() {
      studentCarPosition = 0.0;
      opponentCarPosition = 0.0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Car Racing Quiz Game"),
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
      body: Stack(
        children: [
          // Background with a road or race track
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(
                    "images\road_background.png"), // Road background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    // Student's car with animation
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: MediaQuery.of(context).size.width *
                          studentCarPosition,
                      bottom: 100,
                      child: const Icon(Icons.directions_car,
                          color: Colors.blue, size: 50),
                    ),
                    // Opponent's car with animation
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: MediaQuery.of(context).size.width *
                          opponentCarPosition,
                      bottom: 200,
                      child: const Icon(Icons.directions_car,
                          color: Colors.red, size: 50),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      question,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 59, 51, 51),
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    ...answers.map((answer) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange[400],
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () => checkAnswer(answer),
                            child: Text(answer),
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
