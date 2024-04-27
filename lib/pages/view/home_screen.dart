import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/data/workout/workout.dart';
import 'package:fitapp/pages/view/workout_screen.dart';

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
  int? _loadingIndex = null;

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
  void navToWorkoutScreen(String wID, String workoutName, int idx) async {
    setState(() {
      _loadingIndex = idx;
    });

    await Future.delayed(const Duration(seconds: 1));
    if (context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              WorkoutScreen(workoutID: wID, workoutName: workoutName),
        ),
      );
    }

    setState(() {
      // _isLoading = false;
      _loadingIndex = null;
    });
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

    return Scaffold(
      appBar: AppBar(title: const Text('FitApp')),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewWorkout,
        child: const Icon(Icons.add_circle_rounded, size: 50),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
                itemCount: workouts.length,
                itemBuilder: (context, idx) {
                  if (_loadingIndex == idx) {
                    return ListTile(
                      title: Text(workouts[idx].name),
                      trailing: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  } else {
                    return ListTile(
                      title: Text(workouts[idx].name),
                      trailing: IconButton(
                        onPressed: () {
                          String? wID = workouts[idx].wid;
                          if (wID != null) {
                            navToWorkoutScreen(wID, workouts[idx].name, idx);
                          }
                        },
                        icon: const Icon(Icons.arrow_forward_ios_rounded),
                      ),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }
}
