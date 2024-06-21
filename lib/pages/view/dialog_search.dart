import 'package:fitapp/data/users/app_user.dart';
import 'package:fitapp/data/workout/shared_workout.dart';
import 'package:fitapp/pages/widgets/chat_search_bar.dart';
import 'package:fitapp/pages/widgets/share_workout_tile.dart';
import 'package:fitapp/pages/widgets/user_tile.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DialogSearch extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> userList;
  final Map<String, dynamic> data;
  const DialogSearch({
    super.key,
    required this.currentUser,
    required this.userList,
    required this.data,
  });

  @override
  State<DialogSearch> createState() => _DialogSearchState();
}

class _DialogSearchState extends State<DialogSearch> {
  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<AppUser>>.value(
      value: FirestoreDatabase().users,
      initialData: [],
      child: MyDialogSearch(
          currentUser: widget.currentUser,
          userList: widget.userList,
          data: widget.data),
    );
  }
}

class MyDialogSearch extends StatefulWidget {
  final AppUser currentUser;
  final List<AppUser> userList;
  final Map<String, dynamic> data;

  const MyDialogSearch({
    super.key,
    required this.currentUser,
    required this.userList,
    required this.data,
  });

  @override
  State<MyDialogSearch> createState() => _MyDialogSearchState();
}

class _MyDialogSearchState extends State<MyDialogSearch> {
  late List<AppUser> userList;
  late List<AppUser> allUsers;
  late AppUser currentUser;
  late List<AppUser> foundUsers;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    currentUser = widget.currentUser;
    allUsers = Provider.of<List<AppUser>>(context);
    allUsers.removeWhere((item) => item.uid == currentUser.uid);
    if (widget.data["userTileType"] == "share_workout") {
      userList = filterUsersByID(currentUser.friends);
    } else if (widget.data["userTileType"] == "friend_request") {
      userList = allUsers;
    }
    foundUsers = userList;

    // userList = widget.userList;
    // userList.removeWhere((item) => item.uid == currentUser.uid);
    // foundUsers = userList;
  }

  List<AppUser> filterUsersByID(List<dynamic> requiredIds) {
    return allUsers.where((item) => requiredIds.contains(item.uid)).toList();
  }

  void _runFilter(String txtSearch) {
    List<AppUser> data = [];
    if (txtSearch.isEmpty) {
      data = userList;
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
    var data = widget.data;
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
                    AppUser user = foundUsers[idx];
                    String fullName = "${user.name} ${user.lname}";
                    bool isFriend = currentUser.friends.contains(user.uid);

                    if (data["userTileType"] == "friend_request") {
                      return UserTile(
                        userName: fullName,
                        requestSend: user.fRequests.contains(currentUser.uid),
                        isFriend: isFriend,
                        sendFriendRequest: () => setState(() {
                          FirestoreDatabase()
                              .sendFriendRequest(currentUser.uid, user.uid);
                        }),
                        cancelFriendRequest: () => setState(() {
                          FirestoreDatabase()
                              .removeFriendRequest(currentUser.uid, user.uid);
                        }),
                      );
                    } else if (data["userTileType"] == "share_workout") {
                      var wId = data["workoutId"];
                      bool workoutSend = _containsKey(user.workoutReqs, wId);
                      bool isAccepted = _containsKey(user.sharedWorkouts, wId);

                      return ShareWorkoutTile(
                        userName: fullName,
                        workoutSend: workoutSend,
                        isAccepted: isAccepted,
                        shareWorkout: () => setState(() {
                          FirestoreDatabase().shareWorkout(currentUser.uid,
                              user.uid, wId, fullName, data["workoutName"]);
                        }),
                        unshareWokrout: () => setState(() {
                          FirestoreDatabase().unshareWokrout(user.uid, wId);
                        }),
                      );
                    } else {
                      return const Text("No workouts found");
                    }
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  bool _containsKey(List<SharedWorkout> workoutReqs, String wId) {
    for (final item in workoutReqs) {
      if (item.workoutId == wId) {
        return true;
      }
    }
    return false;
  }
}
