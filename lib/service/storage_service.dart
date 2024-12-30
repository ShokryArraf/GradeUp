import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  // Uploads an image to Firebase Storage and returns the download URL
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
    } catch (_) {
      throw Exception('Error uploading image.');
    }
  }

  // Uploads a file (PDF, Word) to Firebase Storage and returns the download URL
  Future<String?> uploadFile(File file, String fileName) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instanceFor(
        app: Firebase.app(),
        bucket: 'gs://grade-up-project1.firebasestorage.app',
      );
      final storageRef = storage.ref().child('uploads/$fileName');

      final uploadTask = storageRef.putFile(file);
      await uploadTask;
      final downloadURL = await storageRef.getDownloadURL();
      return downloadURL;
    } catch (_) {
      throw Exception('Error uploading file.');
    }
  }
}
