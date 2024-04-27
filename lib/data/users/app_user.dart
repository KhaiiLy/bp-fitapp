import 'package:fitapp/data/users/friend_request.dart';

class AppUser {
  final String uid;
  final String name;
  final String lname;
  final String email;
  List workouts;
  List friends;
  List fRequests;
  Map<String, dynamic> chatRoom;

  AppUser({
    required this.uid,
    required this.name,
    required this.lname,
    required this.email,
    required this.workouts,
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
        'friends': friends,
        'received_fReq': fRequests,
        'get_chat': chatRoom,
      };

  List<Map<String, dynamic>> convertRequests() {
    List<Map<String, dynamic>> converted = [];
    for (FriendRequest req in fRequests) {
      converted.add(req.toMap());
    }
    return converted;
  }

  factory AppUser.fromMap(Map<String, dynamic> data) => AppUser(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        lname: data['last_name'] ?? '',
        email: data['email'] ?? '',
        workouts: data['workouts'] ?? [],
        friends: data['friends'] ?? [],
        fRequests: data['received_fReq'] ?? [],
        chatRoom: data['get_chat'] ?? {},
        // fRequests: List<FriendRequest>.from(
        //     data['f_requests']?.map((x) => FriendRequest.fromMap(x))),
      );
}
