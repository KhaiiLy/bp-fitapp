import 'package:fitapp/data/models/app_user.dart';
import 'package:fitapp/pages/widgets/chat_search_bar.dart';
import 'package:fitapp/pages/widgets/user_tile.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';

class DialogSearch extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> appUsers;

  const DialogSearch({
    super.key,
    required this.currentUser,
    required this.appUsers,
  });

  @override
  State<DialogSearch> createState() => _DialogSearchState();
}

class _DialogSearchState extends State<DialogSearch> {
  // initialize parameter data
  late List<AppUser> appUsers;
  late AppUser currentUser;
  // data for search filter
  late List<AppUser> foundUsers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() {
      appUsers = widget.appUsers;
      currentUser = widget.currentUser;

      foundUsers = widget.appUsers;
    });
  }

  void _runFilter(String txtSearch) {
    List<AppUser> data = [];
    if (txtSearch.isEmpty) {
      data = appUsers;
    } else if (txtSearch.isNotEmpty) {
      data = foundUsers.where((friend) {
        String fullName = "${friend.name} ${friend.lname}";
        return fullName.toLowerCase().contains(txtSearch.toLowerCase());
      }).toList();
    }
    setState(() {
      foundUsers = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
      backgroundColor: Colors.white,
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              SizedBox(
                height: 36,
                child: Row(
                  children: [
                    ChatSearchhBar(runFilter: _runFilter),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel',
                          style: TextStyle(
                              fontWeight: FontWeight.w800, fontSize: 14)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // BUILD USER LIST
              Expanded(
                child: ListView.builder(
                  itemCount: foundUsers.length,
                  itemBuilder: (context, idx) {
                    var fullName =
                        "${foundUsers[idx].name} ${foundUsers[idx].lname}";
                    return UserTile(
                      userName: fullName,
                      requestSend:
                          currentUser.fRequests.contains(foundUsers[idx].uid),
                      sendFriendRequest: () => FirestoreDatabase()
                          .addFriendRequest(
                              currentUser.uid, foundUsers[idx].uid),
                      cancelFriendRequest: () => FirestoreDatabase()
                          .removeFriendRequest(
                              currentUser.uid, foundUsers[idx].uid),
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
