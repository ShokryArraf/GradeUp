import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/teacher.dart';

class StudentProgressView extends StatelessWidget {
  final Teacher teacher;

  const StudentProgressView({super.key, required this.teacher});

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    final List<int> teachingGrades = teacher.teachingGrades;
    final List<String> assignedLessons = teacher.assignedLessons;

    // Fetch userprogress documents with matching grades
    final querySnapshot = await firestore.collection('userprogress').get();

    List<Map<String, dynamic>> students = [];
    for (var doc in querySnapshot.docs) {
      final data = doc.data();
      final int grade = data['grade'] ?? 0;

      if (teachingGrades.contains(grade)) {
        // Fetch lessons from the `gameLesson` subcollection
        final gameLessonCollection = firestore
            .collection('userprogress')
            .doc(doc.id)
            .collection('gameLesson');

        final gameLessonsSnapshot = await gameLessonCollection.get();

        for (var lessonDoc in gameLessonsSnapshot.docs) {
          final lessonData = lessonDoc.data();
          final String lessonName = lessonDoc.id;

          if (assignedLessons.contains(lessonName)) {
            students.add({
              'id': doc.id,
              'name': lessonData['name'],
              'grade': grade,
              'lesson': lessonName,
              'level': lessonData['level'] ?? 'N/A',
              'rightAnswers': lessonData['rightAnswers'] ?? 0,
              'wrongAnswers': lessonData['wrongAnswers'] ?? 0,
              'points': lessonData['points'] ?? 0,
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
                  // trailing: IconButton(
                  //   icon: const Icon(Icons.more_vert),
                  //   onPressed: () {
                  //     // Optional: Add options like "View Detailed Progress"
                  //   },
                  // ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
