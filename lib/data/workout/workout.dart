// import 'package:fitapp/data/models/exercise.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String? wid;
  final String name;
  final String notes;
  final dynamic createdAt;
  // final List<Exercise>? exercises;

  Workout({
    this.wid,
    required this.name,
    required this.notes,
    required this.createdAt,
    /*this.exercises*/
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'notes': notes,
        'createdAt': createdAt,
        // 'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      };

  factory Workout.fromMap(String id, Map<String, dynamic> data) => Workout(
        wid: id,
        name: data['name'] ?? '',
        notes: data['notes'] ?? '',
        createdAt: data['createdAt'] ?? Timestamp.now(),

        // exercises: List<Exercise>.from(
        //     data['exercises']?.map((x) => Exercise.fromMap(x)))
        // exercises: data['exercises'] ?? <Exercise>[],
      );
}
