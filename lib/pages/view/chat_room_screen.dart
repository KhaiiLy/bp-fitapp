import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/data/chat/chat_room.dart';
import 'package:fitapp/data/chat/message.dart';
import 'package:fitapp/pages/widgets/chat_bubble.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String userName;
  const ChatRoomScreen(
      {super.key, required this.roomId, required this.userName});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController messageCtrl = TextEditingController();
  final scrollCtrl = ScrollController();

  Future<void> onSendMessage(String roomId, String currentUserId) async {
    FirestoreDatabase().sendMessage(roomId, currentUserId, messageCtrl.text);
    scrollCtrl.animateTo(0,
        duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    messageCtrl.clear();
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String roomId = widget.roomId;
    String userName = widget.userName;
    User currentUser = FirebaseAuth.instance.currentUser!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(
          userName,
          style: TextStyle(color: Colors.cyan[200]),
        ),
        centerTitle: true,
        backgroundColor: Colors.grey[200],
        iconTheme: IconThemeData(color: Colors.cyan[200]),
      ),
      body: Column(
        children: [
          _buildMessageList(roomId, currentUser),
          _buildUserInput(roomId, currentUser),
        ],
      ),
    );
  }

  Widget _buildMessageList(String roomId, User currentUser) {
    return StreamBuilder<ChatRoom>(
      stream: FirestoreDatabase().getChatHistory(roomId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (snapshot.hasData) {
          ChatRoom data = snapshot.data!;
          List<Message> messages = data.messages;

          return Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Align(
                alignment: Alignment.topCenter,
                child: ListView.builder(
                  controller: scrollCtrl,
                  shrinkWrap: true,
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, idx) {
                    return ChatBubble(
                      message: messages[idx],
                      currentUserId: currentUser.uid,
                    );
                  },
                ),
              ),
            ),
          );
        } else {
          return const Text('No data.');
        }
      },
    );
  }

  Widget _buildUserInput(String roomId, User currentUser) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: Alignment.center,
              width: 250,
              height: 46,
              child: TextField(
                controller: messageCtrl,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1,
                    color: Colors.black54),
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(20)),
                    filled: true,
                    fillColor: Colors.grey[200]),
                textAlignVertical: TextAlignVertical.center,
              ),
            ),
          ),
          IconButton(
            onPressed: () => onSendMessage(roomId, currentUser.uid),
            icon: const Icon(Icons.send_rounded),
            iconSize: 35,
            color: Colors.cyan[200],
          ),
        ],
      ),
    );
  }
}
