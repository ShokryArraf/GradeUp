import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/student.dart';

class StudentCoursesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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
}
