class User {
  final String uid;
  final String name;
  final String lname;
  final String email;
  List workouts;
  List friends;
  List fRequests;

  User({
    required this.uid,
    required this.name,
    required this.lname,
    required this.email,
    required this.workouts,
    required this.friends,
    required this.fRequests,
  });

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'lname': lname,
        'email': email,
      };

  factory User.fromMap(Map<String, dynamic> data) => User(
        uid: data['uid'] ?? '',
        name: data['name'] ?? '',
        lname: data['last_name'] ?? '',
        email: data['email'] ?? '',
        workouts: data['workouts'] ?? [],
        friends: data['friends'] ?? [],
        fRequests: data['f_requests'] ?? [],
      );
}
