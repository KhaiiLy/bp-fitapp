import 'package:fitapp/services/auth/auth_page.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:fitapp/services/database/local_preferences.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'services/firebase_options.dart';
import 'package:fitapp/pages/home.dart';
import './data/models/workout.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await LocalPreferences.init();
  runApp(const FitApp());
}

class FitApp extends StatelessWidget {
  const FitApp({super.key});

  @override
  Widget build(BuildContext context) {
    // String? wID;
    // return MultiProvider(
    //   providers: const [
    //     //empty provider for now
    //   ],
    //   child:
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: GoogleFonts.lato().fontFamily),
      home: const FitAppHome(),
      // ),
    );
  }
}

class FitAppHome extends StatelessWidget {
  const FitAppHome({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamProvider<List<Workout>>(
      create: (context) => FirestoreDatabase().workouts,
      initialData: [], // Use an empty list as initialData
      catchError: (_, error) {
        print("error:  ${error.toString()}");
        return []; // Return an empty list in case of an error
      },
      // child: Home(),
      child: const AuthPage(),
    );
  }
}
