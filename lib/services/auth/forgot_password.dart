import 'package:firebase_auth/firebase_auth.dart';
import 'package:fitapp/services/auth/widgets/my_textfield.dart';
import 'package:flutter/material.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final emailCtrl = TextEditingController();

  Future _resetPassword(BuildContext context_) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailCtrl.text);
      if (context_.mounted) {
        showDialog(
          context: context_,
          builder: (context) => const AlertDialog(
            shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(1))),
            content: Text('Password reset link sent.'),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (context_.mounted) {
        showDialog(
          context: context_,
          builder: (context) => AlertDialog(
            shape: const BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(1))),
            content: Text(e.message.toString()),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Enter your email to reset password'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: MyTextField(
                controller: emailCtrl, labelText: "email", obscureText: false),
          ),
          const SizedBox(height: 15),
          ElevatedButton(
            onPressed: () => _resetPassword(context),
            child: const Text('Reset Password'),
          )
        ],
      ),
    );
  }
}
