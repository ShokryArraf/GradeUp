import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/constants/routes.dart';
import 'package:grade_up/enums/menu_action.dart';

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
                  _buildDashboardCard(Icons.book, 'My Courses', Colors.blue,
                      () {
                    // Navigate to courses page
                  }),
                  _buildDashboardCard(
                      Icons.assignment, 'Assignments', Colors.orange, () {
                    // Navigate to assignments page
                  }),
                  _buildDashboardCard(
                      Icons.bar_chart, 'Progress & Grades', Colors.purple, () {
                    // View progress and grades
                  }),
                  _buildDashboardCard(Icons.settings, 'Settings', Colors.green,
                      () {
                    // Navigate to settings
                  }),
                  _buildDashboardCard(
                      Icons.videogame_asset, 'Game', Colors.redAccent, () {
                    Navigator.of(context)
                        .pushNamed(gameRoute); // Route to the game page
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

Widget _buildDashboardCard(
    IconData icon, String title, Color color, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 40),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    ),
  );
}

Future<bool> showLogoutDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Log out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: const Text('Log out'),
          ),
        ],
      );
    },
  ).then((value) => value ?? false);
}
