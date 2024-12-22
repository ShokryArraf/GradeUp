import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseService {
  Future<String?> uploadImage(File image) async {
    try {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      FirebaseStorage storage = FirebaseStorage.instanceFor(
        app: Firebase.app(),
        bucket: 'gs://grade-up-project1.firebasestorage.app',
      );
      final storageRef = storage.ref().child('uploads/$fileName');

      final uploadTask = storageRef.putFile(image);
      await uploadTask;
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
}
