import 'package:fitapp/data/users/app_user.dart';
import 'package:fitapp/pages/view/profile_screen.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/workout/workout.dart';
import 'view/chat_screen.dart';
import 'view/home_screen.dart';

class HomeProviders extends StatefulWidget {
  const HomeProviders({super.key});

  @override
  State<HomeProviders> createState() => _HomeProvidersState();
}

class _HomeProvidersState extends State<HomeProviders> {
  @override
  Widget build(BuildContext context) {
    var currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return MultiProvider(
      providers: [
        StreamProvider<AppUser>.value(
          value: FirestoreDatabase().getAppUserData(currentUserId),
          initialData: AppUser(
              uid: '',
              name: '',
              lname: '',
              email: '',
              workouts: [],
              friends: [],
              fRequests: [],
              chatRoom: {}),
        ),
        StreamProvider<List<AppUser>>.value(
            value: FirestoreDatabase().users,
            // ignore: prefer_const_literals_to_create_immutables
            initialData: []),
        StreamProvider<List<Workout>>.value(
          value: FirestoreDatabase().getWorkouts(currentUserId),
          // ignore: prefer_const_literals_to_create_immutables
          initialData: [],
        ),
      ],
      child: const Home(),
    );
  }
}

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // BOTTOM NAVIGATION BAR
  int _currentIndex = 1;
  void _selectScreen(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // PAGING
  final List<Widget> _screens = [
    const HomeScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
