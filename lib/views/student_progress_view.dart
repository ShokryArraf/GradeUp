import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/teacher.dart';

class StudentProgressView extends StatelessWidget {
  final Teacher teacher;

  const StudentProgressView({super.key, required this.teacher});

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;
    final List<Map<String, dynamic>> students = [];

    // Loop through each lesson the teacher teaches and its corresponding grades
    for (var entry in teacher.lessonGradeMap.entries) {
      final String lesson = entry.key; // The lesson name
      final List<int> grades = entry.value; // The list of grades for the lesson

      for (var grade in grades) {
        // Fetch all students in the grade
        final studentsSnapshot = await firestore
            .collection('schools')
            .doc(teacher.school)
            .collection('grades')
            .doc(grade.toString())
            .collection('students')
            .get();

        for (var studentDoc in studentsSnapshot.docs) {
          final studentData = studentDoc.data();

          // Fetch the game progress for the specific lesson
          final gameProgressSnapshot = await studentDoc.reference
              .collection('gameProgress')
              .doc(lesson)
              .get();

          if (gameProgressSnapshot.exists) {
            final progressData = gameProgressSnapshot.data();

            // Add the student's progress for the lesson
            students.add({
              'id': studentDoc.id,
              'name': studentData['name'] ?? 'Unknown', // Student's name
              'grade': grade, // Grade
              'lesson': lesson, // Lesson
              'level': progressData?['level'] ?? 'N/A', // Game level
              'rightAnswers':
                  progressData?['rightAnswers'] ?? 0, // Right answers
              'wrongAnswers':
                  progressData?['wrongAnswers'] ?? 0, // Wrong answers
              'points': progressData?['points'] ?? 0, // Total points
            });
          }
        }
      }
    }

    return students;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Progress View',
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
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchStudents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!;
          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8.0),
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      student['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                  title: Text(
                    '${student['name']} - Grade ${student['grade']}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Lesson: ${student['lesson']}'),
                      Text('Level: ${student['level']}'),
                      Text('Points: ${student['points']}'),
                      Text('Right Answers: ${student['rightAnswers']}'),
                      Text('Wrong Answers: ${student['wrongAnswers']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
