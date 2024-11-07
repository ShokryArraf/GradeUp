// // ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:grade_up/service/game_service.dart';

// class GameEditingView extends StatefulWidget {
//   const GameEditingView({super.key});

//   @override
//   GameEditingViewState createState() => GameEditingViewState();
// }

// class GameEditingViewState extends State<GameEditingView> {
//   final GameService _gameService = GameService();
//   String? _selectedLesson;
//   final TextEditingController _questionController = TextEditingController();
//   final TextEditingController _correctAnswerController =
//       TextEditingController();
//   final List<TextEditingController> _answerOptionControllers =
//       List.generate(4, (index) => TextEditingController());

//   Future<List<String>> _fetchLessons() async {
//     final lessonsSnapshot =
//         await _gameService.firestore.collection('lessons').get();
//     return lessonsSnapshot.docs.map((doc) => doc.id).toList();
//   }

//   Future<void> _addQuestion() async {
//     if (_selectedLesson == null ||
//         _questionController.text.isEmpty ||
//         _correctAnswerController.text.isEmpty ||
//         _answerOptionControllers.any((controller) => controller.text.isEmpty)) {
//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Please fill in all fields")));
//       return;
//     }

//     final questionData = {
//       'questionText': _questionController.text,
//       'correctAnswer': _correctAnswerController.text,
//       'answerOptions': _answerOptionControllers
//           .map((controller) => controller.text)
//           .toList(),
//       'questionLevel': '1', // Assuming default level; adjust as needed
//     };

//     try {
//       await _gameService.addQuestion(_selectedLesson!, questionData);
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Question added!")));
//       _clearFields();
//     } catch (e) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(SnackBar(content: Text("Failed to add question: $e")));
//     }
//   }

//   void _clearFields() {
//     _questionController.clear();
//     _correctAnswerController.clear();
//     for (var controller in _answerOptionControllers) {
//       controller.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Add Game Questions"),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: FutureBuilder<List<String>>(
//           future: _fetchLessons(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }

//             return Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 DropdownButton<String>(
//                   hint: const Text("Select Lesson"),
//                   value: _selectedLesson,
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedLesson = value;
//                     });
//                   },
//                   items: snapshot.data!
//                       .map((lesson) => DropdownMenuItem(
//                             value: lesson,
//                             child: Text(lesson),
//                           ))
//                       .toList(),
//                 ),
//                 TextField(
//                   controller: _questionController,
//                   decoration: const InputDecoration(labelText: "Question Text"),
//                 ),
//                 ..._answerOptionControllers.map((controller) => TextField(
//                       controller: controller,
//                       decoration:
//                           const InputDecoration(labelText: "Answer Option"),
//                     )),
//                 TextField(
//                   controller: _correctAnswerController,
//                   decoration:
//                       const InputDecoration(labelText: "Correct Answer"),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: _addQuestion,
//                   child: const Text("Add Question"),
//                 ),
//               ],
//             );
//           },
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously

// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:grade_up/service/game_service.dart';

// class GameEditingView extends StatefulWidget {
//   const GameEditingView({super.key});

//   @override
//   GameEditingViewState createState() => GameEditingViewState();
// }

// class GameEditingViewState extends State<GameEditingView> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedLesson;
//   String? _questionText;
//   String? _correctAnswer;
//   List<String> _answerOptions = [];
//   String? _selectedLevel;
//   final GameService _gameService = GameService();

//   Future<List<String>> _fetchLessons() async {
//     // Fetch the list of lessons from Firestore
//     final lessonsSnapshot =
//         await FirebaseFirestore.instance.collection('lessons').get();
//     return lessonsSnapshot.docs.map((doc) => doc.id).toList();
//   }

//   Future<List<String>> _fetchLevels(String lesson) async {
//     // Fetch unique levels for the selected lesson
//     final levelSnapshot = await FirebaseFirestore.instance
//         .collection('lessons')
//         .doc(lesson)
//         .collection('questions')
//         .get();

//     // Collect and return unique levels
//     return levelSnapshot.docs
//         .map((doc) => doc.data()['questionLevel'] as String)
//         .toSet()
//         .toList();
//   }

//   Future<int> _getQuestionCount(String lesson, String level) async {
//     // Get count of questions in a specific lesson and level
//     final questions = await _gameService.fetchQuestionsByLevel(lesson, level);
//     return questions.length;
//   }

//   void _addQuestion() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();

//       // Check the question count at the selected level
//       int currentCount =
//           await _getQuestionCount(_selectedLesson!, _selectedLevel!);
//       if (currentCount < 6) {
//         // Add the question if count is less than 6
//         await FirebaseFirestore.instance
//             .collection('lessons')
//             .doc(_selectedLesson)
//             .collection('questions')
//             .add({
//           'questionText': _questionText,
//           'correctAnswer': _correctAnswer,
//           'answerOptions': _answerOptions,
//           'questionLevel': _selectedLevel,
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Question added successfully!')),
//         );

//         // Clear form
//         _formKey.currentState?.reset();
//         setState(() {
//           _answerOptions.clear();
//         });
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//               content: Text('Each level must have exactly 6 questions.')),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Add Game Question')),
//       body: FutureBuilder<List<String>>(
//         future: _fetchLessons(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return const Center(child: CircularProgressIndicator());
//           }

//           final lessons = snapshot.data!;
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   DropdownButtonFormField<String>(
//                     decoration:
//                         const InputDecoration(labelText: 'Select Lesson'),
//                     items: lessons.map((lesson) {
//                       return DropdownMenuItem(
//                         value: lesson,
//                         child: Text(lesson),
//                       );
//                     }).toList(),
//                     onChanged: (value) async {
//                       setState(() {
//                         _selectedLesson = value;
//                         _selectedLevel = null; // Reset level on lesson change
//                       });
//                     },
//                     validator: (value) =>
//                         value == null ? 'Please select a lesson' : null,
//                   ),
//                   if (_selectedLesson != null)
//                     FutureBuilder<List<String>>(
//                       future: _fetchLevels(_selectedLesson!),
//                       builder: (context, levelSnapshot) {
//                         if (!levelSnapshot.hasData) {
//                           return const Center(
//                               child: CircularProgressIndicator());
//                         }
//                         final levels = levelSnapshot.data!;
//                         return DropdownButtonFormField<String>(
//                           decoration:
//                               const InputDecoration(labelText: 'Select Level'),
//                           items: levels.map((level) {
//                             return DropdownMenuItem(
//                               value: level,
//                               child: Text(level),
//                             );
//                           }).toList(),
//                           onChanged: (value) {
//                             setState(() {
//                               _selectedLevel = value;
//                             });
//                           },
//                           validator: (value) => value == null
//                               ? 'Please select a question level'
//                               : null,
//                         );
//                       },
//                     ),
//                   TextFormField(
//                     decoration:
//                         const InputDecoration(labelText: 'Question Text'),
//                     onSaved: (value) => _questionText = value,
//                     validator: (value) => value == null || value.isEmpty
//                         ? 'Please enter the question text'
//                         : null,
//                   ),
//                   TextFormField(
//                     decoration:
//                         const InputDecoration(labelText: 'Correct Answer'),
//                     onSaved: (value) => _correctAnswer = value,
//                     validator: (value) => value == null || value.isEmpty
//                         ? 'Please enter the correct answer'
//                         : null,
//                   ),
//                   TextFormField(
//                     decoration: const InputDecoration(
//                         labelText: 'Answer Options (comma-separated)'),
//                     onSaved: (value) {
//                       _answerOptions =
//                           value!.split(',').map((e) => e.trim()).toList();
//                     },
//                     validator: (value) => value == null || value.isEmpty
//                         ? 'Please enter at least one answer option'
//                         : null,
//                   ),
//                   const SizedBox(height: 20),
//                   ElevatedButton(
//                     onPressed: _addQuestion,
//                     child: const Text('Add Question'),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/game_service.dart';

class GameEditingView extends StatefulWidget {
  const GameEditingView({super.key});

  @override
  GameEditingViewState createState() => GameEditingViewState();
}

class GameEditingViewState extends State<GameEditingView> {
  final _formKey = GlobalKey<FormState>();
  String? _selectedLesson;
  String? _questionText;
  String? _correctAnswer;
  List<String> _answerOptions = [];
  String? _selectedLevel;
  final GameService _gameService = GameService();
  List<Map<String, dynamic>> _questions = [];

  Future<List<String>> _fetchLessons() async {
    final lessonsSnapshot =
        await FirebaseFirestore.instance.collection('lessons').get();
    return lessonsSnapshot.docs.map((doc) => doc.id).toList();
  }

  Future<List<String>> _fetchLevels(String lesson) async {
    final levelSnapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .doc(lesson)
        .collection('questions')
        .get();

    return levelSnapshot.docs
        .map((doc) => doc.data()['questionLevel'] as String)
        .toSet()
        .toList();
  }

  Future<void> _fetchQuestions() async {
    if (_selectedLesson != null && _selectedLevel != null) {
      final querySnapshot = await FirebaseFirestore.instance
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
    await FirebaseFirestore.instance
        .collection('lessons')
        .doc(_selectedLesson)
        .collection('questions')
        .doc(questionId)
        .delete();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Question deleted successfully!')),
    );

    _fetchQuestions(); // Refresh questions list after deletion
  }

  void _addQuestion() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      int currentCount = _questions.length;
      if (currentCount < 6) {
        await FirebaseFirestore.instance
            .collection('lessons')
            .doc(_selectedLesson)
            .collection('questions')
            .add({
          'questionText': _questionText,
          'correctAnswer': _correctAnswer,
          'answerOptions': _answerOptions,
          'questionLevel': _selectedLevel,
        });

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
      appBar: AppBar(title: const Text('Edit Game Questions')),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<String>(
                    decoration:
                        const InputDecoration(labelText: 'Select Lesson'),
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
                  if (_selectedLesson != null)
                    FutureBuilder<List<String>>(
                      future: _fetchLevels(_selectedLesson!),
                      builder: (context, levelSnapshot) {
                        if (!levelSnapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        final levels = levelSnapshot.data!;
                        return DropdownButtonFormField<String>(
                          decoration:
                              const InputDecoration(labelText: 'Select Level'),
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
                  if (_questions.isNotEmpty)
                    Expanded(
                      child: ListView.builder(
                        itemCount: _questions.length,
                        itemBuilder: (context, index) {
                          final question = _questions[index];
                          return ListTile(
                            title: Text(question['questionText']),
                            subtitle:
                                Text('Level: ${question['questionLevel']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deleteQuestion(question['id']);
                              },
                            ),
                          );
                        },
                      ),
                    ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Question Text'),
                    onSaved: (value) => _questionText = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the question text'
                        : null,
                  ),
                  TextFormField(
                    decoration:
                        const InputDecoration(labelText: 'Correct Answer'),
                    onSaved: (value) => _correctAnswer = value,
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter the correct answer'
                        : null,
                  ),
                  TextFormField(
                    decoration: const InputDecoration(
                        labelText: 'Answer Options (comma-separated)'),
                    onSaved: (value) {
                      _answerOptions =
                          value!.split(',').map((e) => e.trim()).toList();
                    },
                    validator: (value) => value == null || value.isEmpty
                        ? 'Please enter answer options'
                        : null,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _addQuestion,
                    child: const Text('Add Question'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
