// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grade_up/service/game_service.dart';
import 'package:grade_up/utilities/build_text_field.dart';

class GameEditingView extends StatefulWidget {
  const GameEditingView({super.key});

  @override
  GameEditingViewState createState() => GameEditingViewState();
}

GameService gameService = GameService();

class GameEditingViewState extends State<GameEditingView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLesson;
  String? _questionText;
  String? _correctAnswer;
  List<String> _answerOptions = [];
  String? _selectedLevel;
  List<Map<String, dynamic>> _questions = [];

  Future<List<String>> _fetchLessons() async {
    final lessonsSnapshot =
        await gameService.firestore.collection('lessons').get();
    return lessonsSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<void> _fetchQuestions() async {
    if (_selectedLesson != null && _selectedLevel != null) {
      final querySnapshot = await gameService.firestore
          .collection('lessons')
          .doc(_selectedLesson)
          .collection('questions')
          .where('questionLevel', isEqualTo: _selectedLevel)
          .get();

      // Map each document to include the document ID
      _questions = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data map
        return data;
      }).toList();

      setState(() {}); // Refresh the UI to show the fetched questions
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    if (_selectedLesson != null && questionId.isNotEmpty) {
      // Check if there’s more than one question at this level
      if (_questions.length > 1) {
        await gameService.deleteQuestion(_selectedLesson!, questionId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question deleted successfully!')),
        );

        _fetchQuestions(); // Refresh questions list after deletion
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content:
                  Text('At least one question must remain at this level.')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Error: Question ID is null or lesson is not selected')),
      );
    }
  }

  void _addQuestion() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      if (_questions.length < 6) {
        await gameService.addQuestion(
          _selectedLesson!,
          {
            'questionText': _questionText,
            'correctAnswer': _correctAnswer,
            'answerOptions': _answerOptions,
            'questionLevel': _selectedLevel,
          },
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully!')),
        );

        _formKey.currentState?.reset();
        setState(() {
          _answerOptions.clear();
        });
        _fetchQuestions(); // Refresh questions list after adding a new question
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Each level must have exactly 6 questions.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Game Questions',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
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
      body: FutureBuilder<List<String>>(
        future: _fetchLessons(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final lessons = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Select Lesson',
                        filled: true,
                        fillColor: Colors.grey.shade200,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      items: lessons.map((lesson) {
                        return DropdownMenuItem(
                          value: lesson,
                          child: Text(lesson),
                        );
                      }).toList(),
                      onChanged: (value) async {
                        setState(() {
                          _selectedLesson = value;
                          _selectedLevel = null;
                          _questions = [];
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a lesson' : null,
                    ),
                    const SizedBox(height: 12),
                    if (_selectedLesson != null)
                      FutureBuilder<List<String>>(
                        future: gameService
                            .fetchQuestions(_selectedLesson!)
                            .then((questions) => questions
                                .map((q) => q['questionLevel'] as String)
                                .toSet()
                                .toList()),
                        builder: (context, levelSnapshot) {
                          if (!levelSnapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final levels = levelSnapshot.data!;
                          return DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: 'Select Level',
                              filled: true,
                              fillColor: Colors.grey.shade200,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                            ),
                            items: levels.map((level) {
                              return DropdownMenuItem(
                                value: level,
                                child: Text(level),
                              );
                            }).toList(),
                            onChanged: (value) async {
                              setState(() {
                                _selectedLevel = value;
                                _questions = [];
                              });
                              _fetchQuestions();
                            },
                            validator: (value) => value == null
                                ? 'Please select a question level'
                                : null,
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    if (_questions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(
                                question['questionText'] ?? 'No Question Text',
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              subtitle:
                                  Text('Level: ${question['questionLevel']}'),
                              trailing: IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  _deleteQuestion(question['id']);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 20),
                    buildTextField('Question Text', onSaved: (value) {
                      _questionText = value;
                    }),
                    const SizedBox(height: 10),
                    buildTextField('Correct Answer', onSaved: (value) {
                      _correctAnswer = value;
                    }),
                    const SizedBox(height: 10),
                    buildTextField(
                      'Answer Options (comma-separated)',
                      onSaved: (value) {
                        _answerOptions =
                            value!.split(',').map((e) => e.trim()).toList();
                      },
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: ElevatedButton(
                        onPressed: _addQuestion,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            vertical: 16.0,
                            horizontal: 24.0,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: const Text(
                          'Add Question',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
