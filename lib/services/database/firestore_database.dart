import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitapp/data/models/exercise.dart';
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

  // Stream<List<User>> getUserData(String uid) {
  //   var data = db
  //       .collection('users')
  //       .doc(uid)
  //       .snapshots()
  //       .map((snap) => AppUser.fromMap(snap.data()!));
  //   return [] as Stream<List<User>>;
  // }

  /* 
    WORKOUT SCREEN
    
    ../pages/widgets/set_tile.dart
    ../services/database/local_preferences.dart
  */

// ---------- WORKOUT - DATA SETTERS ---------------------------
  Future addWorkout(String wName) async {
    Workout workout = Workout(
      name: wName,
      createdAt: FieldValue.serverTimestamp(),
    );

    final mappedData = workout.toMap();
    await db.collection('workouts').add(mappedData);
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
  Stream<List<Workout>> get workouts {
    Stream<List<Workout>> data = db
        .collection('workouts')
        .snapshots()
        .map((snap) => snap.docs.map((doc) {
              return Workout.fromMap(doc.id, doc.data());
            }).toList());
    return data;
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
