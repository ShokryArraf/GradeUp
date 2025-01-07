import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

class TeacherService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Teacher?> fetchTeacherData(String schoolName) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final teacherId = user.uid;
      final teacherDoc = await _firestore
          .collection('schools')
          .doc(schoolName)
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        final teacher = Teacher.fromFirestore(teacherDoc.data()!, teacherId);
        teacher.school = schoolName;
        return teacher;
      } else {
        throw FailedToLoadTeacherDataException();
      }
    }
    return null;
  }

  Future<DocumentReference> addMaterial(
    String lessonName, {
    required int grade,
    required Teacher teacher,
    required String title,
  }) async {
    final materialsCollection = _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials');

    // Fetch the current highest index in the materials collection
    final querySnapshot = await materialsCollection
        .orderBy('index', descending: true)
        .limit(1)
        .get();

    int nextIndex = 0; // Default index if no materials exist
    if (querySnapshot.docs.isNotEmpty) {
      nextIndex = querySnapshot.docs.first.data()['index'] + 1;
    }

    // Add the material with the calculated index
    Map<String, dynamic> materialData = {
      'title': title,
      'index': nextIndex, // Add the index for ordering
    };

    return await materialsCollection.add(materialData);
  }

  Future<DocumentReference> addContent(String lessonName,
      {required int grade,
      required Teacher teacher,
      required String materialID,
      required String title}) async {
    Map<String, dynamic> contentData = {
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
        .doc(materialID)
        .collection('content')
        .add(contentData);
  }

  Future<void> addBlock(
      {required String lessonName,
      required int grade,
      required Teacher teacher,
      required String materialID,
      required String contentID,
      required String type,
      required String data,
      required String timestamp,
      String? filename}) async {
    final contentRef = FirebaseFirestore.instance
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID)
        .collection('content')
        .doc(contentID)
        .collection('blocks');

    // Only add 'filename' if the type is pdf, docx, or doc
    final blockData = {
      'type': type,
      'data': data,
      'timestamp': timestamp,
    };

    if (filename != null &&
        (type == 'pdf' || type == 'docx' || type == 'doc')) {
      blockData['filename'] = filename;
    }
    await contentRef.add(blockData);
  }

  Future<List<Map<String, dynamic>>> fetchMaterials({
    required String lessonName,
    required int grade,
    required Teacher teacher,
  }) async {
    final materialsCollection = _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials');

    final querySnapshot = await materialsCollection.orderBy('index').get();

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
      required int grade,
      required Teacher teacher,
      required String materialID}) async {
    // Reference the specific content document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(teacher.school)
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
    required String contentID,
    String orderBy = 'timestamp',
  }) async {
    // Reference the specific content document by its name (ID)
    final lessonRef = _firestore
        .collection('schools')
        .doc(teacher.school)
        .collection('grades')
        .doc(grade.toString())
        .collection('lessons')
        .doc(lessonName)
        .collection('materials')
        .doc(materialID)
        .collection('content')
        .doc(contentID)
        .collection('blocks');

    final querySnapshot = await lessonRef.orderBy(orderBy).get();
    return querySnapshot.docs
        .map((doc) => {
              'id': doc.id, // Assignment ID
              ...doc.data(), // Include all fields in the content
            })
        .toList();
  }

  Future<List<Map<String, dynamic>>> fetchStudentsProgress(
      String school, int grade, String lesson) async {
    try {
      final studentsSnapshot = await _firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade.toString())
          .collection('students')
          .get();

      List<Map<String, dynamic>> studentProgress = [];

      for (var studentDoc in studentsSnapshot.docs) {
        final studentId = studentDoc.id;

        final assignmentsSnapshot = await _firestore
            .collection('schools')
            .doc(school)
            .collection('grades')
            .doc(grade.toString())
            .collection('students')
            .doc(studentId)
            .collection('assignmentsToDo')
            .where('lesson', isEqualTo: lesson)
            .get();

        int totalAssignments = assignmentsSnapshot.size;
        int completedAssignments = assignmentsSnapshot.docs
            .where((doc) => doc.data()['status'] == 'submitted')
            .length;

        studentProgress.add({
          'name': studentDoc.data()['name'] ?? 'Unnamed Student',
          'completed': completedAssignments,
          'total': totalAssignments,
        });
      }

      return studentProgress;
    } catch (_) {
      throw ErrorFetchingStudentProgress();
    }
  }
}
