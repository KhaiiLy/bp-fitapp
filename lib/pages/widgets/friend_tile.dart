import 'package:fitapp/pages/view/chat_room_screen.dart';
import 'package:flutter/material.dart';

class FriendTile extends StatefulWidget {
  final String roomId;
  final String userName;

  const FriendTile({
    super.key,
    required this.roomId,
    required this.userName,
  });

  @override
  State<FriendTile> createState() => _FriendTileState();
}

void navToChatroom(BuildContext context, String roomId, String userName) {
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => ChatRoomScreen(
              roomId: roomId,
              userName: userName,
            )),
  );
}

class _FriendTileState extends State<FriendTile> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => navToChatroom(context, widget.roomId, widget.userName),
      child: Card(
        child: ListTile(
          leading: const CircleAvatar(child: Icon((Icons.person))),
          title: Text(widget.userName, style: const TextStyle(fontSize: 14)),
        ),
      ),
    );
  }
}
