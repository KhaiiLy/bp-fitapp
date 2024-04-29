import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitapp/data/chat/chat_room.dart';
import 'package:fitapp/data/chat/message.dart';

import 'package:fitapp/data/workout/exercise.dart';
import 'package:fitapp/services/database/local_preferences.dart';
import '../../data/workout/workout.dart';
import '../../data/workout/sets.dart';
import '../../data/users/app_user.dart';

class FirestoreDatabase {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  /*
    USERS
  */
  Future<void> addNewRegistered(AppUser appUser) async {
    try {
      await db.collection('users').doc(appUser.uid).set(appUser.toMap());
    } catch (error) {
      print('Error setting new user: $error');
    }
  }

  /* 
    CHAT SCREEN
  */

  Future<void> sendMessage(
      String roomID, String senderID, String content) async {
    var timestamp = FieldValue.serverTimestamp();
    Message message = Message(
      senderId: senderID,
      content: content,
      sentAt: timestamp,
    );
    await db
        .collection('chat_rooms')
        .doc(roomID)
        .collection('messages')
        .add(message.toMap())
        .then(
          (value) => db
              .collection('chat_rooms')
              .doc(roomID)
              .update({'last_message': timestamp}),
        );
  }

  Stream<ChatRoom> getChatHistory(String roomId) {
    try {
      final chatRoom = db
          .collection('chat_rooms')
          .doc(roomId)
          .snapshots()
          .asyncMap((doc) async {
        final msgSnap = db
            .collection('chat_rooms')
            .doc(roomId)
            .collection('messages')
            .orderBy('sent_at', descending: true)
            .get();
        var messages = await msgSnap.then((value) =>
            value.docs.map((msg) => Message.fromMap(msg.data())).toList());
        var data = doc.data()!;
        data['messages'] = messages;
        data['room_id'] = roomId;

        return ChatRoom.fromMap(data);
      });
      return chatRoom;
    } catch (e) {
      print('Error fetching chat room: $e');
      return const Stream.empty();
    }
  }

  // get current users.data - retrieve list of friend List<String>
  Stream<AppUser> getAppUserData(String uid) {
    var data = db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => AppUser.fromMap(doc.data()!));
    return data;
  }

// get list of users
  Stream<List<AppUser>> get users {
    var data = db.collection('users').snapshots().map(
        (doc) => doc.docs.map((doc) => AppUser.fromMap(doc.data())).toList());
    return data;
  }

  Future<void> sendFriendRequest(String currentUid, String otherUid) async {
    try {
      // add current user into received_fReq of a user we want to link with
      await db.collection('users').doc(otherUid).update({
        'received_fReq': FieldValue.arrayUnion([currentUid])
      });
    } on Exception catch (e) {
      print('Error adding id: $otherUid into f_requests list: $e');
    }
  }

  Future<String> createChatRoom() async {
    var data = {'last_message': FieldValue.serverTimestamp(), 'room_id': ''};
    var docRef = await db.collection('chat_rooms').add(data);
    return docRef.id;
  }

  Future<void> acceptFriendReq(String currentUid, String reqSenderId) async {
    WriteBatch batch = FirebaseFirestore.instance.batch();
    try {
      var currUserRef = db.collection('users').doc(currentUid);
      var reqSenderRef = db.collection('users').doc(reqSenderId);

      batch.update(currUserRef, {
        'received_fReq': FieldValue.arrayRemove([reqSenderId]),
        'friends': FieldValue.arrayUnion([reqSenderId])
      });
      batch.update(reqSenderRef, {
        // 'received_fReq': FieldValue.arrayRemove([reqSenderId]),
        'friends': FieldValue.arrayUnion([currentUid])
      });
      String roomId = await createChatRoom();
      batch.set(
          currUserRef,
          {
            'get_chat': {reqSenderId: roomId}
          },
          SetOptions(merge: true));
      batch.set(
          reqSenderRef,
          {
            'get_chat': {currentUid: roomId}
          },
          SetOptions(merge: true));
      await batch.commit();
    } catch (e) {
      print('Accept friend request error: $e');
    }
  }

  Future<void> removeFriendRequest(String currentUid, String otherUid) async {
    try {
      await db.collection('users').doc(otherUid).update({
        'received_fReq': FieldValue.arrayRemove([currentUid])
      });
    } on Exception catch (e) {
      print('Error removing id: $otherUid from f_requests list: $e');
    }
  }

  /* 
    WORKOUT SCREEN
    ../pages/widgets/set_tile.dart
    ../services/database/local_preferences.dart
  */

// ---------- WORKOUT - DATA SETTERS ---------------------------
  Future addWorkout(String uid, String wName) async {
    Workout workout = Workout(
      name: wName,
      createdAt: FieldValue.serverTimestamp(),
    );

    final mappedData = workout.toMap();
    await db.collection('workouts').add(mappedData).then((doc) {
      db.collection('users').doc(uid).update({
        'workouts': FieldValue.arrayUnion([doc.id])
      });
    });
  }

  void addExercise(String wID, String eID, String exerciseName_) {
    var data = {
      'createdAt': FieldValue.serverTimestamp(),
      'eid': eID,
      'name': exerciseName_,
      'sets': [],
    };

    try {
      db
          .collection('workouts')
          .doc(wID)
          .collection('exercises')
          .doc(eID)
          .set(data);
      print('Exercise added successfully.');
    } catch (e) {
      print('Error adding exercise: $e');
    }
  }

  void updateSets(String wID) {
    final batch = db.batch();
    List updates = LocalPreferences.getUpdates(wID);
    String eID;
    dynamic updatedSets;
    DocumentReference<Map<String, dynamic>> docRef;

    for (var item in updates) {
      eID = item['eid'];
      updatedSets = item['sets'];

      docRef =
          db.collection('workouts').doc(wID).collection('exercises').doc(eID);
      batch.update(docRef, {'sets': updatedSets});
    }
    batch.commit();
    LocalPreferences.clearUpdates(wID);
    print('sets inside doc >> $wID _ updated');
  }

  void addSet(String wID, String? eID) {
    Exercise exercise;
    Sets newSet;

    db
        .collection('workouts')
        .doc(wID)
        .collection('exercises')
        .doc(eID)
        .get()
        .then((doc) => {
              newSet = Sets(reps: "", weight: ""),
              exercise = Exercise.fromMap(doc.data() as Map<String, dynamic>),
              exercise.sets.add(newSet),
              db
                  .collection('workouts')
                  .doc(wID)
                  .collection('exercises')
                  .doc(eID)
                  .set(exercise.toMap())
            });
    print('exercise >> $eID _ empty set added');
  }

  void removeSet(String wID, String? eID, int setIdx) {
    Exercise exercise;

    db
        .collection('workouts')
        .doc(wID)
        .collection('exercises')
        .doc(eID)
        .get()
        .then((doc) => {
              exercise = Exercise.fromMap(doc.data() as Map<String, dynamic>),
              exercise.sets.removeAt(setIdx),
              db
                  .collection('workouts')
                  .doc(wID)
                  .collection('exercises')
                  .doc(eID)
                  .set(exercise.toMap())
            });
    print('exercise >> $eID _ set on index: $setIdx removed');
  }

  String generateDocID(String wID) {
    var newDocRef =
        db.collection('wokrouts').doc(wID).collection('exercises').doc();
    var newDocId = newDocRef.id;
    return newDocId;
  }

// ---------- WORKOUT GETTERS ---------------------------
  Stream<List<Workout>> getWorkouts(String uid) {
    return db
        .collection('users')
        .doc(uid)
        .snapshots()
        .asyncMap((userSnap) async {
      try {
        if (!userSnap.exists) {
          print('User document by the id: $uid not found.');
          return [];
        }
        List<dynamic> workoutIdsData = userSnap.data()?['workouts'];

        if (workoutIdsData.isEmpty) {
          print('Workout list of a user: $uid is empty.');
          return [];
        }
        List<String> workoutIds = workoutIdsData.cast<String>();
        // Fetch workout based on the id
        List<Future<DocumentSnapshot>> futures = workoutIds
            .map((id) => db.collection('workouts').doc(id).get())
            .toList();

        // Waiting for all document fetch futures to complete
        List<DocumentSnapshot> snapshots = await Future.wait(futures);

        List<Workout> workouts = snapshots
            .map((doc) {
              var data = doc.data() as Map<String, dynamic>;
              if (data.isNotEmpty) {
                return Workout.fromMap(doc.id, data);
              } else {
                print('Document data not available.');
              }
            })
            .cast<Workout>()
            .toList();

        return workouts;
      } catch (error) {
        print('Error loading user workokuts: $error');
        return [];
      }
    });
  }

  Stream<List<Exercise>> getExercises(String? wID) {
    Map<String, dynamic> data;
    return db
        .collection('workouts')
        .doc(wID)
        .collection('exercises')
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              data = doc.data();
              data['eid'] = doc.id;
              return Exercise.fromMap(doc.data());
            }).toList());
  }
}
