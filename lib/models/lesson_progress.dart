// lesson_progress.dart
import 'package:grade_up/models/assignment.dart';

class LessonProgress {
  final String lessonTitle;
  final Map<String, Assignment> assignments;

  LessonProgress({
    required this.lessonTitle,
    required this.assignments,
  });

  // Factory constructor to create a LessonProgress instance from Firestore data
  factory LessonProgress.fromFirestore(Map<String, dynamic> data) {
    Map<String, Assignment> assignments = {};
    if (data['assignments'] != null) {
      data['assignments'].forEach((assignmentId, assignmentData) {
        assignments[assignmentId] = Assignment.fromFirestore(assignmentData);
      });
    }

    return LessonProgress(
      lessonTitle: data['lessonTitle'] ?? '',
      assignments: assignments,
    );
  }

  // Convert a LessonProgress instance to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'lessonTitle': lessonTitle,
      'assignments':
          assignments.map((key, value) => MapEntry(key, value.toFirestore())),
    };
  }
}
