// import 'package:fitapp/data/users/friend_request.dart';

import 'package:fitapp/data/workout/shared_workout.dart';

class AppUser {
  final String uid;
  final String name;
  final String lname;
  final String email;
  List workouts;
  List<SharedWorkout> sharedWorkouts;
  List<SharedWorkout> workoutReqs;
  List friends;
  List fRequests;
  Map<String, dynamic> chatRoom;

  AppUser({
    required this.uid,
    required this.name,
    required this.lname,
    required this.email,
    required this.workouts,
    required this.sharedWorkouts,
    required this.workoutReqs,
    required this.friends,
    required this.fRequests,
    required this.chatRoom,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'last_name': lname,
        'email': email,
        'workouts': workouts,
        'shared_workouts': convertWorkoutReqs(sharedWorkouts),
        'workout_reqs': convertWorkoutReqs(workoutReqs),
        'friends': friends,
        'received_fReq': fRequests,
        'get_chat': chatRoom,
      };

  Map<String, dynamic> convertWorkoutReqs(List<dynamic> listWorkouts) {
    Map<String, dynamic> converted = {};
    Map<String, dynamic> data;
    for (dynamic workout in listWorkouts) {
      data = workout.toMap();
      converted[data['workout_key']] = data['workout_value'];
    }
    return converted;
  }

  factory AppUser.fromMap(Map<String, dynamic> data) => AppUser(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        lname: data['last_name'] ?? '',
        email: data['email'] ?? '',
        workouts: data['workouts'] ?? [],
        sharedWorkouts: List<SharedWorkout>.from(data['shared_workouts']
            ?.entries
            .map((e) => SharedWorkout.fromMap(e.key, e.value))),
        // workoutReqs: ,
        workoutReqs: List<SharedWorkout>.from(data['workout_reqs']
            ?.entries
            .map((e) => SharedWorkout.fromMap(e.key, e.value))),
        friends: data['friends'] ?? [],
        fRequests: data['received_fReq'] ?? [],
        chatRoom: data['get_chat'] ?? {},

        // fRequests: List<FriendRequest>.from(
        //     data['f_requests']?.map((x) => FriendRequest.fromMap(x))),
      );
}
