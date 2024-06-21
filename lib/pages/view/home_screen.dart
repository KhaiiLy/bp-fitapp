import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/data/users/app_user.dart';
import 'package:fitapp/data/workout/shared_workout.dart';
import 'package:fitapp/data/workout/workout.dart';
import 'package:fitapp/pages/view/workout_screen.dart';
import 'package:fitapp/pages/widgets/notification_badge.dart';

import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // text controller
  final newWorkoutCtrl = TextEditingController();
  String? get currentUser => FirebaseAuth.instance.currentUser?.uid;
  bool showMyWorkouts = true;

  // create a new workout
  void createNewWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Create new workout"),
        content: TextField(controller: newWorkoutCtrl),
        actions: [
          TextButton(onPressed: cancel, child: const Text("Cancel")),
          TextButton(onPressed: save, child: const Text("Add")),
        ],
        actionsAlignment: MainAxisAlignment.spaceBetween,
      ),
    );
  }

  // navigate to workout screen with exercises
  void navToWorkoutScreen(AppUser user, String wID, String workoutName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutScreen(
          currentUser: user,
          workoutId: wID,
          workoutName: workoutName,
        ),
      ),
    );
  }

  // save workout
  void save() {
    // add workout to workout data list with provider
    FirestoreDatabase().addWorkout(currentUser!, newWorkoutCtrl.text);
    Navigator.pop(context);
    clear();
  }

  // cancel
  void cancel() {
    Navigator.pop(context);
    clear();
  }

  // clear textfield for new workout
  void clear() {
    newWorkoutCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    List<Workout> workouts = Provider.of<List<Workout>>(context);
    var user = Provider.of<AppUser>(context);
    var appBarHeight = AppBar().preferredSize.height;
    List<SharedWorkout> workoutReqs = user.workoutReqs;

    return Scaffold(
      appBar: AppBar(
        title: const Text('1 on 1'),
        actions: [
          Stack(
            children: [
              PopupMenuButton(
                  icon: const Icon(Icons.notifications_rounded, size: 32),
                  offset: Offset(-4.0, appBarHeight - 2),
                  itemBuilder: (context) {
                    return workoutReqs
                        .map((workout) => PopupMenuItem(
                            value: workout,
                            child: ListTile(
                              title: Text(workout.workoutName),
                              subtitle: Text("From ${workout.userName}"),
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
                                        icon: const Icon(Icons
                                            .check_circle_outline_outlined),
                                        onPressed: () {
                                          FirestoreDatabase().acceptWorkout(
                                              currentUser!,
                                              workout.fromUid,
                                              workout.workoutId,
                                              workout.userName,
                                              workout.workoutName);
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
                                          FirestoreDatabase().unshareWokrout(
                                              currentUser!, workout.workoutId);
                                          Navigator.pop(context);
                                        }),
                                  ),
                                ],
                              ),
                            )))
                        .toList();
                  }),
              workoutReqs.isNotEmpty
                  ? NotificationBadge(numOfNot: workoutReqs.length)
                  : const SizedBox(),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewWorkout,
        child: const Icon(Icons.add_circle_rounded, size: 50),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TextButton(
                  onPressed: () => setState(() {
                    showMyWorkouts = true;
                  }),
                  child: const Text('My workouts'),
                ),
                const SizedBox(width: 10),
                TextButton(
                    onPressed: () => setState(() {
                          showMyWorkouts = false;
                        }),
                    child: const Text('Shared workouts')),
              ],
            ),
            // const SizedBox(height: 10),
            showMyWorkouts
                ? Expanded(
                    child: ListView.builder(
                      itemCount: workouts.length,
                      itemBuilder: (context, idx) => GestureDetector(
                        onTap: () {
                          var workout = workouts[idx];
                          navToWorkoutScreen(user, workout.wid!, workout.name);
                        },
                        child: Dismissible(
                          key: UniqueKey(),
                          direction: DismissDirection.endToStart,
                          onDismissed: (direction) {
                            if (direction == DismissDirection.endToStart) {
                              FirestoreDatabase()
                                  .removeWorkout(user.uid, workouts[idx].wid!);
                            }
                          },
                          background: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                  bottomRight: Radius.circular(12),
                                  topRight: Radius.circular(12)),
                            ),
                          ),
                          child: Card(
                            child: ListTile(
                              title: Text(workouts[idx].name),
                              trailing:
                                  const Icon(Icons.arrow_forward_ios_outlined),
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                : _buildSharedWorkouts(user, "shared_workouts")
          ],
        ),
      ),
    );
  }

  Widget _buildSharedWorkouts(AppUser user, String workoutType) {
    return StreamBuilder(
      stream: FirestoreDatabase().getWorkouts(user.uid, workoutType),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(15.0),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        } else {
          var sharedWorkouts = snapshot.data!;
          return Expanded(
            child: ListView.builder(
              itemCount: sharedWorkouts.length,
              itemBuilder: (context, idx) => GestureDetector(
                onTap: () {
                  var sWorkout = sharedWorkouts[idx];
                  navToWorkoutScreen(user, sWorkout.wid!, sWorkout.name);
                },
                child: Dismissible(
                  key: UniqueKey(),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    if (direction == DismissDirection.endToStart) {
                      FirestoreDatabase().removeSharedWorkout(
                          user.uid, sharedWorkouts[idx].wid!);
                    }
                  },
                  background: Container(
                    margin: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                          bottomRight: Radius.circular(12),
                          topRight: Radius.circular(12)),
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      title: Text(sharedWorkouts[idx].name),
                      trailing: const Icon(Icons.arrow_forward_ios_outlined),
                    ),
                  ),
                ),
              ),
            ),
          );
        }
      },
    );
  }
}
