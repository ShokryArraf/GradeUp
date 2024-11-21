import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import '../models/teacher.dart';

class AssignmentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> getAssignedLessons(Teacher teacher) async {
    try {
      // Adjust the path according to your Firestore structure
      final snapshot = await _firestore
          .collection('teachers')
          .doc(teacher.teacherId)
          .collection('assignedLessons')
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.map((doc) {
          return {
            'id': doc.id,
            'title': doc['title'] ?? 'Untitled Lesson',
          };
        }).toList();
      } else {
        return []; // Empty list if no assigned lessons
      }
    } catch (e) {
      throw ErrorFetchingAssignedLessonsException;
    }
  }

  // Create a new assignment and return a reference to it
  Future<DocumentReference> createAssignment(
    String lessonId, {
    required String title,
    required String description,
    required DateTime dueDate,
    required List<String> questions,
    required int grade,
    required String teacherName,
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
        .collection('lessons1')
        .doc(lessonId)
        .collection('assignments')
        .add(assignmentData);
  }

  // Assign an assignment to all students enrolled in a particular lesson
  Future<void> assignToEnrolledStudents(
      String lessonId, String assignmentId) async {
    final studentsSnapshot = await _firestore
        .collection('students')
        .where('enrolledLessons', arrayContains: lessonId)
        .get();

    for (var student in studentsSnapshot.docs) {
      await _firestore
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

  Future<List<Map<String, dynamic>>> fetchAssignments({
    required String teacherName,
    required String lessonName,
    required int grade,
  }) async {
    // Reference the specific lesson document by its name (ID)
    final lessonRef = _firestore.collection('lessons1').doc(lessonName);

    // Fetch the assignments subcollection for this lesson
    final assignmentsSnapshot = await lessonRef.collection('assignments').get();

    // Filter assignments based on teacherName and grade
    return assignmentsSnapshot.docs
        .where((doc) =>
            doc.data()['teacherName'] == teacherName &&
            doc.data()['grade'] == grade)
        .map((doc) => {
              'id': doc.id, // Assignment ID
              'lessonName': lessonName, // Add lesson name
              ...doc.data(), // Include all fields in the assignment
            })
        .toList();
  }

  Future<void> deleteAssignment(String lessonName, String assignmentId) async {
    await _firestore
        .collection('lessons1')
        .doc(lessonName)
        .collection('assignments')
        .doc(assignmentId)
        .delete();
  }
}
