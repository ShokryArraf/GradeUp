import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';

class GameService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  get questions => null;

  Future<void> addQuestion(String lesson, Map<String, dynamic> questionData,
      String school, String grade) async {
    try {
      await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('lessons')
          .doc(lesson)
          .collection('gameQuestions')
          .add(questionData);
    } catch (_) {
      throw FailedToAddQuestionException;
    }
  }

// Fetch questions for a specific lesson
  Future<List<Map<String, dynamic>>> fetchQuestions(
      String lesson, String school, String grade) async {
    try {
      final questionsSnapshot = await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('lessons')
          .doc(lesson)
          .collection('gameQuestions')
          .get();

      // Map each document to its data and add the documentID to the map
      return questionsSnapshot.docs.map((doc) {
        var questionData = doc.data();
        questionData['id'] = doc.id; // Add document ID to each question
        return questionData;
      }).toList();
    } catch (_) {
      throw ErrorFetchingQuestionsException();
    }
  }

  Future<void> updateUserProgress(
      String userId,
      String lesson,
      int rightAnswers,
      int points,
      int level,
      int wrongAnswers,
      studentName) async {
    try {
      // Ensure the parent document in 'userprogress' exists with a placeholder field
      await firestore.collection('userprogress').doc(userId).set({
        'exists':
            true, // Placeholder field to make the document visible in queries
      }, SetOptions(merge: true));

      // Update or set the data in the 'gameLesson' subcollection
      await firestore
          .collection('userprogress')
          .doc(userId)
          .collection('gameLesson')
          .doc(lesson)
          .set({
        'rightAnswers': rightAnswers,
        'points': points,
        'level': level,
        'wrongAnswers': wrongAnswers,
        'name': studentName,
      }, SetOptions(merge: true)); // Merge with existing data
    } catch (_) {
      throw ErrorUpdatingUserProgressException;
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

  Future<void> deleteQuestion(
      String lesson, String questionId, String school, String grade) async {
    try {
      await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('lessons')
          .doc(lesson)
          .collection('gameQuestions')
          .doc(questionId)
          .delete();
    } catch (_) {
      throw FailedToAddQuestionException;
    }
  }
}
