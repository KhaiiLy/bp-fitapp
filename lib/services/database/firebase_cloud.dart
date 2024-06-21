import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class FirebaseCloud {
  final storage = FirebaseStorage.instance.ref();
  final currentUser = FirebaseAuth.instance.currentUser!;

  Future<void> uploadImage(File img, String roomId) async {
    try {
      String fileName = img.path.split("/").last;
      String timestamp =
          DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final filePath = "$roomId/images/$timestamp-$fileName";
      final uploadRef = storage.child(filePath);
      uploadRef.putFile(img).snapshotEvents.listen((event) async {
        switch (event.state) {
          case TaskState.running:
            debugPrint('uploading image to cloud');
            break;
          case TaskState.paused:
            debugPrint('uploading paused');
            break;
          case TaskState.success:
            debugPrint('image successfully uploaded');
            FirestoreDatabase()
                .sendMessage(roomId, currentUser.uid, filePath, 'image');
            break;
          case TaskState.canceled:
            debugPrint('upload canceled');
            break;
          case TaskState.error:
            debugPrint('error occured when uploading image');
            break;
        }
      });
    } catch (e) {
      debugPrint('Error uploading file: $e');
    }
  }

  Future<String> downloadImage(String filePath) async {
    final imageRef = storage.child(filePath);
    final imageUrl = await imageRef.getDownloadURL();
    return imageUrl;
  }
}
