import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fitapp/data/chat/message.dart';

class ChatRoom {
  final String roomId;
  final List<Message> messages;
  final dynamic lastMessage;

  ChatRoom({
    required this.roomId,
    required this.messages,
    required this.lastMessage,
  });

  Map<String, dynamic> toMap() => {
        'room_id': roomId,
        // 'messages': convertMessages(),
        'last_message': lastMessage,
      };

  List<Map<String, dynamic>> convertMessages() {
    List<Map<String, dynamic>> converted = [];
    for (var msg in messages) {
      Message thisSet = msg;
      converted.add(thisSet.toMap());
    }
    return converted;
  }

  factory ChatRoom.fromMap(Map<String, dynamic> data) => ChatRoom(
        roomId: data['room_id'] ?? '',
        messages: data['messages'] ?? [],
        lastMessage: data['last_message'] ?? Timestamp.now(),
      );
}
