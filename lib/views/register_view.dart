// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
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

  // Available lessons
  final List<String> _availableLessons = [
    'Math',
    'English',
    'Hebrew',
    'Geography',
    'Biology',
    'Chemistry',
  ];

  // Grades (1 to 8)
  final List<int> _grades = List.generate(8, (index) => index + 1);

  // Selected lessons and grades
  final Set<String> _selectedLessons = {};
  final Set<int> _selectedGrades = {};

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

      // Firestore: Save user details based on role
      final userId = userCredential.user?.uid;
      if (userId != null) {
        final userCollection = FirebaseFirestore.instance.collection(
          _role == 'Teacher' ? 'teachers' : 'students',
        );

        final data = {
          'name': fullName,
          _role == 'Teacher' ? 'assignedLessons' : 'enrolledLessons':
              _selectedLessons.toList(),
          if (_role == 'Teacher') 'teachingGrades': _selectedGrades.toList(),
          if (_role == 'Student') 'grade': _selectedGrades.first,
        };

        await userCollection.doc(userId).set(data);
        if (_role == 'Student') {
          await FirebaseFirestore.instance
              .collection('userprogress')
              .doc(userId)
              .set({
            'exists':
                true, // Placeholder field to make the document visible in queries
            'grade': _selectedGrades.first
          }, SetOptions(merge: true));
        }
      }

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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Full Name Input
                    TextField(
                      controller: _fullName,
                      decoration: const InputDecoration(hintText: 'Full Name'),
                    ),
                    const SizedBox(height: 8),
                    // Email Input
                    TextField(
                      controller: _email,
                      enableSuggestions: false,
                      autocorrect: false,
                      keyboardType: TextInputType.emailAddress,
                      decoration:
                          const InputDecoration(hintText: 'Enter your email'),
                    ),
                    const SizedBox(height: 8),
                    // Password Input
                    TextField(
                      controller: _password,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                          hintText: 'Enter your password'),
                    ),
                    const SizedBox(height: 16),
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
                          _selectedLessons.clear();
                          _selectedGrades.clear();
                        });
                      },
                    ),
                    const SizedBox(height: 16),
                    // Lesson Selection
                    Text(
                      _role == 'Teacher'
                          ? 'Select Assigned Lessons:'
                          : 'Select Enrolled Lessons:',
                    ),
                    const SizedBox(height: 8),
                    Column(
                      children: _availableLessons.map((lesson) {
                        return CheckboxListTile(
                          title: Text(lesson),
                          value:
                              _selectedLessons.contains(lesson.toLowerCase()),
                          onChanged: (isSelected) {
                            setState(() {
                              if (isSelected == true) {
                                _selectedLessons.add(lesson.toLowerCase());
                              } else {
                                _selectedLessons.remove(lesson.toLowerCase());
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16),
                    // Grade Selection
                    if (_role == 'Teacher') ...[
                      const Text('Select Grades You Teach:'),
                      Column(
                        children: _grades.map((grade) {
                          return CheckboxListTile(
                            title: Text('Grade $grade'),
                            value: _selectedGrades.contains(grade),
                            onChanged: (isSelected) {
                              setState(() {
                                if (isSelected == true) {
                                  _selectedGrades.add(grade);
                                } else {
                                  _selectedGrades.remove(grade);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ] else if (_role == 'Student') ...[
                      const Text('Select Your Grade:'),
                      Column(
                        children: _grades.map((grade) {
                          return RadioListTile<int>(
                            title: Text('Grade $grade'),
                            value: grade,
                            groupValue: _selectedGrades.isNotEmpty
                                ? _selectedGrades.first
                                : null,
                            onChanged: (selectedGrade) {
                              setState(() {
                                _selectedGrades
                                  ..clear()
                                  ..add(selectedGrade!);
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ],
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
