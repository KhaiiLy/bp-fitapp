import 'package:flutter/material.dart';

class NotificationBadge extends StatefulWidget {
  final int numOfNot;
  const NotificationBadge({super.key, required this.numOfNot});

  @override
  State<NotificationBadge> createState() => _NotificationBadgeState();
}

class _NotificationBadgeState extends State<NotificationBadge> {
  @override
  Widget build(BuildContext context) {
    String count = widget.numOfNot.toString();
    return Positioned(
      right: -2,
      top: 3,
      child: Container(
        height: 20,
        width: 20,
        padding: const EdgeInsets.all(1.5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Container(
          height: 16,
          width: 16,
          padding: const EdgeInsets.all(0),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(count,
              style: const TextStyle(color: Colors.white, fontSize: 11),
              textAlign: TextAlign.center),
        ),
      ),
    );
  }
}
