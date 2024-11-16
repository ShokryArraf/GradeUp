// ignore_for_file: use_build_context_synchronously

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/enums/menu_action.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/cloud_storage_exceptions.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/utilities/show_logout_dialog.dart';
import 'package:grade_up/views/create_assignment_view.dart';
import 'package:grade_up/views/student_progress_view.dart';

class TeacherMainView extends StatefulWidget {
  const TeacherMainView({super.key});

  @override
  State<TeacherMainView> createState() => _TeacherMainViewState();
}

class _TeacherMainViewState extends State<TeacherMainView> {
  Teacher? _teacher;

  @override
  void initState() {
    super.initState();
    _initializeTeacher();
  }

  Future<void> _initializeTeacher() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final teacherId = user.uid;
      final teacherDoc = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(teacherId)
          .get();

      if (teacherDoc.exists) {
        setState(() {
          _teacher = Teacher.fromFirestore(teacherDoc.data()!, teacherId);
        });
      } else {
        throw FailedToLoadTeacherDataException();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayName = _teacher?.name ?? 'Teacher';

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
            }
          }, itemBuilder: (context) {
            return [
              const PopupMenuItem<MenuAction>(
                value: MenuAction.logout,
                child: Text('Log out'),
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
                // Background gradient for the teacher info
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
                    // Teacher Image
                    Container(
                      margin: const EdgeInsets.all(16),
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        image: const DecorationImage(
                          image: AssetImage(
                              'images/teacher_logo.png'), // Replace with your image path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Teacher Info
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
                    // Navigate to course management
                  }),
                  buildDashboardCard(
                      Icons.assignment, 'Assignments', Colors.orange, () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CreateAssignmentView(teacher: _teacher!),
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
                            StudentProgressView(teacher: _teacher!),
                      ),
                    );
                  }),
                  buildDashboardCard(Icons.settings, 'Settings', Colors.green,
                      () {
                    // Navigate to settings
                  }),
                  buildDashboardCard(Icons.add, 'Game Editing', Colors.teal,
                      () {
                    Navigator.of(context).pushNamed(gameeditRoute);
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
