import 'package:flutter/material.dart';

class ChatSearchhBar extends StatefulWidget {
  final void Function(String) runFilter;
  const ChatSearchhBar({
    super.key,
    required this.runFilter,
  });

  @override
  State<ChatSearchhBar> createState() => _ChatSearchhBarState();
}

class _ChatSearchhBarState extends State<ChatSearchhBar> {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextField(
        onChanged: ((value) {
          widget.runFilter(value);
        }),
        style: const TextStyle(fontSize: 14),
        decoration: InputDecoration(
          hintText: 'Search',
          contentPadding: const EdgeInsets.all(8),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey.shade600,
          ),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(color: Colors.grey.shade100),
          ),
        ),
      ),
    );
  }
}
