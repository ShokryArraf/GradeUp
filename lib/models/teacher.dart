class Teacher {
  final String teacherId;
  final String name;
  final Map<String, List<int>> lessonGradeMap; // Map lessons to grades
  late final String school;

  Teacher({
    required this.teacherId,
    required this.name,
    required this.lessonGradeMap,
  });

  // Factory constructor to create a Teacher instance from Firestore data
  factory Teacher.fromFirestore(Map<String, dynamic> data, String teacherId) {
    return Teacher(
      teacherId: teacherId,
      name: data['name'] ?? '',
      lessonGradeMap: (data['teachingLessons'] as Map<String, dynamic>? ?? {})
          .map((key, value) =>
              MapEntry(key, List<int>.from(value ?? []))), // Parse grades
    );
  }

  // Convert a Teacher instance to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'teachingLessons':
          lessonGradeMap.map((key, value) => MapEntry(key, value)),
    };
  }
}
