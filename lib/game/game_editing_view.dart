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
      throw Exception("שגיאה בטעינת כיתות: $e");
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
        const SnackBar(content: Text('שאלה נמחקה בהצלחה')),
      );
      _fetchQuestions();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('חובה להשאיר לפחות שאלה אחת ברמה הזאת'),
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
          content: Text('שאלה ארוכה מדי'),
        ),
      );
      return false;
    }

    // Check if the correct answer is one of the options
    if (!answerOptions.contains(correctAnswer)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'חובה להזין תשובה נכונה לפי אחד האופציות')),
      );
      return false;
    }

    if (answerOptions.length != 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('חובה להזין 4 אפוציות בתשובות')),
      );
      return false;
    }

    // Check if all options are unique
    if (!areOptionsUnique(answerOptions)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("כל תשובה חייבת להיות שונה מהתשובות האחרות")),
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
                'חובה להזין תשובה נכונה לפי אחד האופציות')),
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
          const SnackBar(content: Text('שאלה הוספה בהצלחה')),
        );

        _formKey.currentState?.reset();
        setState(() =>
            _answerOptions = List.filled(4, '')); // Reset with 4 empty strings

        _fetchQuestions();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('מקסימום 6 שאלות לכל רמה')),
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
              const SnackBar(content: Text("סוג קובץ לא תקין (CSV)")),
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
                "אתה לא מלמד את השיעור/כיתה שהכנסת",
                "ולידציה נכשלה עד השורה ${i + 1}. רק שורות עד שורה $lastValidRow בוצעו.");
            return;
          }
          // Add question to the database
          if (!_validateInputs(questionText, answerOptions, correctAnswer)) {
            CustomDialog.show(
              context,
              "ולידציה נכשלה",
              "ולידציה נכשלה עד השורה ${i + 1}. רק שורות עד שורה $lastValidRow בוצעו.",
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
        CustomDialog.show(context, "הצלחה",
            ":השאלת עודכנו בהצלחה! שורה אחרונה שבוצעה $lastValidRow.");
        _fetchQuestions(); // Refresh the question list
      }
    } catch (e) {
      CustomDialog.show(context, "שגיאה", "שגיאה בעדכון שאלות: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'עריכת שאלות משחק',
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
                        labelText: 'בחר שיעור',
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
                          value == null ? 'בחר שיעור בבקשה' : null,
                    ),
                    const SizedBox(height: 10),
                    // Grade Dropdown
                    if (_selectedLesson != null)
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'בחר כיתה',
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
                            child: Text('כיתה $grade'),
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
                            value == null ? 'בחר כיתה בבקשה' : null,
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
                                  labelText: 'בחר או הוסיף רמה',
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
                                    ? 'רמות קיימות: ${levels.join(', ')}'
                                    : 'איו רמות קיימות. צור רמה חדשה',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'הערה: בהוספת רמה חדשה, יש לוודא שבסופו של דבר יש לה 5 שאלות לפחות. בנוסף, כל שאלה היא עד 9 מילים',
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
                                question['questionText'] ?? 'אין תוכן שאלה'),
                            subtitle:
                                Text('רמה: ${question['questionLevel']}'),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteQuestion(question['id']),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 10),
                    // Add Question Fields
                    buildTextField('שאלה',
                        onSaved: (value) => _questionText = value),

                    const SizedBox(height: 10),
                    buildTextField('תשובה נכונה',
                        onSaved: (value) => _correctAnswer = value),
                    const SizedBox(height: 24.0),
                    Text(
                      'תשובות:',
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
                            labelText: 'תשובה ${i + 1}',
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
                              ? 'בבקשה הכנס תשובה ${i + 1}'
                              : null,
                        ),
                      ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: _addQuestion,
                      child: const Text('הוספת שאלה'),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "בחר באופציה הזאת להוספת מספר שאלות ביחד בעזרת קובץ CSV\n"
                            "תוודא שהקובץ לפי הפורמט המתאים. לחץ על סימן אינפורמציה לקבל מידע או להוריד הטימפלט.",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: _bulkUploadQuestions,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("הוספת שאלות בעזרת קובץ"),
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.info_outline),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title:
                                          const Text("הוראות פורמט קובץ CSV"),
                                      content: const Text(
                                        ":הקובץ עלול להגיל את העמודות הבאות\n"
                                        "1. שיעור (למשל: מתמטיקה)\n"
                                        "2. כיתה (למשל: 6)\n"
                                        "3. רמה (למשל: 1)\n"
                                        "4. שאלה (למשל: 'מה זה 2+2')\n"
                                        "5. תשובה נכונה (למשל: '4')\n"
                                        "6. תשובה 1 (למשל: '4')\n"
                                        "7. תשובה 2 (למשל: '3')\n"
                                        "8. תשובה 3 (למשל: '2')\n"
                                        "9. תשובה 4 (למשל: '5')\n\n"
                                        "תוודא שכל השורות מלאות בהתאם",
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.of(context).pop(),
                                          child: const Text("סגור"),
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
                                  content: Text("...מוריד טפליט"),
                                ),
                              );
                            },
                            icon: const Icon(Icons.download),
                            label: const Text("CSV הורדת קובץ"),
                          ),
                        ],
                      ),
                    ] else ...[
                      const Center(
                        child: Text(
                          "אפשר להעלות מספר שאלות מקובץ CSV רק דרך טלפון",
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
