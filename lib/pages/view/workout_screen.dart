import 'dart:async';

import 'package:fitapp/data/users/app_user.dart';
import 'package:fitapp/data/workout/workout.dart';
import 'package:fitapp/pages/view/dialog_search.dart';
import 'package:fitapp/services/database/local_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/pages/widgets/set_tile.dart';
import 'package:fitapp/data/workout/exercise.dart';
import 'package:fitapp/data/workout/sets.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatelessWidget {
  final AppUser currentUser;
  final String workoutId;
  final String workoutName;

  const WorkoutScreen({
    super.key,
    required this.currentUser,
    required this.workoutId,
    required this.workoutName,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        StreamProvider<List<AppUser>>.value(
          value: FirestoreDatabase().users,
          initialData: [],
        ),
        StreamProvider<String>.value(
            value: FirestoreDatabase().getWorkoutNotes(workoutId),
            initialData: ""),
      ],
      child: MyWorkoutScreen(
        currentUser: currentUser,
        workoutId: workoutId,
        wName: workoutName,
      ),
    );
  }
}

class MyWorkoutScreen extends StatefulWidget {
  final AppUser currentUser;
  final String workoutId;
  final String wName;

  const MyWorkoutScreen({
    super.key,
    required this.currentUser,
    required this.workoutId,
    required this.wName,
  });

  @override
  State<MyWorkoutScreen> createState() => _MyWorkoutScreenState();
}

class _MyWorkoutScreenState extends State<MyWorkoutScreen> {
  TextEditingController newExerciseCtrl = TextEditingController();
  TextEditingController notesCtrl = TextEditingController();
  Timer? _debounce;
  late List<AppUser> allUsers;
  late List<AppUser> friends;

  @override
  void initState() {
    super.initState();
    notesCtrl.addListener(_notesListener);
  }

  void _notesListener() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      LocalPreferences.saveNotes(widget.workoutId, notesCtrl.text);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    try {
      allUsers = Provider.of<List<AppUser>>(context);
    } catch (e) {
      print("Error occured in workout screen: $e");
    }

    setState(() {
      friends = filterUsersByID(widget.currentUser.friends);
    });
  }

  List<AppUser> filterUsersByID(List<dynamic> requiredIds) {
    return allUsers.where((item) => requiredIds.contains(item.uid)).toList();
  }

  Future addNewExercise(context) {
    return showDialog(
        context: context,
        builder: ((context) => AlertDialog(
              title: const Text('Add new exercise'),
              content: TextField(
                controller: newExerciseCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                    hintText: 'Enter the name of an exercise'),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                TextButton(
                    onPressed: () =>
                        Navigator.pop(context, newExerciseCtrl.text),
                    child: const Text('Add')),
              ],
              actionsAlignment: MainAxisAlignment.spaceBetween,
            )));
  }

  void _searchWindow() {
    var data = {
      "userTileType": "share_workout",
      "workoutId": widget.workoutId,
      "workoutName": widget.wName
    };
    showDialog(
      context: context,
      builder: (_) {
        return DialogSearch(
          currentUser: widget.currentUser,
          userList: friends,
          // userTileType: "share_workout",
          data: data,
        );
      },
    );
  }

  @override
  void dispose() {
    newExerciseCtrl.dispose();
    notesCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String notes = Provider.of<String>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.wName),
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () {
              if (LocalPreferences.getUpdates(widget.workoutId).isNotEmpty) {
                FirestoreDatabase().updateSets(widget.workoutId);
              }
              FirestoreDatabase().updateNotes(widget.workoutId);
              Navigator.of(context).pop();
            }),
        actions: [
          IconButton(
            onPressed: () => _searchWindow(),
            icon: const Icon(Icons.share_outlined, size: 34),
            color: Colors.cyan[200],
          )
        ],
      ),
      body: StreamBuilder<List<Exercise>>(
        stream: FirestoreDatabase().getExercises(widget.workoutId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else {
            List<Exercise> data = snapshot.data!;
            LocalPreferences.saveExercises(widget.workoutId, data);
            List<Exercise> exercises =
                LocalPreferences.getExercises(widget.workoutId);
            LocalPreferences.saveNotes(widget.workoutId, notes);
            notesCtrl.text = LocalPreferences.getNotes(widget.workoutId);

            return Container(
              margin: const EdgeInsets.all(25),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                      child: Column(
                    children: [
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: const InputDecoration(
                            hintText: "Notes", border: InputBorder.none),
                        controller: notesCtrl,
                      ),
                      const SizedBox(height: 20),
                    ],
                  )),

                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, exIdx) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                exercises[exIdx].name,
                              ),
                            ),
                            const SizedBox(height: 10),
                            //EXERCISES PANEL- SETS, WEIGHT, REPS, DONE
                            const Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                    child: Text('Set',
                                        textAlign: TextAlign.center)),
                                SizedBox(width: 10),
                                Expanded(
                                    flex: 2,
                                    child: Text('+Kg',
                                        textAlign: TextAlign.center)),
                                SizedBox(width: 10),
                                Expanded(
                                    flex: 2,
                                    child: Text('Reps',
                                        textAlign: TextAlign.center)),
                                SizedBox(width: 10),
                                Expanded(child: Icon(Icons.done_rounded))
                              ],
                            ),

                            const SizedBox(height: 10),

                            Column(
                              children: List.generate(
                                exercises[exIdx].sets.length,
                                (setIdx) {
                                  List<Sets> sets = exercises[exIdx].sets;
                                  return Dismissible(
                                    direction: DismissDirection.endToStart,
                                    key: UniqueKey(),
                                    onDismissed: (direction) async {
                                      if (direction ==
                                          DismissDirection.endToStart) {
                                        if (LocalPreferences.getUpdates(
                                                widget.workoutId)
                                            .isNotEmpty) {
                                          await FirestoreDatabase()
                                              .updateSets(widget.workoutId);
                                        }
                                        FirestoreDatabase().removeSet(
                                            widget.workoutId,
                                            exercises[exIdx].eid,
                                            setIdx);
                                      }
                                    },
                                    background:
                                        Container(color: Colors.redAccent),
                                    child: SetTile(
                                      wid: widget.workoutId,
                                      eid: exercises[exIdx].eid!,
                                      exIdx: exIdx,
                                      set: (setIdx + 1).toString(),
                                      weight: sets[setIdx].weight,
                                      reps: sets[setIdx].reps,
                                      isCompleted: sets[setIdx].completed,
                                    ),
                                  );
                                },
                              ),
                            ),

                            const SizedBox(height: 10),

                            //ADD SET BUTTON
                            SizedBox(
                              child: TextButton.icon(
                                // onPressed: () => FirestoreDatabase()
                                //     .addSet(widget.workoutId, exercises[exIdx].eid),
                                onPressed: () async {
                                  if (LocalPreferences.getUpdates(
                                          widget.workoutId)
                                      .isNotEmpty) {
                                    await FirestoreDatabase()
                                        .updateSets(widget.workoutId);
                                  }
                                  FirestoreDatabase().addSet(
                                      widget.workoutId, exercises[exIdx].eid);
                                },
                                icon: const Icon(Icons.add),
                                label: const Text('Add set',
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.grey[300],
                                    foregroundColor: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: exercises.length,
                    ),
                  ),

                  const SliverToBoxAdapter(
                    child: SizedBox(height: 20),
                  ),

                  // ADD ExERCISE
                  SliverToBoxAdapter(
                    child: SizedBox(
                      // child: Expanded(
                      child: TextButton(
                          onPressed: () async {
                            var newExerciseName = await addNewExercise(context);
                            if (newExerciseName != null) {
                              newExerciseName as String;
                              if (LocalPreferences.getUpdates(widget.workoutId)
                                  .isNotEmpty) {
                                await FirestoreDatabase()
                                    .updateSets(widget.workoutId);
                              }
                              LocalPreferences.addExerciseLocally(
                                  widget.workoutId, newExerciseName);
                            } else {
                              print('exercise name is empty');
                            }
                          },
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.blue[100],
                              foregroundColor: Colors.white),
                          child: const Text('Add exercise',
                              style: TextStyle(fontWeight: FontWeight.bold))),
                      // ),
                    ),
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 10)),

                  /*SliverToBoxAdapter(
                    child: Row(
                      children: [
                        Expanded(
                            child: TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                              backgroundColor: Colors.red[300],
                              foregroundColor: Colors.white),
                          child: const Text('Cancel',
                              style: TextStyle(fontWeight: FontWeight.bold)),
                        )),
                        const SizedBox(width: 20),
                        Expanded(
                            child: TextButton(
                                onPressed: () {},
                                style: TextButton.styleFrom(
                                    backgroundColor: Colors.green[200],
                                    foregroundColor: Colors.white),
                                child: const Text('Done',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold))))
                      ],
                    ),
                  )*/
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
