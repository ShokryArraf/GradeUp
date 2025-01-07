import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

class SubmissionService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> fetchSubmissionDetails({
    required String schoolId,
    required String gradeId,
    required String studentId,
    required String assignmentId,
  }) async {
    try {
      final submissionRef = _firestore
          .collection('schools')
          .doc(schoolId)
          .collection('grades')
          .doc(gradeId)
          .collection('students')
          .doc(studentId)
          .collection('assignmentsToDo')
          .doc(assignmentId);

      final docSnapshot = await submissionRef.get();

      if (docSnapshot.exists) {
        return docSnapshot.data();
      }
    } catch (_) {
      throw ErrorFetchingSubmissionDetails;
    }
    return null;
  }
}
