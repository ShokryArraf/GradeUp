import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/enums/menu_action.dart';
import 'package:grade_up/game/game_editing_view.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/teacher_service.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/utilities/show_logout_dialog.dart';
import 'package:grade_up/assignments/assignment_manage_options.dart';
import 'package:grade_up/views/teacher/grade_selection_view.dart';
import 'package:grade_up/views/teacher/student_progress_options.dart';

class TeacherMainView extends StatefulWidget {
  final String schoolName;

  const TeacherMainView({super.key, required this.schoolName});

  @override
  State<TeacherMainView> createState() => _TeacherMainViewState();
}

class _TeacherMainViewState extends State<TeacherMainView> {
  Teacher? _teacher;
  final TeacherService _firestoreService = TeacherService();

  @override
  void initState() {
    super.initState();
    _initializeTeacher();
  }

  Future<void> _initializeTeacher() async {
    try {
      final teacher =
          await _firestoreService.fetchTeacherData(widget.schoolName);
      setState(() {
        _teacher = teacher;
      });
    } catch (_) {
      await showErrorDialog(
        context,
        "Failed to load teacher data",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _teacher?.name ?? 'Teacher';
    final schoolName = _teacher?.school ?? 'School';

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Teacher Dashboard',
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
              case MenuAction.emergency:
                Navigator.of(context).pushNamed(emergencyRoute);
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
              const PopupMenuItem<MenuAction>(
                value: MenuAction.emergency,
                child: Text('Emergency'),
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
                Container(
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFffe0b2), Color(0xFFffcc80)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: const EdgeInsets.all(16),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: AssetImage('images/teacher_logo.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
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
                          schoolName,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                        ),
                        const Text(
                          'Welcome back!',
                          style: TextStyle(
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
              'Ready to teach?',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                children: [
                  buildDashboardCard(
                      Icons.manage_accounts, 'Manage Courses', Colors.blue, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GradeSelection(teacher: _teacher!),
                      ),
                    );
                  }),
                  buildDashboardCard(
                      Icons.assignment, 'Assignments', Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AssignmentManageOptions(teacher: _teacher!),
                      ),
                    );
                  }),
                  buildDashboardCard(
                      Icons.insights, 'Review Student Progress', Colors.purple,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            StudentProgressOptions(teacher: _teacher!),
                      ),
                    );
                  }),
                  buildDashboardCard(Icons.add, 'Game Editing', Colors.teal,
                      () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            GameEditingView(teacher: _teacher!),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
