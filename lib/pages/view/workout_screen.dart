import 'package:fitapp/services/database/local_preferences.dart';
import 'package:flutter/material.dart';
import 'package:fitapp/pages/widgets/set_tile.dart';
import 'package:fitapp/data/models/exercise.dart';
import 'package:fitapp/data/models/sets.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:provider/provider.dart';

class WorkoutScreen extends StatelessWidget {
  final String workoutID;
  final String workoutName;

  const WorkoutScreen(
      {super.key, required this.workoutID, required this.workoutName});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Exercise>>.value(
      value: FirestoreDatabase().getExercises(workoutID),
      initialData: [],
      child: ExercisesWidget(wID: workoutID, wName: workoutName),
    );
  }
}

class ExercisesWidget extends StatefulWidget {
  final String wID;
  final String wName;
  const ExercisesWidget({
    super.key,
    required this.wID,
    required this.wName,
  });

  @override
  State<ExercisesWidget> createState() => _ExercisesWidgetState();
}

class _ExercisesWidgetState extends State<ExercisesWidget> {
  var newExerciseCtrl = TextEditingController();

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

  @override
  void dispose() {
    newExerciseCtrl.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    List<Exercise> data = Provider.of(context);
    LocalPreferences.saveExercises(widget.wID, data);
    List<Exercise> exercises = LocalPreferences.getExercises(widget.wID);

    return Scaffold(
        appBar: AppBar(
          title: Text(widget.wName),
          leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () {
                if (LocalPreferences.getUpdates(widget.wID).isNotEmpty) {
                  FirestoreDatabase().updateSets(widget.wID);
                }
                Navigator.of(context).pop();
              }),
        ),
        body: Container(
          margin: const EdgeInsets.all(25),
          child: CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                  child: Column(
                children: [
                  TextField(
                    decoration: InputDecoration(
                        hintText: "Notes", border: InputBorder.none),
                  ),
                  SizedBox(height: 20),
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
                                child:
                                    Text('Set', textAlign: TextAlign.center)),
                            SizedBox(width: 10),
                            Expanded(
                                flex: 2,
                                child:
                                    Text('+Kg', textAlign: TextAlign.center)),
                            SizedBox(width: 10),
                            Expanded(
                                flex: 2,
                                child:
                                    Text('Reps', textAlign: TextAlign.center)),
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
                                key: UniqueKey(),
                                onDismissed: (direction) {
                                  if (direction ==
                                      DismissDirection.endToStart) {
                                    FirestoreDatabase().removeSet(widget.wID,
                                        exercises[exIdx].eid, setIdx);
                                  }
                                },
                                background: Container(color: Colors.redAccent),
                                child: SetTile(
                                  wid: widget.wID,
                                  eid: exercises[exIdx].eid!,
                                  exIdx: exIdx,
                                  set: (setIdx + 1).toString(),
                                  weight: sets[setIdx].weight,
                                  reps: sets[setIdx].reps,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 10),

                        //ADD SET BUTTON
                        SizedBox(
                          child: TextButton.icon(
                            onPressed: () => FirestoreDatabase()
                                .addSet(widget.wID, exercises[exIdx].eid),
                            icon: const Icon(Icons.add),
                            label: const Text('Add set',
                                style: TextStyle(fontWeight: FontWeight.bold)),
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
                          LocalPreferences.addExerciseLocally(
                              widget.wID, newExerciseName);
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

              SliverToBoxAdapter(
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
                                style: TextStyle(fontWeight: FontWeight.bold))))
                  ],
                ),
              )
            ],
          ),
        ));
  }
}
