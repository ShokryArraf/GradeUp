import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

class StudentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<Student?> getStudent(String schoolName, String grade) async {
    final user = _auth.currentUser;
    if (user == null) return null;

    try {
      final studentDoc = await _firestore
          .collection('schools')
          .doc(schoolName)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(user.uid)
          .get();

      if (studentDoc.exists) {
        final studentData = studentDoc.data();
        if (studentData != null) {
          final student = Student.fromFirestore(studentData, user.uid);
          student.school = schoolName;
          return student;
        }
      }
    } catch (_) {
      throw FailedToLoadStudentDataException();
    }
    return null;
  }

  Future<double> getStudentProgress(Student student) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('schools')
          .doc(student.school)
          .collection('grades')
          .doc(student.grade.toString())
          .collection('students')
          .doc(student.studentId)
          .collection('assignmentsToDo')
          .get();

      final totalAssignments = assignmentsSnapshot.size;
      final completedAssignments = assignmentsSnapshot.docs
          .where((doc) => doc.data()['status'] == 'submitted')
          .length;

      return totalAssignments > 0
          ? completedAssignments / totalAssignments
          : 0.0;
    } catch (_) {
      throw ErrorFetchingStudentProgress;
    }
  }

  Future<List<Map<String, dynamic>>> fetchMaterials({
    required String lessonName,
    required Student student,
  }) async {
    // Reference the specific lesson document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(student.school)
        .collection('grades')
        .doc(student.grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials');

    final querySnapshot = await lessonRef.orderBy('index').get();

    // Return a list of maps with 'id' and other material data
    return querySnapshot.docs.map((doc) {
      return {
        'id': doc.id, // Include the document ID
        ...doc.data(), // Include the other fields in the material
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchContent(
      {required String lessonName,
      required Student student,
      required String materialID}) async {
    // Reference the specific content document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(student.school)
        .collection('grades')
        .doc(student.grade.toString())
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

  Future<List<Map<String, dynamic>>> fetchBlocks(
      {required String lessonName,
      required Student student,
      required String materialID,
      required String contentID}) async {
    // Reference the specific content document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(student.school)
        .collection('grades')
        .doc(student.grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID)
        .collection('content')
        .doc(contentID);

    // Fetch the materials subcollection for this lesson, ordered by 'timestamp'
    final blockSnapshot = await lessonRef
        .collection('blocks')
        .orderBy('timestamp', descending: false) // Ascending order
        .get();

    return blockSnapshot.docs
        .map((doc) => {
              'id': doc.id, // Assignment ID
              ...doc.data(), // Include all fields in the content
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchAssignments({
    required String lessonName,
    required Student student,
  }) async {
    // Reference the specific lesson document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(student.school)
        .collection('grades')
        .doc(student.grade.toString())
        .collection('lessons')
        .doc(lessonName);

    // Fetch the assignments subcollection for this lesson
    final assignmentsSnapshot = await lessonRef.collection('assignments').get();

    // Filter assignments based on teacherName and grade
    return assignmentsSnapshot.docs
        .map((doc) => {
              'id': doc.id, // Assignment ID
              'lessonName': lessonName, // Add lesson name
              ...doc.data(), // Include all fields in the assignment
            })
        .toList();
  }

  // Future<Map<String, dynamic>> getAssignmentStatusAndScore(
  //   required String assignmentId, {
  //   required Student student,
  // }) async {
  //   try {
  //     final doc = await _firestore
  //         .collection('schools')
  //         .doc(student.school)
  //         .collection('grades')
  //         .doc(student.grade.toString())
  //         .collection('students')
  //         .doc(student.studentId)
  //         .collection('assignmentsToDo')
  //         .doc(assignmentId)
  //         .get();

  //     return doc.exists ? doc.data() ?? {} : {};
  //   } catch (_) {
  //     throw FailedToFetchAssignmentStatusAndScore;
  //   }
  // }

  Future<Map<String, dynamic>> getAssignmentStatusAndScore({
    required String assignmentId,
    required Student student,
  }) async {
    try {
      final doc = await _firestore
          .collection('schools')
          .doc(student.school)
          .collection('grades')
          .doc(student.grade.toString())
          .collection('students')
          .doc(student.studentId)
          .collection('assignmentsToDo')
          .doc(assignmentId)
          .get();

      return doc.exists ? doc.data() ?? {} : {};
    } catch (_) {
      throw FailedToFetchAssignmentStatusAndScore;
    }
  }

  Future<Map<String, dynamic>> fetchStudentProgress({
    required String studentId,
    required String school,
    required String grade,
  }) async {
    try {
      final assignmentsSnapshot = await _firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(studentId)
          .collection('assignmentsToDo')
          .get();

      int totalAssignments = 0;
      int completedAssignments = 0;
      double totalScore = 0.0;
      int scoredAssignments = 0;
      Map<String, double> lessonScores = {};

      for (var doc in assignmentsSnapshot.docs) {
        final data = doc.data();
        totalAssignments++;

        if (data['status'] == 'submitted') {
          completedAssignments++;
        }

        if (data['score'] != null) {
          final score = data['score'] as int;
          totalScore += score;
          scoredAssignments++;
          final lesson = data['lesson'] ?? 'General';
          lessonScores[lesson] = (lessonScores[lesson] ?? 0.0) + score;
        }
      }

      if (scoredAssignments > 0) {
        totalScore /= scoredAssignments;
        lessonScores.updateAll(
          (lesson, score) => score / scoredAssignments,
        );
      }

      return {
        'totalAssignments': totalAssignments,
        'completedAssignments': completedAssignments,
        'pendingAssignments': totalAssignments - completedAssignments,
        'averageScore': totalScore,
        'lessonScores': lessonScores,
      };
    } catch (_) {
      throw ErrorFetchingStudentProgress();
    }
  }
}
