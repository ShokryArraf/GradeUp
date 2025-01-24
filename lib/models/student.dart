class Student {
  final String studentId;
  final String name;
  final List<String> enrolledLessons;
  final int grade;
  late final String school;

  Student({
    required this.studentId,
    required this.name,
    required this.enrolledLessons,
    required this.grade,
  });

  // Factory constructor to create a Student instance from Firestore data
  factory Student.fromFirestore(Map<String, dynamic> data, String studentId) {
    // Map<String, LessonProgress> progress = {};
    if (data['progress'] != null) {
      data['progress'].forEach((lessonId, lessonData) {});
    }

    return Student(
      studentId: studentId,
      name: data['name'] ?? '',
      enrolledLessons: List<String>.from(data['enrolledLessons'] ?? []),
      grade: data['grade'] ?? 0,
    );
  }

  // Convert a Student instance to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'enrolledLessons': enrolledLessons,
      'grade': grade,
    };
  }
}
