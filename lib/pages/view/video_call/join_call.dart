import 'package:fitapp/pages/view/video_call/video_call_screen.dart';
import 'package:flutter/material.dart';

class JoinCall extends StatelessWidget {
  final String roomId;
  const JoinCall({super.key, required this.roomId});

  void _joinVideoCall(BuildContext context_) {
    print('_joinVideoCall invoked');
    Navigator.push(
      context_,
      MaterialPageRoute(
          builder: (context) => VideoCallScreen(
                roomId: roomId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: TextButton(
        onPressed: () {
          print('joining call');
          _joinVideoCall(context);
        },
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
          backgroundColor: Colors.green[300],
          foregroundColor: Colors.white,
        ),
        child: const Text('Join meet'),
      ),
    );
  }
}
