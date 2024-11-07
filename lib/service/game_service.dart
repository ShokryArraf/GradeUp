import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

class GameService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  get questions => null;

  Future<void> addQuestion(
      String lesson, Map<String, dynamic> questionData) async {
    try {
      await firestore
          .collection('lessons')
          .doc(lesson)
          .collection('questions')
          .add(questionData);
    } catch (_) {
      throw FailedToAddQuestion;
    }
  }

  // Fetch questions for a specific lesson
  Future<List<Map<String, dynamic>>> fetchQuestions(String lesson) async {
    try {
      final questionsSnapshot = await firestore
          .collection('lessons')
          .doc(lesson)
          .collection('questions')
          .get();

      return questionsSnapshot.docs.map((doc) => doc.data()).toList();
    } catch (_) {
      throw ErrorFetchingQuestionsException;
    }
  }

  // Update user progress
  Future<void> updateUserProgress(String userId, String lesson,
      int rightAnswers, int points, int level) async {
    try {
      await firestore
          .collection('userprogress')
          .doc(userId)
          .collection('gameLesson')
          .doc(lesson)
          .set({
        'rightAnswers': rightAnswers,
        'points': points,
        'level': level,
      }, SetOptions(merge: true)); // Merge with existing data
    } catch (_) {
      throw ErrorUpdatingUserProgressException();
    }
  }

  // Fetch user progress
  Future<Map<String, dynamic>?> fetchUserProgress(
      String userId, String lesson) async {
    try {
      final userProgressSnapshot = await firestore
          .collection('userprogress')
          .doc(userId)
          .collection('gameLesson')
          .doc(lesson)
          .get();

      if (userProgressSnapshot.exists) {
        return userProgressSnapshot.data();
      }
      return null;
    } catch (_) {
      throw ErrorFetchingUserProgressException;
    }
  }

  // Fetch user progress including question level
  Future<Map<String, dynamic>> getUserProgress(
      String userId, String lesson) async {
    final userProgressDoc = await FirebaseFirestore.instance
        .collection('userprogress')
        .doc(userId)
        .collection('gameLesson')
        .doc(lesson)
        .get();

    if (userProgressDoc.exists) {
      return userProgressDoc.data()!;
    } else {
      throw UserProgressNotFoundException;
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
