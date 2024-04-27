import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitapp/data/workout/sets.dart';

class Exercise {
  final String? eid;
  dynamic createdAt;
  final String name;
  List<Sets> sets;

  Exercise({
    this.eid,
    this.createdAt,
    required this.name,
    required this.sets,
  });

  Map<String, dynamic> toMap() => {
        'eid': eid,
        'createdAt': createdAt,
        'name': name,
        'sets': convertSets(),
      };

  List<Map<String, dynamic>> convertSets() {
    List<Map<String, dynamic>> converted = [];
    for (var set in sets) {
      Sets thisSet = set;
      converted.add(thisSet.toMap());
    }
    return converted;
  }

  factory Exercise.fromMap(Map<String, dynamic> data) => Exercise(
        eid: data['eid'] ?? '',
        createdAt: data['createdAt'] ?? Timestamp.now(),
        name: data['name'] ?? '',
        sets: List<Sets>.from(data['sets']?.map((x) => Sets.fromMap(x))),
      );

// SHARED PREFERENCES MAPPING
  Map<String, dynamic> toSharedPrefs() => {
        'eid': eid,
        'name': name,
        'sets': convertSets(),
      };

  factory Exercise.fromSharedPrefs(Map<String, dynamic> data) => Exercise(
        eid: data['eid'] ?? '',
        name: data['name'] ?? '',
        sets: List<Sets>.from(data['sets']?.map((x) => Sets.fromMap(x))),
      );
}
