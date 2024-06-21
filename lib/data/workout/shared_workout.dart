class SharedWorkout {
  final String workoutId;
  final String workoutName;
  final String userName;
  final String fromUid;

  SharedWorkout(
      {required this.workoutId,
      required this.workoutName,
      required this.userName,
      required this.fromUid});

  Map<String, dynamic> toMap() => {
        'workout_key': workoutId,
        'workout_value': {
          'workou_name': workoutName,
          'sender_name': userName,
          'sender_id': fromUid,
        }
      };

  factory SharedWorkout.fromMap(String key, Map<String, dynamic> value) =>
      SharedWorkout(
          workoutId: key,
          workoutName: value['workoutName'],
          userName: value['userName'],
          fromUid: value['fromUid']);
}
