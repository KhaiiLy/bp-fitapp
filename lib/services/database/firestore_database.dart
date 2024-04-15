import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:fitapp/data/models/exercise.dart';
import 'package:fitapp/data/models/friend_request.dart';
import 'package:fitapp/services/database/local_preferences.dart';
import '../../data/models/workout.dart';
import '../../data/models/sets.dart';
import '../../data/models/app_user.dart';

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
  Stream<List<AppUser>> get users {
    var data = db.collection('users').snapshots().map(
        (doc) => doc.docs.map((doc) => AppUser.fromMap(doc.data())).toList());
    return data;
  }

  Future<void> addFriendRequest(String currentUid, String requestingId) async {
    // DocumentReference documentRef = db.collection('users').doc(requestingId);
    FriendRequest newRequest =
        FriendRequest(reqUid: currentUid, state: 'unresolved');

    try {
      // add current user into list of requests of a user that we sended it to
      // await db.collection('users').doc(requestingId).get().then((doc) {
      //   user = AppUser.fromMap(doc.data()!);
      //   user.fRequests.add(newRequest);
      //   db.collection('users').doc(requestingId).set(user.toMap());
      // });
      var snap = await db.collection('users').doc(requestingId).get();
      List<Map<String, dynamic>> requests =
          List<Map<String, dynamic>>.from(snap.data()!['f_requests']);
      requests.add(newRequest.toMap());
      await db
          .collection('users')
          .doc(requestingId)
          .update({'f_requests': requests});
    } on Exception catch (e) {
      print('Error adding id: $requestingId into f_requests list: $e');
    }
  }

  Future<void> removeFriendRequest(
      String currentUid, String requestingId) async {
    try {
      await db.collection('users').doc(requestingId).update({
        'f_request': FieldValue.arrayRemove([currentUid])
      });
    } on Exception catch (e) {
      print('Error removing id: $requestingId from f_requests list: $e');
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
