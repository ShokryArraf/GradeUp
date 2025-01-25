// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/student_view.dart';
import 'package:grade_up/views/teacher_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController();
    _password = TextEditingController();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('כניסה'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '!ברוך הבא',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _email,
              enableSuggestions: false,
              autocorrect: false,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'הכנס דוא"ל',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _password,
              obscureText: true,
              enableSuggestions: false,
              autocorrect: false,
              decoration: InputDecoration(
                hintText: 'הכנס סיסמא',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final email = _email.text;
                final password = _password.text;
                try {
                  final userCredential = await FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                          email: email, password: password);
                  if (userCredential.user != null) {
                    // Extract the name,role,school name from the displayName field
                    final displayName = userCredential.user?.displayName;
                    final parts = displayName?.split(': ');
                    final role = parts?[0];
                    final schoolName = parts?[2];

                    if (schoolName == null) {
                      await showErrorDialog(context, "מידע הבית ספר חסרה");
                      return;
                    }

                    if (role == "Student") {
                      final grade = parts?[3];
                      // Navigate to the student view, passing the school name
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudentMainView(
                            schoolName: schoolName.toString(),
                            grade: grade!,
                          ),
                        ),
                        (route) => false,
                      );
                    } else {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TeacherMainView(
                              schoolName: schoolName.toString()),
                        ),
                        (route) => false,
                      );
                    }
                  }
                } on FirebaseAuthException catch (e) {
                  if (e.code == 'user-not-found') {
                    await showErrorDialog(
                      context,
                      "משתמש לא נמצא",
                    );
                  } else if (e.code == 'wrong-password') {
                    await showErrorDialog(
                      context,
                      "סיסמא שגויה",
                    );
                  } else {
                    await showErrorDialog(
                      context,
                      'תכניס אימיל וסיסמא מתאימים',
                    );
                  }
                } catch (e) {
                  await showErrorDialog(
                    context,
                    "בבקשה צור קשר עם צוות העזרה",
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('כניסה'),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(registerRoute, (route) => false);
              },
              child: const Text('לא רשום עדיין? תירשם כאן'),
            ),
          ],
        ),
      ),
    );
  }
}
