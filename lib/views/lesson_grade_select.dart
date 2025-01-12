import 'package:flutter/material.dart';
import 'package:grade_up/assignments/submitted_assignment_list.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/teacher_service.dart';
import 'package:grade_up/views/teacher/student_progress_page.dart';

// We use this class two times: one for viewing student's progress and the other for viewing the submitted assignments
class LessonGradeSelect extends StatefulWidget {
  final Teacher teacher;
  final bool isViewingProgress; // Add a boolean to differentiate modes

  const LessonGradeSelect({
    super.key,
    required this.teacher,
    required this.isViewingProgress, // Require this parameter
  });

  @override
  LessonGradeSelectState createState() => LessonGradeSelectState();
}

class LessonGradeSelectState extends State<LessonGradeSelect> {
  final TeacherService _teacherService = TeacherService();

  bool _isLoading = false; // Track loading state

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isViewingProgress
            ? 'התקדמות תלמידים'
            : 'מטלות מוגשות'),
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
      body: ListView.builder(
        itemCount: widget.teacher.lessonGradeMap.length,
        itemBuilder: (context, index) {
          final lesson = widget.teacher.lessonGradeMap.keys.elementAt(index);
          final grades = widget.teacher.lessonGradeMap[lesson]!;

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 4.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ExpansionTile(
              tilePadding:
                  const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
              title: Text(
                lesson,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              subtitle: Text(
                'כיתות: ${grades.join(', ')}',
                style: const TextStyle(color: Colors.grey),
              ),
              children: grades.map((grade) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Text('כיתה $grade'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.blueAccent,
                  ),
                  onTap: () async {
                    setState(() {
                      _isLoading = true; // Set loading to true
                    });

                    if (widget.isViewingProgress) {
                      final studentProgress =
                          await _teacherService.fetchStudentsProgress(
                        widget.teacher.school,
                        grade,
                        lesson,
                      );
                      setState(() {
                        _isLoading =
                            false; // Set loading to false after data fetch
                      });

                      // Navigate to StudentProgressPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentProgressPage(
                            grade: grade,
                            studentProgress: studentProgress,
                          ),
                        ),
                      );
                    } else {
                      // Navigate to SubmittedAssignmentsList
                      setState(() {
                        _isLoading = false; // Stop loading if no data is needed
                      });

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmittedAssignmentsList(
                            school: widget.teacher.school,
                            grade: grade.toString(),
                            lesson: lesson,
                            teachername: widget.teacher.name,
                          ),
                        ),
                      );
                    }
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
      // Show a loading spinner while data is being fetched
      floatingActionButton: _isLoading
          ? const CircularProgressIndicator() // Show a loading spinner
          : Container(),
    );
  }
}
