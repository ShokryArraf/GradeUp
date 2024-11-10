// student.dart
import 'package:grade_up/models/lesson_progress.dart';

class Student {
  final String studentId;
  final String name;
  final List<String> enrolledLessons;
  final Map<String, LessonProgress> progress;

  Student({
    required this.studentId,
    required this.name,
    required this.enrolledLessons,
    required this.progress,
  });

  // Factory constructor to create a Student instance from Firestore data
  factory Student.fromFirestore(Map<String, dynamic> data, String studentId) {
    Map<String, LessonProgress> progress = {};
    if (data['progress'] != null) {
      data['progress'].forEach((lessonId, lessonData) {
        progress[lessonId] = LessonProgress.fromFirestore(lessonData);
      });
    }

    return Student(
      studentId: studentId,
      name: data['name'] ?? '',
      enrolledLessons: List<String>.from(data['enrolledLessons'] ?? []),
      progress: progress,
    );
  }

  // Convert a Student instance to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'enrolledLessons': enrolledLessons,
      'progress':
          progress.map((key, value) => MapEntry(key, value.toFirestore())),
    };
  }
}
