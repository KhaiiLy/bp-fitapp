import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:fitapp/services/auth/register_screen.dart';
import 'widgets/my_textfield.dart';

class LoginScreen extends StatefulWidget {
  final Function()? onTap;
  const LoginScreen({super.key, this.onTap});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // input controls
  final emailCtrler = TextEditingController();
  final passwdCtrler = TextEditingController();

  // loading circle
  bool _isLoading = false;

  // sign-in method
  void signIn() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailCtrler.text, password: passwdCtrler.text);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        print('Invalid combination of email and password');
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    emailCtrler.dispose();
    passwdCtrler.dispose();
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
            const SizedBox(height: 35),

            // USER INPUTS
            MyTextField(
                controller: emailCtrler,
                labelText: "Email",
                obscureText: false),
            MyTextField(
                controller: passwdCtrler,
                labelText: "Password",
                obscureText: true),
            const SizedBox(height: 10),

            // FORGOT PASSWORD
            Text(
              "Forgot Password?",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 25),

            // LOGIN BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(140, 50),
                backgroundColor: const Color.fromARGB(255, 73, 185, 216),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              onPressed: _isLoading ? null : signIn,
              child: _isLoading
                  ? const SizedBox(
                      height: 25,
                      width: 25,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text("Log In", style: TextStyle(fontSize: 20)),
            ),

            const Expanded(child: SizedBox(height: 25)),

            const Text("Not on FitApp yet?"),
            GestureDetector(
              onTap: widget.onTap,
              /*() {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegisterPage(),
                  ),
                );
              },*/
              child: const Text(
                "Sign Up",
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
