class User {
  final String uid;
  final String name;
  final String lname;
  final String email;

  User(
      {required this.uid,
      required this.name,
      required this.lname,
      required this.email});

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'name': name,
        'lname': lname,
        'email': email,
      };

  factory User.fromMap(String uid_, Map<String, dynamic> data) => User(
        uid: uid_,
        name: data['name'] ?? '',
        lname: data['last_name'] ?? '',
        email: data['email'] ?? '',
      );
}
