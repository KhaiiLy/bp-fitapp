import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../pages/home.dart';
import 'open_screen.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // USER IS LOGGED IN
          if (snapshot.hasData) {
            // return StreamProvider.value(
            //     value: FirestoreDatabase().workouts,
            //     initialData: [],
            //     child: const Home());
            return const HomeProviders();
          }
          // USER IS NOT LOGGED IN
          else {
            return const OpenScreen();
          }
        },
      ),
    );
  }
}
