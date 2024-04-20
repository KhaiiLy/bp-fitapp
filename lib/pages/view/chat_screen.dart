import 'package:fitapp/pages/widgets/dialog_search.dart';
import 'package:fitapp/pages/widgets/user_tile.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_user.dart';
import 'package:fitapp/pages/widgets/chat_search_bar.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Chat();
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  late List<AppUser> others;
  late List<AppUser> friends;
  late List<AppUser> users;
  late AppUser currentUser;

  late List<AppUser> foundFriends;

  @override
  void didChangeDependencies() {
    currentUser = Provider.of<AppUser>(context);
    users = Provider.of<List<AppUser>>(context);

    setListviewData(currentUser.friends);
    super.didChangeDependencies();
  }

  void setListviewData(List<dynamic> friendIds) {
    friends = users.where((obj) => friendIds.contains(obj.uid)).toList();
    users.removeWhere((item) => item.uid == currentUser.uid);
    foundFriends = friends;
    others = users;
  }

  void _runFilter(String txtSearch) {
    List<AppUser> data = [];

    if (txtSearch.isEmpty) {
      data = friends;
    } else if (txtSearch.isNotEmpty) {
      data = friends.where((friend) {
        String fullName = "${friend.name} ${friend.lname}";
        return fullName.toLowerCase().contains(txtSearch.toLowerCase());
      }).toList();
    }
    setState(() {
      foundFriends = data;
    });
  }

  void _searchWindow() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DialogSearch(currentUser: currentUser, appUsers: others);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ChatSearchhBar(runFilter: _runFilter),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () => _searchWindow(),
                      icon: const Icon(Icons.person_add_alt_outlined),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // BUILD USER LIST
              Expanded(
                child: ListView.builder(
                  itemCount: foundFriends.length,
                  itemBuilder: (context, idx) {
                    var fullName =
                        "${foundFriends[idx].name} ${foundFriends[idx].lname}";
                    return UserTile(
                      userName: fullName,
                      requestSend:
                          currentUser.fRequests.contains(foundFriends[idx].uid),
                      sendFriendRequest: () => FirestoreDatabase()
                          .addFriendRequest(
                              currentUser.uid, foundFriends[idx].uid),
                      cancelFriendRequest: () => FirestoreDatabase()
                          .removeFriendRequest(
                              currentUser.uid, foundFriends[idx].uid),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
