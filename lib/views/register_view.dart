// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  late final TextEditingController _fullName;
  String _role = 'Student'; // Default role selection

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
    _fullName = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _fullName.dispose();
    super.dispose();
  }

  Future<void> _registerUser() async {
    final email = _email.text;
    final password = _password.text;
    final fullName = _fullName.text;

    try {
      // Register user with Firebase Auth
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      // Set display name to include full name and role
      await userCredential.user?.updateDisplayName("$_role: $fullName");

      // Optionally, you could also update the photoURL to store role information
      //await userCredential.user?.updatePhotoURL("Role: $_role");

      print('User registered successfully: ${userCredential.user}');
      // Navigate to another route (e.g., home or login)
      Navigator.of(context)
          .pushNamedAndRemoveUntil(loginRoute, (route) => false);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        await showErrorDialog(context, "Weak password.");
      } else if (e.code == 'email-already-in-use') {
        await showErrorDialog(context, 'Email already in use.');
      } else if (e.code == 'invalid-email') {
        await showErrorDialog(context, 'Invalid email entered.');
      } else {
        await showErrorDialog(context, 'Error: ${e.code}');
      }
    } catch (e) {
      await showErrorDialog(context, e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Register'),
      ),
      body: FutureBuilder(
        future: Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Full Name Input
                  TextField(
                    controller: _fullName,
                    decoration: const InputDecoration(hintText: 'Full Name'),
                  ),
                  // Email Input
                  TextField(
                    controller: _email,
                    enableSuggestions: false,
                    autocorrect: false,
                    keyboardType: TextInputType.emailAddress,
                    decoration:
                        const InputDecoration(hintText: 'Enter your email'),
                  ),
                  // Password Input
                  TextField(
                    controller: _password,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration:
                        const InputDecoration(hintText: 'Enter your password'),
                  ),
                  // Dropdown for Role Selection (Student/Teacher)
                  DropdownButton<String>(
                    value: _role,
                    items: ['Student', 'Teacher'].map((role) {
                      return DropdownMenuItem(
                        value: role,
                        child: Text(role),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _role = value!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  // Register Button
                  TextButton(
                    onPressed: _registerUser,
                    child: const Text('Register'),
                  ),
                  // Navigate to Login
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                          loginRoute, (route) => false);
                    },
                    child: const Text('Already registered? Login here!'),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
