import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId = FirebaseAuth.instance.currentUser!.uid;

  // Save game progress
  Future<void> saveGameProgress(int score, String badge) async {
    await _db.collection('users').doc(userId).set({
      'score': score,
      'badges': FieldValue.arrayUnion([badge]),
    }, SetOptions(merge: true));
  }

  // Get user badges
  Future<List<String>> getUserBadges() async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    // Cast the data to Map<String, dynamic>
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return data?['badges']?.cast<String>() ?? [];
  }

  // Get user score
  Future<int> getUserScore() async {
    DocumentSnapshot doc = await _db.collection('users').doc(userId).get();
    // Cast the data to Map<String, dynamic>
    Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
    return data?['score'] ?? 0;
  }
}
