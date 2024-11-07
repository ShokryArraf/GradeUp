// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/enums/menu_action.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/utilities/show_logout_dialog.dart';

class StudentMainView extends StatefulWidget {
  const StudentMainView({super.key});

  @override
  State<StudentMainView> createState() => _StudentMainViewState();
}

String getDisplayName() {
  final user = FirebaseAuth.instance.currentUser;
  return user != null
      ? user.displayName?.split(': ')[1] ?? 'Student'
      : 'Student';
}

class _StudentMainViewState extends State<StudentMainView> {
  @override
  Widget build(BuildContext context) {
    final displayName = getDisplayName();

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
              'Welcome back! Let’s start learning.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            // Example Progress Bar
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
                    // Navigate to courses page
                  }),
                  buildDashboardCard(
                      Icons.assignment, 'Assignments', Colors.orange, () {
                    // Navigate to assignments page
                  }),
                  buildDashboardCard(
                      Icons.bar_chart, 'Progress & Grades', Colors.purple, () {
                    // View progress and grades
                  }),
                  buildDashboardCard(Icons.settings, 'Settings', Colors.green,
                      () {
                    // Navigate to settings
                  }),
                  buildDashboardCard(
                      Icons.videogame_asset, 'Game', Colors.redAccent, () {
                    Navigator.of(context)
                        .pushNamed(gameoptionsRoute); // Route to the game page
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
