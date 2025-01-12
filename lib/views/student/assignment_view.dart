import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/student_service.dart';
import 'package:grade_up/utilities/format_date.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/student/assignment_detail_view.dart';

class AssignmentsView extends StatefulWidget {
  final Student student;
  final String lesson;

  const AssignmentsView(
      {super.key, required this.student, required this.lesson});

  @override
  State<AssignmentsView> createState() => _AssignmentsViewState();
}

class _AssignmentsViewState extends State<AssignmentsView> {
  final _coursesService = StudentService();
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
    } catch (_) {
      // Handle error
      showErrorDialog(context, 'שגיאה בטעינת מטלות');
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
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
                        'אין מטלות זמינות כרגע',
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
                            future: _coursesService.getAssignmentStatusAndScore(
                              assignmentId: assignmentId,
                              student: widget.student,
                            ),
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
                              final dueDateStr = assignment['dueDate'] ?? '';
                              final dueDate = dueDateStr.isNotEmpty
                                  ? DateTime.parse(dueDateStr)
                                  : null;
                              final isOverdue = dueDate != null &&
                                  dueDate.isBefore(DateTime.now());
                              final isSubmitted = status == 'submitted';
                              final hasScore = score != 'N/A' && score != null;

                              // Custom indicator icon and text based on status
                              IconData statusIcon;
                              Color statusColor;
                              String statusText;

                              if (isSubmitted && hasScore) {
                                statusIcon =
                                    Icons.star; // Indicates reviewed or scored
                                statusColor = Colors.blue;
                                statusText = 'נבדק';
                              } else if (isSubmitted) {
                                statusIcon =
                                    Icons.check_circle; // Indicates submission
                                statusColor = Colors.green;
                                statusText = 'הוגש';
                              } else if (isOverdue) {
                                statusIcon = Icons.warning; // Indicates overdue
                                statusColor = Colors.red;
                                statusText = 'באיחור';
                              } else {
                                statusIcon =
                                    Icons.access_time; // Indicates pending
                                statusColor = Colors.orange;
                                statusText = 'ממתין';
                              }

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
                                    leading: Icon(statusIcon,
                                        color: statusColor,
                                        size: 40), // Status icon
                                    title: Text(
                                      assignment['title'] ?? 'אין כותרת',
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
                                          'מועד אחרון להגשה: ${formatDueDate(assignment['dueDate'] ?? 'לא צוין')}',
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Row(
                                          children: [
                                            const Text(
                                              'סטטוס: ',
                                              style: TextStyle(
                                                color: Colors.white70,
                                                fontSize: 14,
                                              ),
                                            ),
                                            Text(
                                              statusText,
                                              style: TextStyle(
                                                color: statusColor,
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (hasScore) ...[
                                          const SizedBox(height: 5),
                                          Text(
                                            'ציון: $score',
                                            style: const TextStyle(
                                              color: Colors.white70,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
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
                                            status: statusText,
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
