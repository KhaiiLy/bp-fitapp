import 'dart:convert';
import 'package:fitapp/data/workout/exercise.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalPreferences {
  static late SharedPreferences prefs;

  static var exerciseKey = 'ex';
  static const setKey = 'set';
  static const weightKey = 'weight';
  static const repsKey = 'reps';
  static var updatesKey = 'updates';

  static Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

// ---------- GETTER ---------------------------

  static Future saveExercises(String wid, List<Exercise> exercises) async {
    String data =
        (jsonEncode(exercises.map((ex) => ex.toSharedPrefs()).toList()));
    await prefs.setString('${exerciseKey}_$wid', data);
  }

  static List<Exercise> getExercises(String wid) {
    var exercises = jsonDecode(prefs.getString('${exerciseKey}_$wid') ?? '');

    var data = (exercises as List)
        .map((item) => Exercise.fromSharedPrefs(item))
        .toList();

    return data;
  }

// ---------- DATA SETTERS ---------------------------
  static Future<void> prepareBatch(
      String wid, String eid, dynamic updatedItem) async {
    List updates = prefs
            .getStringList('${updatesKey}_$wid')
            ?.map((json) => jsonDecode(json))
            .toList() ??
        [];
    bool eidFound;
    if (updates.isNotEmpty) {
      eidFound = false;
      for (var item in updates) {
        if (item['eid'] == eid) {
          item['sets'] = updatedItem;
          eidFound = true;
          // print('item with id: $eid updated');
          break;
        }
      }
      if (!eidFound) {
        // print('\nnew item with id: $eid was added');
        updates.add({'eid': eid, 'sets': updatedItem});
      }
    } else if (updates.isEmpty) {
      // print('\nitem with id: $eid added to an empy array');
      updates.add({'eid': eid, 'sets': updatedItem});
    }

    List<String> encodedData = updates.map((item) => jsonEncode(item)).toList();
    await prefs.setStringList('${updatesKey}_$wid', encodedData);
  }

  static List<dynamic> getUpdates(String wid) {
    List updates = prefs
            .getStringList('${updatesKey}_$wid')
            ?.map((json) => jsonDecode(json))
            .toList() ??
        [];
    print('Function: getUpdates()');
    for (var item in updates) {
      print(item);
    }
    return updates;
  }

  static Future updateExercise(String wid, String eid, int exIdx, int setIdx,
      String parameter, String value) async {
    var exercises = jsonDecode(prefs.getString('${exerciseKey}_$wid') ?? '');

    // prefs.remove('${updatesKey}_$wid');

    if (value != exercises[exIdx]['sets'][setIdx][parameter]) {
      exercises[exIdx]['sets'][setIdx][parameter] = value;
      var updatedItem = exercises[exIdx]['sets'];
      prepareBatch(wid, eid, updatedItem);

      List<Exercise> exerciseList = (exercises as List)
          .map((item) => Exercise.fromSharedPrefs(item))
          .toList();
      String data =
          (jsonEncode(exerciseList.map((ex) => ex.toSharedPrefs()).toList()));
      await prefs.setString('${exerciseKey}_$wid', data);
    } else {
      await null;
    }
  }

  static Future<void> clearUpdates(String wid) async {
    await prefs.remove('${updatesKey}_$wid');
  }

  static Future<void> addExerciseLocally(
      String wid, String exerciseName_) async {
    String newDocId = FirestoreDatabase().generateDocID(wid);
    var exercises = jsonDecode(prefs.getString('${exerciseKey}_$wid') ?? '');
    var list = (exercises as List)
        .map((item) => Exercise.fromSharedPrefs(item))
        .toList();

    list.add(Exercise(eid: newDocId, name: exerciseName_, sets: []));
    String encoded =
        (jsonEncode(list.map((ex) => ex.toSharedPrefs()).toList()));

    await prefs.setString('${exerciseKey}_$wid', encoded);
    FirestoreDatabase().addExercise(wid, newDocId, exerciseName_);
  }
}
