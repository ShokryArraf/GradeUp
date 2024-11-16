class Teacher {
  final String teacherId;
  final String name;
  final List<String> assignedLessons;
  final List<int> teachingGrades;

  Teacher({
    required this.teacherId,
    required this.name,
    required this.assignedLessons,
    required this.teachingGrades,
  });

  // Factory constructor to create a Teacher instance from Firestore data
  factory Teacher.fromFirestore(Map<String, dynamic> data, String teacherId) {
    return Teacher(
      teacherId: teacherId,
      name: data['name'] ?? '',
      assignedLessons: List<String>.from(data['assignedLessons'] ?? []),
      teachingGrades: List<int>.from(
          data['teachingGrades'] ?? []), // Retrieve teachingGrades
    );
  }

  // Convert a Teacher instance to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'assignedLessons': assignedLessons,
      'teachingGrades': teachingGrades,
    };
  }
}
