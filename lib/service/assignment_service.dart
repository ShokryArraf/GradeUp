import 'package:cloud_firestore/cloud_firestore.dart';

class AssignmentService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Fetch all lessons a teacher is assigned to
  Future<List<Map<String, dynamic>>> getAssignedLessons(
      String teacherId) async {
    final teacherDoc =
        await firestore.collection('teachers').doc(teacherId).get();
    List<dynamic> assignedLessons = teacherDoc['assignedLessons'] ?? [];

    List<Map<String, dynamic>> lessons = [];
    for (var lessonId in assignedLessons) {
      final lessonDoc =
          await firestore.collection('lessons').doc(lessonId).get();
      lessons.add({'id': lessonDoc.id, 'title': lessonDoc['title']});
    }
    return lessons;
  }

  // Update createAssignment to return DocumentReference for the new assignment
  Future<DocumentReference> createAssignment(
      String lessonId, Map<String, dynamic> assignmentData) async {
    return await firestore
        .collection('lessons')
        .doc(lessonId)
        .collection('assignments')
        .add(assignmentData);
  }

  // Assign assignment to all students enrolled in a particular lesson
  Future<void> assignToEnrolledStudents(
      String lessonId, String assignmentId) async {
    final studentsSnapshot = await firestore
        .collection('students')
        .where('enrolledLessons', arrayContains: lessonId)
        .get();

    for (var student in studentsSnapshot.docs) {
      await firestore
          .collection('students')
          .doc(student.id)
          .collection('progress')
          .doc(lessonId)
          .collection('assignments')
          .doc(assignmentId)
          .set({
        'status': 'assigned',
        'score': null,
        'submissionDate': null,
      });
    }
  }
}
