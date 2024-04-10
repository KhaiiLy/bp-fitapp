import 'package:flutter/material.dart';

import 'view/chat_screen.dart';
import 'view/home_screen.dart';

class Home extends StatefulWidget {
  Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // final currentUser = FirebaseAuth.instance.currentUser!;

  // SING-OUT METHOD
  void signOut() {
    // FirebaseAuth.instance.signOut();
  }

  // BOTTOM NAVIGATION BAR
  // :selected icon
  int _currentIndex = 0;

  // :method for selected icon
  void _selectScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // :paging
  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   actions: [
      //     IconButton(
      //       onPressed: signOut,
      //       icon: Icon(Icons.logout),
      //     ),
      //   ],
      // ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _selectScreen,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.message), label: "Messages"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
