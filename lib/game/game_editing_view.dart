import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/game/download_template.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/service/game_service.dart';
import 'package:grade_up/utilities/build_text_field.dart';
import 'package:grade_up/utilities/custom_dialog.dart';

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
  List<String> _answerOptions =
      List.filled(4, ''); // Initialize with 4 empty strings
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

  bool areOptionsUnique(List<String> options) {
    return options.toSet().length == options.length;
  }

  bool areLessonGradeValid(String lesson, String grade) {
    if (widget.teacher.lessonGradeMap.containsKey(lesson) &&
        widget.teacher.lessonGradeMap[lesson]!.contains(int.parse(grade))) {
      return true;
    }
    return false;
  }

  bool _validateInputs(
    String? questionText,
    List<String> answerOptions,
    String? correctAnswer,
  ) {
    // Check if the question text exceeds 55 characters
    if (questionText != null && questionText.length > 55) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Question text cannot be that long.'),
        ),
      );
      return false;
    }

    // Check if the correct answer is one of the options
    if (!answerOptions.contains(correctAnswer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You must provide the correct answer in one of the options.')),
      );
      return false;
    }

    if (answerOptions.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must provide 4 answer options.')),
      );
      return false;
    }

    // Check if all options are unique
    if (!areOptionsUnique(answerOptions)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("All answer options must be unique.")),
      );
      return false;
    }

    // Check if we have 4 diffrent answer options
    bool flag = false;
    for (int i = 0; i < answerOptions.length; i++) {
      if (answerOptions[i] == correctAnswer) flag = true;
    }
    if (!flag) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'You must provide the correct answer in one of the options.')),
      );
      return false;
    }
    return true;
  }

  void _addQuestion() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      if (!_validateInputs(_questionText, _answerOptions, _correctAnswer)) {
        return; // Exit if validation fails
      }

      // Proceed with adding the question
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
        setState(() =>
            _answerOptions = List.filled(4, '')); // Reset with 4 empty strings

        _fetchQuestions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Each level must have a maximum of 6 questions.')),
        );
      }
    }
  }

  Future<void> _bulkUploadQuestions() async {
    int lastValidRow = 0; // Track the last valid row processed
    try {
      // Select the CSV file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);

        // Read and parse the CSV file
        final input = file.openRead();
        final fields = await input
            .transform(utf8.decoder)
            .transform(const CsvToListConverter())
            .toList();

        // Validate and process each row
        for (var i = 1; i < fields.length; i++) {
          // Started from i=1 to skip the first row in excel which is not a question we want to save.
          final row = fields[i];
          if (row.length < 7) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid CSV format!")),
            );
            return;
          }
          final lesson = row[0].toString();
          final grade = row[1].toString();
          final level = row[2].toString();
          final questionText = row[3].toString();
          final correctAnswer = row[4].toString();
          // Create a list for answerOptions from row[5], row[6], row[7], row[8]
          final answerOptions = [
            row[5]?.toString(),
            row[6]?.toString(),
            row[7]?.toString(),
            row[8]?.toString(),
          ]
              .where((option) => option != null && option.isNotEmpty)
              .cast<String>()
              .toList();

          if (!areLessonGradeValid(lesson, grade)) {
            CustomDialog.show(
                context,
                "You are not assigned to the lesson/grade you entered. ",
                "Validation failed at row ${i + 1}. Only rows up to $lastValidRow were processed.");
            return;
          }
          // Add question to the database
          if (!_validateInputs(questionText, answerOptions, correctAnswer)) {
            CustomDialog.show(
              context,
              "Validation Failed",
              "Validation failed at row ${i + 1}. Only rows up to $lastValidRow were processed.",
            );
            return; // Exit if validation fails
          }
          await gameService.addQuestion(
            lesson,
            {
              'questionText': questionText,
              'correctAnswer': correctAnswer,
              'answerOptions': answerOptions,
              'questionLevel': level,
            },
            widget.teacher.school,
            grade,
          );
          lastValidRow = i + 1; // Update the last valid row
        }
        // Notify success
        CustomDialog.show(context, "Success",
            "Questions uploaded successfully! Last processed row: $lastValidRow.");
        _fetchQuestions(); // Refresh the question list
      }
    } catch (e) {
      CustomDialog.show(context, "Error", "Error uploading questions: $e");
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
                                'Note: If adding a new level, ensure it eventually has at least 5 questions.In addition Question text can have a maximum of 9 words.',
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
                    const SizedBox(height: 24.0),
                    Text(
                      'Answer Options:',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8.0),
                    // Create 4 answer option fields
                    for (int i = 0; i < 4; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Option ${i + 1}',
                            filled: true,
                            fillColor: Colors.grey.shade200,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onSaved: (value) {
                            _answerOptions[i] = value ?? '';
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? 'Please enter Option ${i + 1}'
                              : null,
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: const Text('Add Question'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Use this option to upload multiple questions from a CSV file. "
                            "Ensure the file follows the required format. Click the info icon for details or download a template.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _bulkUploadQuestions,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Bulk Upload Questions"),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text("CSV Format Instructions"),
                                      content: const Text(
                                        "The CSV file should contain the following columns:\n"
                                        "1. Lesson (e.g., 'math')\n"
                                        "2. Grade (e.g., '6')\n"
                                        "3. Level (e.g., '1')\n"
                                        "4. Question Text (e.g., 'What is 2+2?')\n"
                                        "5. Correct Answer (e.g., '4')\n"
                                        "6. Option 1 (e.g., '4')\n"
                                        "7. Option 2 (e.g., '3')\n"
                                        "8. Option 3 (e.g., '5')\n"
                                        "9. Option 4 (e.g., '2')\n\n"
                                        "Ensure all rows are properly filled.",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("Close"),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          ElevatedButton.icon(
                            onPressed: () async {
                              const downloadTemplate = DownloadTemplate();
                              await downloadTemplate.downloadTemplate();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Downloading template..."),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("Download CSV Template"),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          "You can upload multiple questions from a CSV file on mobile only.",
                          style: TextStyle(fontSize: 16, color: Colors.blue),
                        ),
                      ),
                    ]
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
