import 'package:flutter/material.dart';

class ShareWorkoutTile extends StatefulWidget {
  final String userName;
  final bool workoutSend;
  final bool isAccepted;
  final VoidCallback shareWorkout;
  final VoidCallback unshareWokrout;

  const ShareWorkoutTile({
    super.key,
    required this.userName,
    required this.workoutSend,
    required this.isAccepted,
    required this.shareWorkout,
    required this.unshareWokrout,
  });

  @override
  State<ShareWorkoutTile> createState() => _ShareWorkoutTileState();
}

class _ShareWorkoutTileState extends State<ShareWorkoutTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
          leading: const CircleAvatar(child: Icon((Icons.person))),
          title: Text(widget.userName, style: const TextStyle(fontSize: 14)),
          trailing: widget.isAccepted
              ? const Text('workout accepted')
              : widget.workoutSend
                  ? IconButton(
                      icon: const Icon(Icons.undo_rounded),
                      onPressed: widget.unshareWokrout,
                    )
                  : IconButton(
                      icon: const Icon(Icons.ios_share_sharp),
                      onPressed: widget.shareWorkout,
                    )),
    );
  }
}
