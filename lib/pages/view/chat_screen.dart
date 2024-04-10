import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/user.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<User>>.value(
      value: FirestoreDatabase().users,
      initialData: [],
      child: Chat(),
    );
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  @override
  Widget build(BuildContext context) {
    var users = Provider.of<List<User>>(context);

    return ListView.builder(
        itemCount: users.length,
        itemBuilder: ((context, index) {
          return ListTile(
            title: Text(users[index].email),
          );
        }));
  }
}
