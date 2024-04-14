import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final String userName;
  bool requestSend;
  final VoidCallback? sendFriendRequest;
  final VoidCallback? cancelFriendRequest;

  UserTile({
    Key? key,
    required this.userName,
    required this.requestSend,
    this.sendFriendRequest,
    this.cancelFriendRequest,
  }) : super(key: key);

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon((Icons.person))),
        title: Text(widget.userName),
        trailing: widget.requestSend
            ? IconButton(
                icon: const Icon(Icons.person_remove_outlined),
                onPressed: widget.cancelFriendRequest,
              )
            : IconButton(
                icon: const Icon(Icons.person_add_alt_outlined),
                onPressed: widget.sendFriendRequest,
              ),
      ),
    );
  }
}
