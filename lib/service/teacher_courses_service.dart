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

  Future<DocumentReference> addBlock(String lessonName,
      {required int grade,
      required Teacher teacher,
      required String materialID,
      required String contentID,
      required String type,
      required String data}) async {
    Map<String, dynamic> blockData = {'type': type, 'data': data};

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
        .doc(teacher.school)
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

  Future<List<Map<String, dynamic>>> fetchBlocks(
      {required String lessonName,
      required int grade,
      required Teacher teacher,
      required String materialID,
      required String contentID}) async {
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
}
