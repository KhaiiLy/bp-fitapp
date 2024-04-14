import 'package:fitapp/pages/widgets/user_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/app_user.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Chat();
  }
}

class Chat extends StatefulWidget {
  const Chat({super.key});

  @override
  State<Chat> createState() => _ChatState();
}

class _ChatState extends State<Chat> {
  final TextEditingController _searchCtrl = TextEditingController();
  List<AppUser> _foundUsers = [];
  List<AppUser> users = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    users = Provider.of<List<AppUser>>(context);
    setState(() {
      _foundUsers = users;
    });
  }

  void _runFilter(String txtSearch) {
    List<AppUser> data = [];
    if (txtSearch.isEmpty) {
      data = users;
    } else if (txtSearch.isNotEmpty) {
      data = users.where((user) {
        String fullName = "${user.name} ${user.lname}";
        return fullName.toLowerCase().contains(txtSearch.toLowerCase());
      }).toList();
    }
    setState(() {
      _foundUsers = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chat Screen'),
        actions: [],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 40,
              child: TextField(
                controller: _searchCtrl,
                onChanged: ((value) => _runFilter(value)),
                style: const TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Connect here ..',
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
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: _foundUsers.length,
                itemBuilder: (context, idx) {
                  var fullName =
                      "${_foundUsers[idx].name} ${_foundUsers[idx].lname}";
                  return UserTile(userName: fullName);
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
