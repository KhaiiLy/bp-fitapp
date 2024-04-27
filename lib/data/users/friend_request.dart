class FriendRequest {
  final String reqUid;
  final String state;

  FriendRequest({required this.reqUid, required this.state});

  Map<String, dynamic> toMap() => {'request_uid': reqUid, 'state': state};

  factory FriendRequest.fromMap(Map<String, dynamic> data) =>
      FriendRequest(reqUid: data['request_uid'], state: data['state']);
}
