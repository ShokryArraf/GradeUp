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
    required String subject,
    required String? link,
  }) async {
    Map<String, dynamic> assignmentData = {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'questions': questions,
      'grade': grade,
      'teacherName': teacherName,
      'subject': subject,
      'link': link,
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

  Future<void> updateAssignment({
    required String lessonId,
    required String assignmentId,
    required String grade,
    required Teacher teacher,
    String? title,
    String? description,
    DateTime? dueDate,
    List<String>? questions,
    int? gradeValue,
    String? subject,
    String? link,
  }) async {
    // Reference the assignment document
    final assignmentRef = _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade)
        .collection('lessons')
        .doc(lessonId)
        .collection('assignments')
        .doc(assignmentId);

    // Prepare the update data
    Map<String, dynamic> updatedData = {};

    if (title != null) updatedData['title'] = title;
    if (description != null) updatedData['description'] = description;
    if (dueDate != null) updatedData['dueDate'] = dueDate.toIso8601String();
    if (questions != null) updatedData['questions'] = questions;
    if (gradeValue != null) updatedData['grade'] = gradeValue;
    if (subject != null) updatedData['subject'] = subject;
    if (link != null) updatedData['link'] = link;

    // Update the assignment document
    await assignmentRef.update(updatedData);

    // Fetch students assigned this assignment
    final studentsSnapshot = await _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade)
        .collection('students')
        .where('enrolledLessons', arrayContains: lessonId)
        .get();

    // Reflect updates in each student's assignmentsToDo
    for (var student in studentsSnapshot.docs) {
      final studentAssignmentRef = _firestore
          .collection('schools')
          .doc(teacher.school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(student.id)
          .collection('assignmentsToDo')
          .doc(assignmentId);

      Map<String, dynamic> studentUpdateData = {};

      // Update fields if they are relevant to students
      if (dueDate != null) {
        studentUpdateData['dueDate'] = dueDate.toIso8601String();
      }
      if (title != null) studentUpdateData['title'] = title;

      if (studentUpdateData.isNotEmpty) {
        await studentAssignmentRef.update(studentUpdateData);
      }
    }
  }
}
