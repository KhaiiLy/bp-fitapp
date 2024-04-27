import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String content;
  final String senderId;
  final dynamic sentAt;

  Message({
    required this.senderId,
    required this.content,
    required this.sentAt,
  });

  Map<String, dynamic> toMap() => {
        'content': content,
        'sender_id': senderId,
        'sent_at': sentAt,
      };

  factory Message.fromMap(Map<String, dynamic> data) => Message(
        content: data['content'] ?? '',
        senderId: data['sender_id'] ?? '',
        sentAt: data['sent_at'] ?? Timestamp.now(),
      );
}
