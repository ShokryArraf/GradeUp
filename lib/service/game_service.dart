import 'package:cloud_firestore/cloud_firestore.dart';

class GameService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  get questions => null;

  // Fetch questions for a specific lesson
  Future<List<Map<String, dynamic>>> fetchQuestions(String lesson) async {
    try {
      final questionsSnapshot = await _firestore
          .collection('lessons')
          .doc(lesson)
          .collection('questions')
          .get();

      return questionsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching questions: $e");
      return [];
    }
  }

  // Update user progress
  Future<void> updateUserProgress(
      String userId, Map<String, dynamic> progress) async {
    try {
      await _firestore
          .collection('userprogress')
          .doc(userId)
          .set(progress, SetOptions(merge: true));
    } catch (e) {
      print("Error updating user progress: $e");
    }
  }

  // Fetch user progress
  Future<Map<String, dynamic>?> fetchUserProgress(String userId) async {
    try {
      final userProgressSnapshot =
          await _firestore.collection('userprogress').doc(userId).get();

      if (userProgressSnapshot.exists) {
        return userProgressSnapshot.data();
      }
      return null;
    } catch (e) {
      print("Error fetching user progress: $e");
      return null;
    }
  }

  // Fetch user progress including question level
  Future<Map<String, dynamic>> getUserProgress(String userId) async {
    final userProgressDoc = await FirebaseFirestore.instance
        .collection('userprogress')
        .doc(userId)
        .get();

    if (userProgressDoc.exists) {
      return userProgressDoc.data()!;
    } else {
      throw Exception("User progress not found.");
    }
  }

  // Fetch questions filtered by lesson and question level
  Future<List<Map<String, dynamic>>> fetchQuestionsByLevel(
      String lesson, String questionLevel) async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('lessons')
        .doc(lesson)
        .collection('questions')
        .where('questionLevel', isEqualTo: questionLevel)
        .get();

    return querySnapshot.docs.map((doc) => doc.data()).toList();
  }
}









// import 'package:cloud_firestore/cloud_firestore.dart';

// class GameService {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   List<Map<String, dynamic>> _questions =
//       []; // Private field to store questions

//   // Getter to access questions
//   List<Map<String, dynamic>> get questions => _questions;

//   // Fetch questions for a specific lesson
//   Future<void> fetchQuestions(String lesson) async {
//     try {
//       final questionsSnapshot = await _firestore
//           .collection('lessons')
//           .doc(lesson)
//           .collection('questions')
//           .get();

//       _questions = questionsSnapshot.docs
//           .map((doc) => doc.data() as Map<String, dynamic>)
//           .toList();
//     } catch (e) {
//       print("Error fetching questions: $e");
//     }
//   }

//   // Update user progress
//   Future<void> updateUserProgress(
//       String userId, Map<String, dynamic> progress) async {
//     try {
//       await _firestore
//           .collection('userprogress')
//           .doc(userId)
//           .set(progress, SetOptions(merge: true));
//     } catch (e) {
//       print("Error updating user progress: $e");
//     }
//   }

//   // Fetch user progress
//   Future<Map<String, dynamic>?> fetchUserProgress(String userId) async {
//     try {
//       final userProgressSnapshot =
//           await _firestore.collection('userprogress').doc(userId).get();

//       if (userProgressSnapshot.exists) {
//         return userProgressSnapshot.data() as Map<String, dynamic>;
//       }
//       return null;
//     } catch (e) {
//       print("Error fetching user progress: $e");
//       return null;
//     }
//   }
// }
