import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/service/game_service.dart';
import 'package:grade_up/utilities/build_text_field.dart';

class GameEditingView extends StatefulWidget {
  final Teacher teacher;
  const GameEditingView({super.key, required this.teacher});

  @override
  GameEditingViewState createState() => GameEditingViewState();
}

class GameEditingViewState extends State<GameEditingView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLesson;
  String? _selectedGrade;
  String? _selectedLevel;
  String? _questionText;
  String? _correctAnswer;
  List<String> _answerOptions = [];
  List<Map<String, dynamic>> _questions = [];

  final GameService gameService = GameService();

  Future<List<String>> _fetchAssignedLessons() async {
    try {
      final lessonGradeMap = widget.teacher.lessonGradeMap;
      if (lessonGradeMap.isEmpty) throw ErrorFetchingAssignedLessonsException();
      return lessonGradeMap.keys.toList();
    } catch (_) {
      throw ErrorFetchingAssignedLessonsException();
    }
  }

  List<int> _fetchGradesForLesson(String lessonName) {
    try {
      return widget.teacher.lessonGradeMap[lessonName] ?? [];
    } catch (e) {
      throw Exception("Error fetching grades: $e");
    }
  }

  Future<void> _fetchQuestions() async {
    if (_selectedLesson != null &&
        _selectedGrade != null &&
        _selectedLevel != null) {
      try {
        // Fetch questions from the service
        List<Map<String, dynamic>> questions = await gameService.fetchQuestions(
          _selectedLesson!,
          widget.teacher.school,
          _selectedGrade!,
        );

        // Process and filter questions based on the selected level
        _questions = questions
            .where((q) => q['questionLevel'] == _selectedLevel)
            .map((q) {
          return q;
        }).toList();

        setState(() {}); // Update the state after fetching questions
      } catch (_) {
        throw ErrorFetchingQuestionsException();
      }
    }
  }

  Future<void> _deleteQuestion(String questionId) async {
    if (_questions.length > 1) {
      await gameService.deleteQuestion(
          _selectedLesson!, questionId, widget.teacher.school, _selectedGrade!);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Question deleted successfully!')),
      );
      _fetchQuestions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('At least one question must remain at this level.'),
        ),
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
          widget.teacher.school,
          _selectedGrade!,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question added successfully!')),
        );

        _formKey.currentState?.reset();
        setState(() => _answerOptions.clear());
        _fetchQuestions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Each level must have a maximum of 6 questions.')),
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
        future: _fetchAssignedLessons(),
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
                    // Lesson Dropdown
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
                            value: lesson, child: Text(lesson));
                      }).toList(),
                      value:
                          _selectedLesson, // Ensure that the lesson is selected from the list
                      onChanged: (value) {
                        setState(() {
                          _selectedLesson = value;
                          _selectedLevel = null;
                          _selectedGrade = null;
                          _questions = [];
                          _fetchGradesForLesson(_selectedLesson!);
                        });
                      },
                      validator: (value) =>
                          value == null ? 'Please select a lesson' : null,
                    ),
                    const SizedBox(height: 10),
                    // Grade Dropdown
                    if (_selectedLesson != null)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Select Grade',
                          filled: true,
                          fillColor: Colors.grey.shade200,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        items: _fetchGradesForLesson(_selectedLesson!)
                            .map((grade) {
                          return DropdownMenuItem(
                            value: grade.toString(),
                            child: Text('Grade $grade'),
                          );
                        }).toList(),
                        value:
                            _selectedGrade, // Ensure this matches one of the available grades
                        onChanged: (value) {
                          setState(() {
                            _selectedGrade = value;
                            _selectedLevel = null;
                            _questions = [];
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Please select a grade' : null,
                      ),
                    const SizedBox(height: 10),
                    // Level Selection
                    if (_selectedLesson != null && _selectedGrade != null)
                      FutureBuilder<List<String>>(
                        future: gameService
                            .fetchQuestions(
                              _selectedLesson!,
                              widget.teacher.school,
                              _selectedGrade!,
                            )
                            .then((questions) => questions
                                .map((q) => q['questionLevel'] as String)
                                .toSet()
                                .toList()),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }
                          final levels = snapshot.data!;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller:
                                    TextEditingController(text: _selectedLevel),
                                onChanged: (value) {
                                  setState(() {
                                    _selectedLevel = value;
                                    _questions = [];
                                  });
                                  if (levels.contains(value)) {
                                    _fetchQuestions();
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: 'Select or Add a Level',
                                  filled: true,
                                  fillColor: Colors.grey.shade200,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                levels.isNotEmpty
                                    ? 'Existing Levels: ${levels.join(', ')}'
                                    : 'No levels exist yet. Create a new level.',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Note: If adding a new level, ensure it eventually has at least 5 questions.',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 10),
                    // Display Questions
                    if (_questions.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return ListTile(
                            title: Text(
                                question['questionText'] ?? 'No Question Text'),
                            subtitle:
                                Text('Level: ${question['questionLevel']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuestion(question['id']),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 10),
                    // Add Question Fields
                    buildTextField('Question Text',
                        onSaved: (value) => _questionText = value),
                    const SizedBox(height: 10),
                    buildTextField('Correct Answer',
                        onSaved: (value) => _correctAnswer = value),
                    const SizedBox(height: 10),
                    buildTextField(
                      'Answer Options (comma-separated)',
                      onSaved: (value) => _answerOptions =
                          value?.split(',').map((e) => e.trim()).toList() ?? [],
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: const Text('Add Question'),
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
