import 'package:fitapp/services/database/local_preferences.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class SetTile extends StatefulWidget {
  String wid;
  String eid;
  int exIdx;
  String? set;
  String? weight;
  String? reps;
  bool? isCompleted = false;

  SetTile({
    super.key,
    required this.wid,
    required this.eid,
    required this.exIdx,
    this.set,
    this.weight,
    this.reps,
    this.isCompleted,
  });

  @override
  State<SetTile> createState() => _SetTileState();
}

class _SetTileState extends State<SetTile> {
  TextEditingController setCtrl = TextEditingController();
  TextEditingController weightCtrl = TextEditingController();
  TextEditingController repsCtrl = TextEditingController();

  bool setCompleted = false;

  FocusNode weightNode = FocusNode();
  FocusNode repsNode = FocusNode();

  @override
  void initState() {
    super.initState();

    setControls();

    weightNode.addListener(() {
      if (!weightNode.hasFocus) {
        int setIdx = int.parse(setCtrl.text) - 1;
        LocalPreferences.updateExercise(
          widget.wid,
          widget.eid,
          widget.exIdx,
          setIdx,
          'weight',
          weightCtrl.text,
        );
      }
    });

    repsNode.addListener(() {
      if (!repsNode.hasFocus) {
        int setIdx = int.parse(setCtrl.text) - 1;
        LocalPreferences.updateExercise(
          widget.wid,
          widget.eid,
          widget.exIdx,
          setIdx,
          'reps',
          repsCtrl.text,
        );
      }
    });
  }

  void setControls() {
    if (widget.set!.isEmpty) {
      setCtrl.text = '';
    } else {
      setCtrl.text = widget.set.toString();
    }

    if (widget.weight!.isEmpty) {
      weightCtrl.text = '';
    } else {
      weightCtrl.text = widget.weight.toString();
    }

    if (widget.reps!.isEmpty) {
      repsCtrl.text = '';
    } else {
      repsCtrl.text = widget.reps.toString();
    }

    if (widget.isCompleted == null) {
      setCompleted = false;
    }
  }

  @override
  void dispose() {
    setCtrl.dispose();
    weightCtrl.dispose();
    repsCtrl.dispose();

    weightNode.removeListener(() {
      print("weightNode lost focus");
    });
    repsNode.removeListener(() {
      print("repsNode lost focus");
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(6),
              ),
              controller: setCtrl,
              readOnly: true,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              focusNode: weightNode,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(6),
              ),
              controller: weightCtrl,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            flex: 2,
            child: TextField(
              focusNode: repsNode,
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey[300],
                // enabledBorder: InputBorder.none,
                border: OutlineInputBorder(
                  borderSide: BorderSide.none,
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
                contentPadding: const EdgeInsets.all(6),
              ),
              controller: repsCtrl,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              alignment: Alignment.center,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                iconSize: 20,
                icon: setCompleted
                    ? const Icon(Icons.remove_rounded)
                    : const Icon(Icons.check_rounded),
                onPressed: () {
                  setState(
                    () {
                      setCompleted = !setCompleted;
                    },
                  );
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
