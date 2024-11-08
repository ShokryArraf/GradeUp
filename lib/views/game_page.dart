import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
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
  int currentQuestionIndex = 0;
  final GameService _gameService = GameService();
  final ConfettiController _confettiController = ConfettiController();

  static const double correctAnswerDistance = 1 / 5;
  static const double finishLine = 1.0;

  String question = '';
  List<String> answers = [];
  String correctAnswer = '';
  String? userId = FirebaseAuth.instance.currentUser?.uid;
  List<Map<String, dynamic>> questions = [];
  int points = 0;
  int level = 1;
  int rightAnswers = 0;
  int wrongAnswers = 0;
  String? selectedAnswer;

  @override
  void initState() {
    super.initState();
    _confettiController.stop(); // Start with confetti off
    loadUserProgress();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  Future<void> loadUserProgress() async {
    if (userId != null) {
      try {
        final userProgress =
            await _gameService.fetchUserProgress(userId!, widget.lesson);
        if (userProgress != null) {
          level = userProgress['level'] ?? 1;
          points = userProgress['points'] ?? 0;
          rightAnswers = userProgress['rightAnswers'] ?? 0;
          wrongAnswers = userProgress['wrongAnswers'] ?? 0;
        }
        loadQuestions();
      } catch (e) {
        showError("Error loading user progress");
      }
    }
  }

  Future<void> loadQuestions() async {
    questions = await _gameService.fetchQuestionsByLevel(
        widget.lesson, level.toString());
    if (questions.isNotEmpty) {
      setQuestionData();
    } else {
      showGameCompletionDialog();
    }
  }

  void setQuestionData() {
    setState(() {
      question = questions[currentQuestionIndex]['questionText'];
      answers =
          List<String>.from(questions[currentQuestionIndex]['answerOptions']);
      correctAnswer = questions[currentQuestionIndex]['correctAnswer'];
      selectedAnswer = null;
    });
  }

  void checkAnswer(String answer) {
    setState(() {
      selectedAnswer = answer;
      if (answer == correctAnswer) {
        studentCarPosition += correctAnswerDistance;
        points += 10;
        rightAnswers++;

        if (studentCarPosition >= finishLine) {
          levelUp();
        } else {
          opponentCarPosition += correctAnswerDistance * 0.8;
          if (opponentCarPosition >= finishLine) {
            showLoseDialog();
          }
          loadNextQuestion();
        }
      } else {
        wrongAnswers++;
        opponentCarPosition += correctAnswerDistance * 0.5;

        if (opponentCarPosition >= finishLine) {
          showLoseDialog();
        }
      }
    });
  }

  Future<void> updateUserProgress() async {
    if (userId != null) {
      await _gameService.updateUserProgress(
          userId!, widget.lesson, rightAnswers, points, level, wrongAnswers);
    }
  }

  void loadNextQuestion() {
    setState(() {
      if (currentQuestionIndex < questions.length - 1) {
        currentQuestionIndex++;
        setQuestionData();
      } else {
        showGameCompletionDialog();
      }
    });
  }

  Future<void> levelUp() async {
    level++;
    studentCarPosition = 0.0;
    opponentCarPosition = 0.0;
    currentQuestionIndex = 0;
    await updateUserProgress();

    showLevelUpDialog();
    questions = await _gameService.fetchQuestionsByLevel(
        widget.lesson, level.toString());

    if (questions.isNotEmpty) {
      setQuestionData();
    } else {
      showGameCompletionDialog();
    }
  }

  void showLevelUpDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Row(
          children: [
            Text("Level Up!"),
            SizedBox(width: 10),
            Icon(Icons.emoji_events,
                color: Colors.amber, size: 32), // Badge Icon
          ],
        ),
        content: Text("Congratulations! You've reached level $level."),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                studentCarPosition = 0.0;
              });
            },
            child: const Text('Start Next Level'),
          ),
        ],
      ),
    );
  }

  void showLoseDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("You Lose!"),
        content: const Text(
            "The opponent reached the finish line first. Try again!"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              resetLevel();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void resetLevel() {
    setState(() {
      studentCarPosition = 0.0;
      opponentCarPosition = 0.0;
      currentQuestionIndex = 0;
      loadQuestions();
    });
  }

  void showGameCompletionDialog() {
    // Create an OverlayEntry for the confetti
    final overlay = Overlay.of(context);
    final confettiOverlay = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: true,
          // Adjust for a more intense celebration
          colors: const [
            Colors.red,
            Colors.orange,
            Colors.yellow,
            Colors.green,
            Colors.blue,
            Colors.indigo,
            Colors.purple,
          ],
          numberOfParticles: 50, // Increase particle count for intensity
          minBlastForce: 10, // Adjust min blast speed
          maxBlastForce: 20, // Adjust max blast speed for explosion effect
          gravity: 0.2, // Set lower gravity for a floating effect
          createParticlePath: (size) => Path()
            ..addOval(Rect.fromCircle(
                center: Offset.zero, radius: 8)), // Larger particles
        ),
      ),
    );

    // Insert the confetti overlay on top
    overlay.insert(confettiOverlay);
    _confettiController.play();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Game Complete!"),
        content:
            const Text("You've successfully completed all levels! Great job!"),
        actions: [
          TextButton(
            onPressed: () async {
              _confettiController.stop();

              // Reset level to 1 and restart to the game options.
              level = 1;
              await updateUserProgress();
              // ignore: use_build_context_synchronously
              Navigator.of(context)
                ..popUntil(ModalRoute.withName(studentviewRoute))
                ..pushNamed(gameoptionsRoute);
            },
            child: const Text('Restart Game'),
          ),
          TextButton(
            onPressed: () {
              _confettiController.stop();
              // Save current level and navigate back to student view without resetting
              Navigator.of(context).pop();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(studentviewRoute, (route) => false);
            },
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void showError(String error) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
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
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            shouldLoop: false,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.orange,
              Colors.pink
            ],
            createParticlePath: (size) => Path()
              ..addOval(Rect.fromCircle(center: Offset.zero, radius: 5)),
          ),
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
              const SizedBox(height: 16),
              if (level > 1) // Show badge only if user is above level 1
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.emoji_events,
                        color: Colors.amber, size: 40),
                    const SizedBox(width: 8),
                    Text(
                      "Level $level Badge!",
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              Expanded(
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: MediaQuery.of(context).size.width *
                          studentCarPosition,
                      bottom: 115,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.red,
                        size: 50,
                      ),
                    ),
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 500),
                      left: MediaQuery.of(context).size.width *
                          opponentCarPosition,
                      bottom: 170,
                      child: const Icon(
                        Icons.directions_car,
                        color: Colors.blue,
                        size: 50,
                      ),
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
                              backgroundColor: selectedAnswer == answer &&
                                      answer != correctAnswer
                                  ? Colors.red
                                  : const Color.fromARGB(255, 84, 228, 214),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              textStyle: const TextStyle(fontSize: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              checkAnswer(answer);
                              if (selectedAnswer == answer &&
                                  answer != correctAnswer) {
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  setState(() {
                                    selectedAnswer = null;
                                  });
                                });
                              }
                            },
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
