import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/teacher.dart';

class TeacherCoursesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<DocumentReference> addMaterial(
    String lessonName, {
    required int grade,
    required Teacher teacher,
    required String title,
  }) async {
    Map<String, dynamic> materialData = {
      'title': title,
    };

    return await _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .add(materialData);
  }

  Future<DocumentReference> addContent(
    String lessonName, {
    required int grade,
    required Teacher teacher,
    required String materialID,
    required String title
  }) async {
    Map<String, dynamic> contentData = {
      'title': title,
    };

    return await _firestore
        .collection('schools')
        .doc('Braude High School')
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID)
        .collection('content')
        .add(contentData);
  }


  Future<DocumentReference> addBlock(
    String lessonName, {
    required int grade,
    required Teacher teacher,
    required String materialID,
    required String contentID,
    required String type,
    required String data
  }) async {
    Map<String, dynamic> blockData = {
      'type': type,
      'data': data
    };

    return await _firestore
        .collection('schools')
        .doc('Braude High School')
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID)
        .collection('content')
        .doc(contentID)
        .collection('blocks')
        .add(blockData);
  }

    Future<List<Map<String, dynamic>>> fetchMaterials({
    required String lessonName,
    required int grade,
    required Teacher teacher,
  }) async {
    // Reference the specific lesson document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc('Braude High School')
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName);

    // Fetch the materials subcollection for this lesson
    final materialsSnapshot = await lessonRef.collection('materials').get();

    // Filter assignments based on teacherName and grade
    return materialsSnapshot.docs
        .map((doc) => {
              'id': doc.id, // Assignment ID
              ...doc.data(), // Include all fields in the assignment
            })
        .toList();
  }


Future<List<Map<String, dynamic>>> fetchContent({
    required String lessonName,
    required int grade,
    required Teacher teacher,
    required String materialID
  }) async {
    // Reference the specific content document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc('Braude High School')
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID);

    // Fetch the materials subcollection for this lesson
    final contentSnapshot = await lessonRef.collection('content').get();

    return contentSnapshot.docs
        .map((doc) => {
              'id': doc.id, // Assignment ID
              ...doc.data(), // Include all fields in the content
            })
        .toList();
  }

Future<List<Map<String, dynamic>>> fetchBlocks({
    required String lessonName,
    required int grade,
    required Teacher teacher,
    required String materialID,
    required String contentID
  }) async {
    // Reference the specific content document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc('Braude High School')
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID)
        .collection('content')
        .doc(contentID);

    // Fetch the materials subcollection for this lesson
    final blockSnapshot = await lessonRef.collection('blocks').get();

    return blockSnapshot.docs
        .map((doc) => {
              'id': doc.id, // Assignment ID
              ...doc.data(), // Include all fields in the content
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
    updatedData['link'] = link;

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

