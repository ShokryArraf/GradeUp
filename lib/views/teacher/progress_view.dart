import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/views/teacher/student_progress_page.dart';

class ProgressView extends StatefulWidget {
  final Teacher teacher;

  const ProgressView({super.key, required this.teacher});

  @override
  State<ProgressView> createState() => _ProgressViewState();
}

class _ProgressViewState extends State<ProgressView> {
  final TextEditingController _gradeSearchController = TextEditingController();
  String? _selectedLesson;
  List<int> _gradesList = [];
  List<int> _filteredGrades = [];
  bool _isLoading = false;

  void _updateGradesList(String selectedLesson) {
    setState(() {
      _gradesList = widget.teacher.lessonGradeMap[selectedLesson] ?? [];
      _filteredGrades = List.from(_gradesList);
    });
  }

  void _filterGrades(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredGrades = List.from(_gradesList);
      });
      return;
    }

    final searchGrade = int.tryParse(query);
    if (searchGrade != null) {
      setState(() {
        _filteredGrades =
            _gradesList.where((grade) => grade == searchGrade).toList();
      });
    } else {
      setState(() {
        _filteredGrades = [];
      });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchStudentsProgress(
      String school, int grade, String lesson) async {
    final firestore = FirebaseFirestore.instance;

    try {
      final studentsSnapshot = await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade.toString())
          .collection('students')
          .get();

      List<Map<String, dynamic>> studentProgress = [];

      for (var studentDoc in studentsSnapshot.docs) {
        final studentId = studentDoc.id;

        final assignmentsSnapshot = await firestore
            .collection('schools')
            .doc(school)
            .collection('grades')
            .doc(grade.toString())
            .collection('students')
            .doc(studentId)
            .collection('assignmentsToDo')
            .where('lesson', isEqualTo: lesson)
            .get();

        int totalAssignments = assignmentsSnapshot.size;
        int completedAssignments = assignmentsSnapshot.docs
            .where((doc) => doc.data()['status'] == 'submitted')
            .length;

        studentProgress.add({
          'name': studentDoc.data()['name'] ?? 'Unnamed Student',
          'completed': completedAssignments,
          'total': totalAssignments,
        });
      }

      return studentProgress;
    } catch (e) {
      debugPrint('Error fetching student progress: $e');
      return [];
    }
  }

  void _navigateToStudentProgress(int grade) async {
    if (_selectedLesson == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final studentProgress = await _fetchStudentsProgress(
        widget.teacher.school,
        grade,
        _selectedLesson!,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => StudentProgressPage(
            grade: grade,
            studentProgress: studentProgress,
          ),
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Student Progress'),
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
      body: RefreshIndicator(
        onRefresh: () async {
          if (_selectedLesson != null) {
            _updateGradesList(_selectedLesson!);
          }
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select a Lesson and Grade',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedLesson,
                  decoration: const InputDecoration(
                    labelText: 'Select Lesson',
                    border: OutlineInputBorder(),
                  ),
                  items: widget.teacher.lessonGradeMap.keys.map((lesson) {
                    return DropdownMenuItem<String>(
                      value: lesson,
                      child: Text(lesson),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLesson = value!;
                      _updateGradesList(value);
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _gradeSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Grade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _filterGrades,
                ),
                const SizedBox(height: 16),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredGrades.length,
                  itemBuilder: (context, index) {
                    final grade = _filteredGrades[index];
                    return ListTile(
                      title: Text('Grade: $grade'),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.chevron_right, color: Colors.blue),
                        onPressed: () => _navigateToStudentProgress(grade),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:grade_up/models/teacher.dart';
// import 'package:grade_up/views/teacher/student_progress_page.dart';

// class ProgressView extends StatefulWidget {
//   final Teacher teacher;

//   const ProgressView({super.key, required this.teacher});

//   @override
//   State<ProgressView> createState() => _ProgressViewState();
// }

// class _ProgressViewState extends State<ProgressView> {
//   final TextEditingController _gradeSearchController = TextEditingController();
//   String? _selectedLesson;
//   List<int> _gradesList = [];
//   List<int> _filteredGrades = [];
//   bool _isLoading = false;

//   void _updateGradesList(String selectedLesson) {
//     setState(() {
//       _gradesList = widget.teacher.lessonGradeMap[selectedLesson] ?? [];
//       _filteredGrades = List.from(_gradesList);
//     });
//   }

//   void _filterGrades(String query) {
//     if (query.isEmpty) {
//       setState(() {
//         _filteredGrades = List.from(_gradesList);
//       });
//       return;
//     }

//     final searchGrade = int.tryParse(query);
//     if (searchGrade != null) {
//       setState(() {
//         _filteredGrades =
//             _gradesList.where((grade) => grade == searchGrade).toList();
//       });
//     } else {
//       setState(() {
//         _filteredGrades = [];
//       });
//     }
//   }

//   Future<List<Map<String, dynamic>>> _fetchStudentsProgress(
//       String school, int grade, String lesson) async {
//     final firestore = FirebaseFirestore.instance;

//     try {
//       final studentsSnapshot = await firestore
//           .collection('schools')
//           .doc(school)
//           .collection('grades')
//           .doc(grade.toString())
//           .collection('students')
//           .get();

//       List<Map<String, dynamic>> studentProgress = [];

//       for (var studentDoc in studentsSnapshot.docs) {
//         final studentId = studentDoc.id;

//         final assignmentsSnapshot = await firestore
//             .collection('schools')
//             .doc(school)
//             .collection('grades')
//             .doc(grade.toString())
//             .collection('students')
//             .doc(studentId)
//             .collection('assignmentsToDo')
//             .where('lesson', isEqualTo: lesson)
//             .get();

//         int totalAssignments = assignmentsSnapshot.size;
//         int completedAssignments = assignmentsSnapshot.docs
//             .where((doc) => doc.data()['status'] == 'submitted')
//             .length;

//         studentProgress.add({
//           'name': studentDoc.data()['name'] ?? 'Unnamed Student',
//           'completed': completedAssignments,
//           'total': totalAssignments,
//         });
//       }

//       return studentProgress;
//     } catch (e) {
//       debugPrint('Error fetching student progress: $e');
//       return [];
//     }
//   }

//   void _navigateToStudentProgress(int grade) async {
//     if (_selectedLesson == null) return;

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       final studentProgress = await _fetchStudentsProgress(
//         widget.teacher.school,
//         grade,
//         _selectedLesson!,
//       );

//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => StudentProgressPage(
//             grade: grade,
//             studentProgress: studentProgress,
//           ),
//         ),
//       );
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Student Progress'),
//         centerTitle: true,
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
//       body: RefreshIndicator(
//         onRefresh: () async {
//           if (_selectedLesson != null) {
//             _updateGradesList(_selectedLesson!);
//           }
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           child: Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Select a Lesson and Grade',
//                   style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//                 ),
//                 Autocomplete<String>(
//                   optionsBuilder: (TextEditingValue textEditingValue) {
//                     return widget.teacher.lessonGradeMap.keys
//                         .where((lesson) => lesson
//                             .toLowerCase()
//                             .contains(textEditingValue.text.toLowerCase()))
//                         .toList();
//                   },
//                   onSelected: (selectedLesson) {
//                     setState(() {
//                       _selectedLesson = selectedLesson;
//                       _updateGradesList(selectedLesson);
//                     });
//                   },
//                   fieldViewBuilder:
//                       (context, controller, focusNode, onEditingComplete) {
//                     return TextField(
//                       controller: controller,
//                       focusNode: focusNode,
//                       onEditingComplete: onEditingComplete,
//                       decoration: const InputDecoration(
//                         labelText: 'Select Lesson',
//                         border: OutlineInputBorder(),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 TextField(
//                   controller: _gradeSearchController,
//                   decoration: const InputDecoration(
//                     labelText: 'Search Grade',
//                     border: OutlineInputBorder(),
//                   ),
//                   keyboardType: TextInputType.number,
//                   onChanged: _filterGrades,
//                 ),
//                 const SizedBox(height: 16),
//                 ListView.builder(
//                   shrinkWrap: true,
//                   physics: const NeverScrollableScrollPhysics(),
//                   itemCount: _filteredGrades.length,
//                   itemBuilder: (context, index) {
//                     final grade = _filteredGrades[index];
//                     return ListTile(
//                       title: Text('Grade: $grade'),
//                       trailing: IconButton(
//                         icon:
//                             const Icon(Icons.chevron_right, color: Colors.blue),
//                         onPressed: () => _navigateToStudentProgress(grade),
//                       ),
//                     );
//                   },
//                 ),
//                 const SizedBox(height: 16),
//                 if (_isLoading)
//                   const Center(child: CircularProgressIndicator()),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
