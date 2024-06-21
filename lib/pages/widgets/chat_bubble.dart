import 'package:fitapp/data/chat/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final Message message;
  final String currentUserId;
  const ChatBubble({
    super.key,
    required this.message,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    bool iamSender = message.senderId == currentUserId;
    var msgAlignment = iamSender ? Alignment.centerRight : Alignment.centerLeft;

    return Align(
        alignment: msgAlignment,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 10,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: iamSender ? Colors.cyan.shade200 : Colors.grey.shade400,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 5),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 220),
                child: Text(
                  message.content,
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ));
  }
}
