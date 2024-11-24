import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grade_up/models/student.dart';
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
      Student student) async {
    try {
      // Update or set the data in the 'gameLesson' subcollection
      await firestore
          .collection('schools')
          .doc(student.school)
          .collection('grades')
          .doc(student.grade.toString())
          .collection('students')
          .doc(userId)
          .collection('gameProgress')
          .doc(lesson)
          .set({
        'rightAnswers': rightAnswers,
        'points': points,
        'level': level,
        'wrongAnswers': wrongAnswers,
        'name': student.name,
      }, SetOptions(merge: true)); // Merge with existing data
    } catch (_) {
      throw ErrorUpdatingUserProgressException;
    }
  }

  // Fetch user progress
  Future<Map<String, dynamic>?> fetchUserProgress(
      String userId, String lesson, Student student) async {
    try {
      final userProgressSnapshot = await firestore
          .collection('schools')
          .doc(student.school)
          .collection('grades')
          .doc(student.grade.toString())
          .collection('students')
          .doc(userId)
          .collection('gameProgress')
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

  // Fetch questions filtered by lesson and question level
  Future<List<Map<String, dynamic>>> fetchQuestionsByLevel(
      String lesson, String questionLevel, String school, String grade) async {
    final querySnapshot = await firestore
        .collection('schools')
        .doc(school)
        .collection('grades')
        .doc(grade)
        .collection('lessons')
        .doc(lesson)
        .collection('gameQuestions')
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

  Future<List<Map<String, dynamic>>> fetchLeaderboardData(
      Student student) async {
    try {
      final List<Map<String, dynamic>> data = [];
      QuerySnapshot usersSnapshot = await firestore
          .collection('schools')
          .doc(student.school)
          .collection('grades')
          .doc(student.grade.toString())
          .collection('students')
          .get();

      if (usersSnapshot.docs.isEmpty) {
        throw NoDocumentsFoundException();
      }

      for (var userDoc in usersSnapshot.docs) {
        int totalPoints = 0;

        try {
          QuerySnapshot lessonsSnapshot =
              await userDoc.reference.collection('gameProgress').get();
          if (lessonsSnapshot.docs.isEmpty) {
            continue;
          }

          final name = lessonsSnapshot.docs.first['name'] ??
              'Unknown User'; // Fetch the user's name

          for (var lessonDoc in lessonsSnapshot.docs) {
            final points = lessonDoc['points'];
            totalPoints +=
                points is String ? int.tryParse(points) ?? 0 : points as int;
          }

          data.add({
            'name': name,
            'totalPoints': totalPoints,
          });
        } catch (_) {
          // Handle individual errors gracefully without interrupting the loop
          continue;
        }
      }

      data.sort((a, b) => b['totalPoints'].compareTo(
          a['totalPoints'])); // Sort by total points in descending order

      return data.take(10).toList(); // Return the top 10 users
    } catch (_) {
      throw ErrorFetchingLeaderboardDataException();
    }
  }

  Future<Map<String, Map<String, dynamic>>> fetchAllLessonRewards(
      Student student) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('schools')
          .doc(student.school)
          .collection('grades')
          .doc(student.grade.toString())
          .collection('students')
          .doc(student.studentId)
          .collection('gameProgress')
          .get();

      Map<String, int> pointsData = {};
      Map<String, String> badgesData = {};

      for (var doc in snapshot.docs) {
        String lesson = doc.id;
        int points = doc['points'] ?? 0;
        String badge = getBadge(points);

        pointsData[lesson] = points;
        badgesData[lesson] = badge;
      }

      return {
        'pointsData': pointsData,
        'badgesData': badgesData,
      };
    } catch (_) {
      throw ErrorFetchingLessonsException();
    }
  }

  // Determine badge based on points
  String getBadge(int points) {
    if (points >= 1300) {
      return "images/legend_badge.png";
    } else if (points >= 850) {
      return "images/elite_badge.png";
    } else if (points >= 600) {
      return "images/master_badge.png";
    } else if (points >= 350) {
      return "images/expert_badge.png";
    } else if (points >= 300) {
      return "images/champion_badge.png";
    } else if (points >= 250) {
      return "images/advanced_badge.png";
    } else if (points >= 200) {
      return "images/intermediate_badge.png";
    } else if (points >= 150) {
      return "images/apprentice_badge.png";
    } else if (points >= 50) {
      return "images/beginner_badge.png";
    } else {
      return "images/no_badge.png"; // Default "No Badge" image
    }
  }
}
