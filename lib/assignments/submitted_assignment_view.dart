import 'package:flutter/material.dart';
import 'package:grade_up/assignments/submitted_assignment_list.dart';
import 'package:grade_up/models/teacher.dart';

class ViewSubmittedAssignmentsView extends StatelessWidget {
  final Teacher teacher;

  const ViewSubmittedAssignmentsView({super.key, required this.teacher});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Submitted Assignments'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )),
      body: ListView.builder(
        itemCount: teacher.lessonGradeMap.length,
        itemBuilder: (context, index) {
          final lesson = teacher.lessonGradeMap.keys.elementAt(index);
          final grades = teacher.lessonGradeMap[lesson]!;

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
                'Grades: ${grades.join(', ')}',
                style: const TextStyle(color: Colors.grey),
              ),
              children: grades.map((grade) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                  title: Text('Grade $grade'),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: Colors.blueAccent,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SubmittedAssignmentsList(
                          school: teacher.school,
                          grade: grade.toString(),
                          lesson: lesson,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
