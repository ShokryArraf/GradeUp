import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/student_courses_service.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/student/assignment_detail_view.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentsView extends StatefulWidget {
  final Student student;
  final String lesson;

  const AssignmentsView(
      {super.key, required this.student, required this.lesson});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  final _coursesService = StudentCoursesService();
  List<Map<String, dynamic>> _assignments = []; // List to hold assignments
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchAndSetAssignments();
  }

  Future<void> _fetchAndSetAssignments() async {
    try {
      final assignments = await _coursesService.fetchAssignments(
        lessonName: widget.lesson,
        student: widget.student,
      );
      setState(() {
        _assignments =
            assignments.reversed.toList(); // Save assignments to the list
        _isLoading = false; // Set loading to false
      });
    } catch (error) {
      // Handle error
      showErrorDialog(context, 'Error fetching assignments');
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  String _formatDueDate(String dueDate) {
    try {
      final parsedDate = DateTime.parse(dueDate);
      return DateFormat('yyyy-MM-dd – kk:mm').format(parsedDate);
    } catch (e) {
      return 'Invalid date';
    }
  }

  Future<Map<String, dynamic>> _getAssignmentStatusAndScore(
      String assignmentId) async {
    final firestore = FirebaseFirestore.instance;
    final studentId = widget.student.studentId;
    final school = widget.student.school;
    final grade = widget.student.grade.toString();

    try {
      final doc = await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(studentId)
          .collection('assignmentsToDo')
          .doc(assignmentId)
          .get();

      if (doc.exists) {
        return doc.data() ?? {};
      }
    } catch (e) {
      // Handle error
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Light background color
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show spinner while loading
          : Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
              child: _assignments.isEmpty
                  ? Center(
                      child: Text(
                        'No assignments available yet!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        // Dynamic list of assignments
                        ..._assignments.map((assignment) {
                          final assignmentId = assignment['id'];
                          return FutureBuilder<Map<String, dynamic>>(
                            future: _getAssignmentStatusAndScore(assignmentId),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }

                              final statusData = snapshot.data ?? {};
                              final status =
                                  statusData['status'] ?? 'Not Submitted';
                              final score = statusData['score'] ?? 'N/A';

                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: Container(
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.teal.shade200,
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 20.0),
                                    title: Text(
                                      assignment['title'] ??
                                          'No Title', // Display assignment title
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Due Date: ${_formatDueDate(assignment['dueDate'] ?? 'Not specified')}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Status: $status',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          'Score: $score',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AssignmentDetailView(
                                            assignment: assignment,
                                            student: widget.student,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                      ],
                    ),
            ),
    );
  }
}
