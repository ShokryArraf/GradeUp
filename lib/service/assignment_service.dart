import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/teacher.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new assignment and return a reference to it
  Future<DocumentReference> createAssignment(
    String lessonId, {
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> questions,
    required int grade,
    required String teacherName,
    required Teacher teacher,
  }) async {
    Map<String, dynamic> assignmentData = {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'questions': questions,
      'grade': grade,
      'teacherName': teacherName, // Include teacherName in the data
    };

    return await _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonId)
        .collection('assignments')
        .add(assignmentData);
  }

  // Assign an assignment to all students enrolled in a particular lesson
  Future<void> assignToEnrolledStudents(String lessonId, String assignmentId,
      String grade, Teacher teacher) async {
    final studentsSnapshot = await _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade)
        .collection('students')
        .where('enrolledLessons', arrayContains: lessonId)
        .get();

    for (var student in studentsSnapshot.docs) {
      await _firestore
          .collection('schools')
          .doc(teacher.school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(student.id)
          .collection('assignmentsToDo')
          .doc(assignmentId)
          .set({
        'status': 'assigned',
        'score': null,
        'submissionDate': null,
      });
    }
  }

  Future<List<Map<String, dynamic>>> fetchAssignments({
    required String lessonName,
    required int grade,
    required Teacher teacher,
  }) async {
    // Reference the specific lesson document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName);

    // Fetch the assignments subcollection for this lesson
    final assignmentsSnapshot = await lessonRef.collection('assignments').get();

    // Filter assignments based on teacherName and grade
    return assignmentsSnapshot.docs
        .where((doc) =>
            doc.data()['teacherName'] == teacher.name &&
            doc.data()['grade'] == grade)
        .map((doc) => {
              'id': doc.id, // Assignment ID
              'lessonName': lessonName, // Add lesson name
              ...doc.data(), // Include all fields in the assignment
            })
        .toList();
  }

  Future<void> deleteAssignment(String lessonName, String assignmentId,
      String school, String grade) async {
    await _firestore
        .collection('schools')
        .doc(school)
        .collection('grades')
        .doc(grade)
        .collection('lessons')
        .doc(lessonName)
        .collection('assignments')
        .doc(assignmentId)
        .delete();

    final studentsSnapshot = await _firestore
        .collection('schools')
        .doc(school)
        .collection('grades')
        .doc(grade)
        .collection('students')
        .where('enrolledLessons', arrayContains: lessonName)
        .get();

    for (var student in studentsSnapshot.docs) {
      await _firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(student.id)
          .collection('assignmentsToDo')
          .doc(assignmentId)
          .delete();
    }
  }
}
