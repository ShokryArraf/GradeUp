// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/enums/menu_action.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/utilities/show_logout_dialog.dart';

class TeacherMainView extends StatefulWidget {
  const TeacherMainView({super.key});

  @override
  State<TeacherMainView> createState() => _TeacherMainViewState();
}

String getDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  return user != null
      ? user.displayName?.split(': ')[1] ?? 'Teacher'
      : 'Teacher';
}

class _TeacherMainViewState extends State<TeacherMainView> {
  @override
  Widget build(BuildContext context) {
    final displayName = getDisplayName();

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, $displayName!',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Welcome back! Ready to teach?',
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
                    // Post or manage assignments
                  }),
                  buildDashboardCard(
                      Icons.insights, 'Review Student Progress', Colors.purple,
                      () {
                    Navigator.of(context).pushNamed(studentgameprogressRoute);
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
