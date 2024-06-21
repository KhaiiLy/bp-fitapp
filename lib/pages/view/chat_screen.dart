import 'package:fitapp/pages/view/dialog_search.dart';
import 'package:fitapp/pages/widgets/friend_tile.dart';
import 'package:fitapp/pages/widgets/notification_badge.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/users/app_user.dart';
import 'package:fitapp/pages/widgets/chat_search_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late List<AppUser> others;
  late List<AppUser> friends;
  late List<AppUser> allUsers;
  late AppUser currentUser;
  List friendReqs = [];
  List<AppUser> foundFriends = [];

  @override
  void didChangeDependencies() {
    currentUser = Provider.of<AppUser>(context);
    try {
      allUsers = Provider.of<List<AppUser>>(context);
    } catch (e) {
      print(e);
    }

    setState(() {
      friendReqs = filterUsersByID(currentUser.fRequests);
      friends = filterUsersByID(currentUser.friends);
      foundFriends = friends;
      allUsers.removeWhere((item) => item.uid == currentUser.uid);
      others = allUsers;
    });
    super.didChangeDependencies();
  }

  List<AppUser> filterUsersByID(List<dynamic> requiredIds) {
    return allUsers.where((item) => requiredIds.contains(item.uid)).toList();
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
    var data = {"userTileType": "friend_request"};
    showDialog(
      context: context,
      builder: (_) {
        return DialogSearch(
          currentUser: currentUser,
          userList: others,
          data: data,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var appBarHeight = AppBar().preferredSize.height;

    for (var user in foundFriends) {
      print(user.email);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 8, 14, 0),
            child: Container(
              height: 50,
              width: 50,
              alignment: Alignment.center,
              child: Stack(
                children: [
                  MyPopupMenu(
                    friendReqs: friendReqs,
                    currentUser: currentUser,
                    appBarHeight: appBarHeight,
                  ),
                  friendReqs.isNotEmpty
                      ? NotificationBadge(numOfNot: friendReqs.length)
                      : const SizedBox(),
                ],
              ),
            ),
          )
        ],
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
                    AppUser user = foundFriends[idx];
                    String fullName = "${user.name} ${user.lname}";
                    String roomId = currentUser.chatRoom[user.uid];

                    return FriendTile(roomId: roomId, userName: fullName);
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

class MyPopupMenu extends StatefulWidget {
  final List<dynamic> friendReqs;
  final AppUser currentUser;
  final double appBarHeight;
  const MyPopupMenu(
      {super.key,
      required this.friendReqs,
      required this.currentUser,
      required this.appBarHeight});

  @override
  State<MyPopupMenu> createState() => _MyPopupMenuState();
}

class _MyPopupMenuState extends State<MyPopupMenu> {
  late List<dynamic> requests;
  late AppUser currentUser;
  late double appBarHeight;

  @override
  Widget build(BuildContext context) {
    requests = widget.friendReqs;
    currentUser = widget.currentUser;
    appBarHeight = widget.appBarHeight;

    return PopupMenuButton(
      icon: const Icon(Icons.notifications_rounded, size: 32),
      offset: Offset(-4.0, widget.appBarHeight - 2),
      itemBuilder: (context) {
        return requests.map((user) {
          String fullName = "${user.name} ${user.lname}";
          return PopupMenuItem(
            child: ListTile(
              titleAlignment: ListTileTitleAlignment.center,
              title: Text(fullName),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.center,
                        iconSize: 28,
                        icon: const Icon(Icons.check_circle_outline_outlined),
                        onPressed: () {
                          FirestoreDatabase()
                              .acceptFriendReq(currentUser.uid, user.uid);
                          Navigator.pop(context);
                        }),
                  ),
                  SizedBox(
                    height: 30,
                    width: 30,
                    child: IconButton(
                        padding: const EdgeInsets.all(0),
                        alignment: Alignment.center,
                        iconSize: 28,
                        icon: const Icon(Icons.cancel_outlined),
                        onPressed: () {
                          FirestoreDatabase()
                              .declineFriendReq(currentUser.uid, user.uid);
                          Navigator.pop(context);
                        }),
                  ),
                ],
              ),
            ),
          );
        }).toList();
      },
    );
  }
}
