// import 'package:fitapp/data/models/exercise.dart';

import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String? wid;
  final String name;
  final dynamic createdAt;
  // final List<Exercise>? exercises;

  Workout({
    this.wid,
    required this.name,
    required this.createdAt,
    /*this.exercises*/
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'createdAt': createdAt,
        // 'exercises': exercises.map((exercise) => exercise.toMap()).toList(),
      };

  factory Workout.fromMap(String id, Map<String, dynamic> data) => Workout(
        wid: id,
        name: data['name'] ?? '',
        createdAt: data['createdAt'] ?? Timestamp.now(),

        // exercises: List<Exercise>.from(
        //     data['exercises']?.map((x) => Exercise.fromMap(x)))
        // exercises: data['exercises'] ?? <Exercise>[],
      );
}
