import 'package:flutter/material.dart';

class UserTile extends StatefulWidget {
  final String userName;
  final bool requestSend;
  final bool isFriend;
  final VoidCallback? sendFriendRequest;
  final VoidCallback? cancelFriendRequest;

  const UserTile({
    super.key,
    required this.userName,
    required this.requestSend,
    required this.isFriend,
    this.sendFriendRequest,
    this.cancelFriendRequest,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: const CircleAvatar(child: Icon((Icons.person))),
          title: Text(widget.userName, style: const TextStyle(fontSize: 14)),
          trailing: widget.isFriend
              ? const Text('Friends')
              : widget.requestSend
                  ? IconButton(
                      icon: const Icon(Icons.person_remove_outlined),
                      onPressed: widget.cancelFriendRequest,
                    )
                  : IconButton(
                      icon: const Icon(Icons.person_add_alt_outlined),
                      onPressed: widget.sendFriendRequest,
                    )),
    );
  }
}
