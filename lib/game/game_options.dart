import 'package:flutter/material.dart';
import 'package:grade_up/game/game_page.dart';

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
                _buildGameButton(
                  context,
                  "Play Math Game",
                  Icons.calculate,
                  Colors.greenAccent,
                  () => navigateToGamePage(context, "math"),
                ),
                const SizedBox(height: 20),
                _buildGameButton(
                  context,
                  "Play English Game",
                  Icons.menu_book,
                  Colors.amberAccent,
                  () => navigateToGamePage(context, "english"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGameButton(BuildContext context, String text, IconData icon,
      Color color, VoidCallback onPressed) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        shadowColor: Colors.black54,
      ),
      icon: Icon(icon, size: 28, color: Colors.white),
      label: Text(
        text,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      onPressed: onPressed,
    );
  }
}
