import 'package:fitapp/data/models/app_user.dart';
import 'package:fitapp/pages/view/profile_screen.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models/workout.dart';
import 'view/chat_screen.dart';
import 'view/home_screen.dart';

class HomeProviders extends StatelessWidget {
  const HomeProviders({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<String?>.value(value: FirebaseAuth.instance.currentUser?.uid),
        StreamProvider<List<AppUser>>.value(
            // ignore: prefer_const_literals_to_create_immutables
            value: FirestoreDatabase().users,
            initialData: []),
        StreamProvider<List<Workout>>(
            create: ((context) {
              final String? currentUserId =
                  Provider.of<String?>(context, listen: false);
              if (currentUserId != null) {
                return FirestoreDatabase().getWorkouts(currentUserId);
              } else {
                return const Stream<List<Workout>>.empty();
              }
            }),
            initialData: const []),
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
