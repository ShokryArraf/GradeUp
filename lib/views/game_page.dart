// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:grade_up/service/game_service.dart';

// class GamePage extends StatefulWidget {
//   final String lesson;

//   const GamePage({super.key, required this.lesson});

//   @override
//   GamePageState createState() => GamePageState();
// }

// class GamePageState extends State<GamePage> {
//   double studentCarPosition = 0.0;
//   double opponentCarPosition = 0.0;
//   int currentQuestionIndex = 0; // Track the current question index
//   final GameService _gameService = GameService();

//   static const double correctAnswerDistance = 0.15;
//   static const double incorrectAnswerDistance = 0.05;
//   static const double finishLine = 1.0;

//   String question = '';
//   List<String> answers = [];
//   String correctAnswer = '';
//   String? userId = FirebaseAuth.instance.currentUser?.uid;

//   @override
//   void initState() {
//     super.initState();
//     loadQuestion();
//   }

//   Future<void> loadQuestion() async {
//     // Fetch questions from Firestore for the current lesson (e.g., 'math')
//     final questions = await _gameService.fetchQuestions(widget.lesson);
//     if (questions.isNotEmpty) {
//       setState(() {
//         question = questions[0]['questionText'];
//         answers = List<String>.from(questions[0]['answerOptions']);
//         correctAnswer = questions[0]['correctAnswer'];
//       });
//     } else {
//       print('questions are empty!');
//     }
//   }

//   void checkAnswer(String answer) {
//     setState(() {
//       if (answer == correctAnswer) {
//         studentCarPosition += correctAnswerDistance;
//         opponentCarPosition += incorrectAnswerDistance + 0.02;
//       } else {
//         studentCarPosition += incorrectAnswerDistance;
//         opponentCarPosition += incorrectAnswerDistance + 0.04;
//       }

//       if (studentCarPosition >= finishLine) {
//         showResultDialog("You Win!");
//         _gameService.updateUserProgress(userId!, {
//           'points': FieldValue.increment(10),
//           'badges': FieldValue.arrayUnion(['Winner']),
//           'currentLesson': 'math',
//           'currentQuestionID': 'next_question_id', // Set as needed
//         });
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

//   void loadNextQuestion() {
//     setState(() {
//       studentCarPosition = 0.0;
//       opponentCarPosition = 0.0;

//       if (currentQuestionIndex < _gameService.questions.length - 1) {
//         currentQuestionIndex++;
//       } else {
//         currentQuestionIndex = 0; // Reset to the first question if at the end
//       }

//       // Load the question data at the new index
//       question = _gameService.questions[currentQuestionIndex]['questionText'];
//       answers = List<String>.from(
//           _gameService.questions[currentQuestionIndex]['answerOptions']);
//       correctAnswer =
//           _gameService.questions[currentQuestionIndex]['correctAnswer'];
//     });
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
//       body: Stack(
//         children: [
//           // Background with a road or race track
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/road_background.png'),
//                 fit: BoxFit.fitWidth,
//                 alignment: Alignment.topCenter,
//               ),
//             ),
//           ),
//           Column(
//             children: [
//               Expanded(
//                 child: Stack(
//                   children: [
//                     // Student's car with animation
//                     AnimatedPositioned(
//                       duration: const Duration(milliseconds: 500),
//                       left: MediaQuery.of(context).size.width *
//                           studentCarPosition,
//                       bottom: 115,
//                       child: const Icon(Icons.directions_car,
//                           color: Colors.blue, size: 50),
//                     ),
//                     // Opponent's car with animation
//                     AnimatedPositioned(
//                       duration: const Duration(milliseconds: 500),
//                       left: MediaQuery.of(context).size.width *
//                           opponentCarPosition,
//                       bottom: 180,
//                       child: const Icon(Icons.directions_car,
//                           color: Colors.red, size: 50),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       question,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 59, 51, 51),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),
//                     ...answers.map((answer) => Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromARGB(255, 84, 228, 214),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               textStyle: const TextStyle(fontSize: 18),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                             onPressed: () => checkAnswer(answer),
//                             child: Text(answer),
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/service/game_service.dart';

class GamePage extends StatefulWidget {
  final String lesson;

  const GamePage({super.key, required this.lesson});

  @override
  GamePageState createState() => GamePageState();
}

class GamePageState extends State<GamePage> {
  double studentCarPosition = 0.0;
  double opponentCarPosition = 0.0;
  int currentQuestionIndex = 0; // Track the current question index
  final GameService _gameService = GameService();

  static const double correctAnswerDistance = 0.15;
  static const double incorrectAnswerDistance = 0.05;
  static const double finishLine = 1.0;

  String question = '';
  List<String> answers = [];
  String correctAnswer = '';
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> questions = []; // Store questions for the lesson

  @override
  void initState() {
    super.initState();
    loadQuestion();
  }

  Future<void> loadQuestion() async {
    // Fetch questions for the specified lesson (e.g., 'math', 'english')
    questions = await _gameService.fetchQuestions(widget.lesson);

    if (questions.isNotEmpty) {
      setState(() {
        currentQuestionIndex = 0; // Start with the first question
        updateQuestionData();
      });
    } else {
      print('No questions found for this lesson!');
    }
  }

  void updateQuestionData() {
    // Load question data from the current index
    if (questions.isNotEmpty && currentQuestionIndex < questions.length) {
      question = questions[currentQuestionIndex]['questionText'];
      answers =
          List<String>.from(questions[currentQuestionIndex]['answerOptions']);
      correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
    }
  }

  void checkAnswer(String answer) {
    setState(() {
      if (answer == correctAnswer) {
        studentCarPosition += correctAnswerDistance;
        opponentCarPosition += incorrectAnswerDistance + 0.02;
      } else {
        studentCarPosition += incorrectAnswerDistance;
        opponentCarPosition += incorrectAnswerDistance + 0.04;
      }

      if (studentCarPosition >= finishLine) {
        showResultDialog("You Win!");
        _gameService.updateUserProgress(userId!, {
          'points': FieldValue.increment(10),
          'badges': FieldValue.arrayUnion(['Winner']),
          'currentLesson': widget.lesson,
          'currentQuestionID': questions[currentQuestionIndex]
              ['id'], // Update to actual question ID
        });
      } else if (opponentCarPosition >= finishLine) {
        showResultDialog("You Lost!");
      }
    });
  }

  void loadNextQuestion() {
    setState(() {
      studentCarPosition = 0.0;
      opponentCarPosition = 0.0;

      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        updateQuestionData(); // Load the next question
      } else {
        currentQuestionIndex = 0; // Restart the quiz if at the end
        updateQuestionData();
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
              loadNextQuestion();
            },
            child: const Text('Next Question'),
          ),
        ],
      ),
    );
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
                image: AssetImage('images/road_background.png'),
                fit: BoxFit.fitWidth,
                alignment: Alignment.topCenter,
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
                      bottom: 115,
                      child: const Icon(Icons.directions_car,
                          color: Colors.blue, size: 50),
                    ),
                    // Opponent's car with animation
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: MediaQuery.of(context).size.width *
                          opponentCarPosition,
                      bottom: 180,
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
                              backgroundColor:
                                  const Color.fromARGB(255, 84, 228, 214),
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

// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:grade_up/constants/routes.dart';
// import 'package:grade_up/service/cloud_storage_exceptions.dart';
// import 'package:grade_up/service/game_service.dart';

// class GamePage extends StatefulWidget {
//   final String lesson;

//   const GamePage({super.key, required this.lesson});

//   @override
//   GamePageState createState() => GamePageState();
// }

// class GamePageState extends State<GamePage> {
//   double studentCarPosition = 0.0;
//   double opponentCarPosition = 0.0;
//   int currentQuestionIndex = 0;
//   final GameService _gameService = GameService();

//   static const double correctAnswerDistance = 0.15;
//   static const double incorrectAnswerDistance = 0.05;
//   static const double finishLine = 1.0;

//   String question = '';
//   List<String> answers = [];
//   String correctAnswer = '';
//   String? userId = FirebaseAuth.instance.currentUser?.uid;
//   List<Map<String, dynamic>> questions = [];

//   @override
//   void initState() {
//     super.initState();
//     loadQuestion();
//   }

//   Future<void> loadQuestion() async {
//     try {
//       // Fetch the user's current question level
//       final userProgress = await _gameService.getUserProgress(userId!);
//       final userQuestionLevel = userProgress['questionLevel'];

//       // Fetch questions filtered by lesson and question level
//       questions = await _gameService.fetchQuestionsByLevel(
//           widget.lesson, userQuestionLevel);

//       if (questions.isNotEmpty) {
//         setState(() {
//           currentQuestionIndex = 0;
//           updateQuestionData();
//         });
//       } else {
//         showCongratulationsDialog;
//       }
//     } catch (e) {
//       print("Error loading questions: $e");
//     }
//   }

//   void showCongratulationsDialog() {
//     showDialog(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text("Congratulations!"),
//           content: const Text("You've completed all levels. Great job!"),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 resetGame();
//               },
//               child: const Text("Play Again"),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   // Function to reset the game level in Firestore and navigate back to first level
//   void resetGame() async {
//     await FirebaseFirestore.instance
//         .collection('userprogress')
//         .doc(userId)
//         .update({
//       'questionLevel': 1, // Reset question level to 1
//       'currentLesson':
//           widget.lesson, // Assuming 'math' as default lesson, change as needed
//       'currentQuestionID': '', // Reset to first question or default question
//     });

//     setState(() async {
//       await _gameService.updateUserProgress(
//           userId!, {'questionLevel': '1'}); // Reset local level state to 1
//     });

//     // ignore: use_build_context_synchronously
//     Navigator.pop(context); // Close the dialog
//     // ignore: use_build_context_synchronously
//     Navigator.popAndPushNamed(
//         // ignore: use_build_context_synchronously
//         context,
//         gameoptionsRoute); // Restart the game page
//   }

//   void updateQuestionData() {
//     if (questions.isNotEmpty && currentQuestionIndex < questions.length) {
//       question = questions[currentQuestionIndex]['questionText'];
//       answers =
//           List<String>.from(questions[currentQuestionIndex]['answerOptions']);
//       correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
//     }
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
//               loadNextQuestion();
//             },
//             child: const Text('Next Question'),
//           ),
//         ],
//       ),
//     );
//   }

//   void checkAnswer(String answer) {
//     setState(() {
//       if (answer == correctAnswer) {
//         studentCarPosition += correctAnswerDistance;
//         opponentCarPosition += incorrectAnswerDistance + 0.02;

//         // Load the next question if the answer is correct
//         loadNextQuestion();
//       } else {
//         studentCarPosition += incorrectAnswerDistance;
//         opponentCarPosition += incorrectAnswerDistance + 0.04;
//       }

//       if (studentCarPosition >= finishLine) {
//         advanceToNextLevel();
//       } else if (opponentCarPosition >= finishLine) {
//         showResultDialog("You Lost!");
//       }
//     });
//   }

//   void loadNextQuestion() async {
//     setState(() {
//       if (currentQuestionIndex < questions.length - 1) {
//         currentQuestionIndex++;
//       } else {
//         currentQuestionIndex = 0;
//         updateQuestionData();
//       }
//     });

//     // Check if there are no more questions left at the current question level
//     if (currentQuestionIndex >= questions.length - 1) {
//       final userProgress = await _gameService.getUserProgress(userId!);
//       int currentLevel = int.parse(userProgress['questionLevel'] ?? '1');

//       // Advance to the next level
//       int nextLevel = currentLevel + 1;
//       await _gameService
//           .updateUserProgress(userId!, {'questionLevel': nextLevel.toString()});

//       // Reload questions at the new questionLevel
//       questions = await _gameService.fetchQuestionsByLevel(
//           widget.lesson, nextLevel.toString());
//       if (questions.isNotEmpty) {
//         setState(() {
//           currentQuestionIndex = 0;
//           updateQuestionData();
//         });
//       } else {
//         throw NoMoreQuestionsAvailableException;
//       }
//     }
//   }

//   // void loadNextQuestion() {
//   //   setState(() {
//   //     if (currentQuestionIndex < questions.length - 1) {
//   //       currentQuestionIndex++;
//   //     } else {
//   //       currentQuestionIndex = 0;
//   //     }
//   //     updateQuestionData();
//   //   });
//   // }

//   void advanceToNextLevel() {
//     showDialog(
//       context: context,
//       builder: (_) => AlertDialog(
//         title: const Text("Level Complete!"),
//         content: const Text("You advanced to the next level with a new badge!"),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               resetGameForNextLevel();
//             },
//             child: const Text('Continue'),
//           ),
//         ],
//       ),
//     );
//   }

//   void resetGameForNextLevel() {
//     _gameService.updateUserProgress(userId!, {
//       'points': FieldValue.increment(10),
//       'badges': FieldValue.arrayUnion(['New Level Badge']),
//       'currentLesson': widget.lesson,
//       'currentQuestionID': questions[currentQuestionIndex]['id'],
//     });

//     setState(() {
//       studentCarPosition = 0.0;
//       opponentCarPosition = 0.0;
//       currentQuestionIndex = 0;
//       updateQuestionData();
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
//       body: Stack(
//         children: [
//           Container(
//             decoration: const BoxDecoration(
//               image: DecorationImage(
//                 image: AssetImage('images/road_background.png'),
//                 fit: BoxFit.fitWidth,
//                 alignment: Alignment.topCenter,
//               ),
//             ),
//           ),
//           Column(
//             children: [
//               Expanded(
//                 child: Stack(
//                   children: [
//                     AnimatedPositioned(
//                       duration: const Duration(milliseconds: 500),
//                       left: MediaQuery.of(context).size.width *
//                           studentCarPosition,
//                       bottom: 115,
//                       child: const Icon(Icons.directions_car,
//                           color: Colors.blue, size: 50),
//                     ),
//                     AnimatedPositioned(
//                       duration: const Duration(milliseconds: 500),
//                       left: MediaQuery.of(context).size.width *
//                           opponentCarPosition,
//                       bottom: 180,
//                       child: const Icon(Icons.directions_car,
//                           color: Colors.red, size: 50),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     Text(
//                       question,
//                       style: const TextStyle(
//                         fontSize: 24,
//                         fontWeight: FontWeight.bold,
//                         color: Color.fromARGB(255, 59, 51, 51),
//                       ),
//                       textAlign: TextAlign.center,
//                     ),
//                     const SizedBox(height: 20),
//                     ...answers.map((answer) => Padding(
//                           padding: const EdgeInsets.symmetric(vertical: 4.0),
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                                   const Color.fromARGB(255, 84, 228, 214),
//                               padding: const EdgeInsets.symmetric(vertical: 12),
//                               textStyle: const TextStyle(fontSize: 18),
//                               shape: RoundedRectangleBorder(
//                                 borderRadius: BorderRadius.circular(20),
//                               ),
//                             ),
//                             onPressed: () => checkAnswer(answer),
//                             child: Text(answer),
//                           ),
//                         )),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }
