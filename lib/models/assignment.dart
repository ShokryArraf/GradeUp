// assignment.dart
class Assignment {
  final String status;
  final int score;
  final String submissionDate;

  Assignment({
    required this.status,
    required this.score,
    required this.submissionDate,
  });

  // Factory constructor to create an Assignment instance from Firestore data
  factory Assignment.fromFirestore(Map<String, dynamic> data) {
    return Assignment(
      status: data['status'] ?? '',
      score: data['score'] ?? 0,
      submissionDate: data['submissionDate'] ?? '',
    );
  }

  // Convert an Assignment instance to a map for Firestore storage
  Map<String, dynamic> toFirestore() {
    return {
      'status': status,
      'score': score,
      'submissionDate': submissionDate,
    };
  }
}
