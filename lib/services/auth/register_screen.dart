import 'package:fitapp/data/models/app_user.dart';
import 'package:fitapp/services/database/firestore_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'widgets/my_textfield.dart';

class RegisterScreen extends StatefulWidget {
  final Function()? onTap;
  const RegisterScreen({super.key, this.onTap});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // input controls
  final nameCtrler = TextEditingController();
  final lNameCtrler = TextEditingController();
  final emailCtrler = TextEditingController();
  final passwdCtrler = TextEditingController();
  final confirmPasswdCtrler = TextEditingController();

  bool _isLoading = false;

  // sign-up method
  void signUp() async {
    setState(() {
      _isLoading = true;
    });

    if (passwdCtrler.text == confirmPasswdCtrler.text) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailCtrler.text,
          password: passwdCtrler.text,
        );
        // create a new document for the user with the uid
        User? user = userCredential.user;
        if (user != null) {
          AppUser appUser = AppUser(
            uid: user.uid,
            name: nameCtrler.text,
            lname: lNameCtrler.text,
            email: emailCtrler.text,
            workouts: [],
            friends: [],
            fRequests: [],
          );
          FirestoreDatabase().addNewRegistered(appUser);
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'email-already-in-use') {
          print('The account already exists for that email.');
        }
      }
    } else {
      print("Passwords don't match");
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    nameCtrler.dispose();
    lNameCtrler.dispose();
    emailCtrler.dispose();
    passwdCtrler.dispose();
    confirmPasswdCtrler.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF1F6F5),
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            const SizedBox(height: 50),

            Image.asset(
              'lib/images/pokeball.png',
              height: 165,
            ),
            const SizedBox(height: 15),

            const Text(
              "Create an account",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            // USER INPUTS
            MyTextField(
                controller: nameCtrler, labelText: "Name", obscureText: false),
            MyTextField(
                controller: lNameCtrler,
                labelText: "Last name",
                obscureText: false),
            MyTextField(
                controller: emailCtrler,
                labelText: "Email",
                obscureText: false),
            MyTextField(
                controller: passwdCtrler,
                labelText: "Password",
                obscureText: true),
            MyTextField(
                controller: confirmPasswdCtrler,
                labelText: "Confirm password",
                obscureText: true),
            const SizedBox(height: 35),

            // SING-UP BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 50),
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _isLoading ? null : signUp,
              child: _isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Sing Up",
                      style: TextStyle(
                        fontSize: 20,
                      )),
            ),

            const Expanded(child: SizedBox(height: 25)),

            const Text("Already have an account?"),
            GestureDetector(
              onTap: widget.onTap,
              child: const Text(
                "Sing In",
                style: TextStyle(
                  color: Color(0xff4B56D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 35),
          ],
        ),
      )),
    );
  }
}
