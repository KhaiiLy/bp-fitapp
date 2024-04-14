import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String userName;

  const UserTile({
    Key? key,
    required this.userName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: const CircleAvatar(child: Icon((Icons.person))),
        title: Text(userName),
      ),
    );
  }
}
