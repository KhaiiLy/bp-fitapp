import 'package:fitapp/services/database/firestore_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/user.dart';
import '../data/models/workout.dart';
import 'view/chat_screen.dart';
import 'view/home_screen.dart';

class HomeProviders extends StatelessWidget {
  const HomeProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // StreamProvider.value(
        //     value: FirestoreDatabase().users, initialData: const []),
        StreamProvider<List<Workout>>.value(
            value: FirestoreDatabase().workouts, initialData: const []),
      ],
      child: const Home(),
    );
    // );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final currentUser = FirebaseAuth.instance.currentUser?.uid;

  void signOut() {
    // FirebaseAuth.instance.signOut();
  }

  // BOTTOM NAVIGATION BAR
  int _currentIndex = 0;
  void _selectScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // PAGING
  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    print('home.dart >> $currentUser');

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
