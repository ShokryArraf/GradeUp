import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/enums/menu_action.dart';
import 'package:grade_up/game/game_options.dart';
import 'package:grade_up/models/student.dart'; // Import the Student model
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/utilities/show_logout_dialog.dart';
import 'package:grade_up/views/student/mycourses.dart';
import 'package:grade_up/views/student/student_progress_view.dart';

class StudentMainView extends StatefulWidget {
  final String schoolName;
  final String grade;

  const StudentMainView(
      {super.key, required this.schoolName, required this.grade});

  @override
  State<StudentMainView> createState() => _StudentMainViewState();
}

class _StudentMainViewState extends State<StudentMainView> {
  Student? _student;

  @override
  void initState() {
    super.initState();
    _initializeStudent();
  }

  Future<void> _initializeStudent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final studentDoc = await FirebaseFirestore.instance
            .collection('schools')
            .doc(widget.schoolName)
            .collection('grades')
            .doc(widget.grade)
            .collection('students')
            .doc(user.uid)
            .get();

        if (studentDoc.exists) {
          final studentData = studentDoc.data();
          if (studentData != null) {
            setState(() {
              _student = Student.fromFirestore(studentData, user.uid);
              _student?.school = widget.schoolName;
            });
          }
        }
      } catch (_) {
        throw FailedToLoadStudentDataException;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _student?.name ?? 'Student';
    final grade = _student?.grade.toString() ?? 'N/A';
    final schoolName = _student?.school ?? 'School';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Student Dashboard',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
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
        actions: [
          PopupMenuButton<MenuAction>(onSelected: (value) async {
            switch (value) {
              case MenuAction.logout:
                final shouldLogout = await showLogoutDialog(context);
                if (shouldLogout) {
                  await FirebaseAuth.instance.signOut();
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    loginRoute,
                    (_) => false,
                  );
                }
              case MenuAction.about:
                Navigator.of(context).pushNamed(aboutRoute);
                break;
              case MenuAction.help:
                // Navigate to help and support screen
                Navigator.of(context).pushNamed(helpSupportRoute);
                break;
            }
          }, itemBuilder: (context) {
            return [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Log out'),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.about,
                child: Text('About App'),
              ),
              const PopupMenuItem<MenuAction>(
                value: MenuAction.help,
                child: Text('Help and Support'),
              ),
            ];
          })
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.centerLeft,
              children: [
                // Background gradient for the student info
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFe0f7fa), Color(0xFFb2ebf2)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Student Image
                    Container(
                      margin: const EdgeInsets.all(16),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: AssetImage(
                              'images/student_logo.png'), // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Student Info
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Grade: $grade',
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                        Text(
                          schoolName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Welcome back! Let’s start learning.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            const Text(
              'Overall Progress',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.7, // This would be dynamically set
              backgroundColor: Colors.grey[300],
              color: Colors.teal,
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  buildDashboardCard(Icons.book, 'My Courses', Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyCourses(student: _student!),
                      ),
                    );
                  }),
                  buildDashboardCard(
                      Icons.bar_chart, 'Progress & Grades', Colors.purple, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentProgressSummaryView(student: _student!),
                      ),
                    );
                    // View progress and grades
                  }),
                  buildDashboardCard(
                      Icons.videogame_asset, 'Game', Colors.redAccent, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameOptionsPage(student: _student!),
                      ),
                    ); // Route to the game page
                  }),
                  buildDashboardCard(
                    Icons.warning_amber_rounded, // Warning icon
                    'Emergency', // Title of the card
                    Colors.red, // Red color for emergency
                    () {
                      // Navigate to Emergency Instructions
                      Navigator.of(context).pushNamed(emergencyRoute);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
