import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String msgType;
  final String senderId;
  final dynamic sentAt;

  Message({
    required this.senderId,
    required this.content,
    required this.msgType,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
        'content': content,
        'type': msgType,
        'sender_id': senderId,
        'sent_at': sentAt,
      };

  factory Message.fromMap(Map<String, dynamic> data) => Message(
        content: data['content'] ?? '',
        msgType: data['type'] ?? '',
        senderId: data['sender_id'] ?? '',
        sentAt: data['sent_at'] ?? Timestamp.now(),
      );
}
