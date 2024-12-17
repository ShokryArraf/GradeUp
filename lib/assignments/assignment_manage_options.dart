import 'package:flutter/material.dart';
import 'package:grade_up/assignments/create_assignment_view.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/assignments/search_delete_assignment_view.dart';

class AssignmentManageOptions extends StatefulWidget {
  final Teacher teacher;

  const AssignmentManageOptions({super.key, required this.teacher});

  @override
  State<AssignmentManageOptions> createState() =>
      _AssignmentManageOptionsState();
}

class _AssignmentManageOptionsState extends State<AssignmentManageOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Assignments'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            buildDashboardCard(
              Icons.create,
              'Create Assignments',
              Colors.green,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        CreateAssignmentView(teacher: widget.teacher),
                  ),
                );
              },
            ),
            buildDashboardCard(
              Icons.search,
              'Search,Edit & Delete Assignments',
              Colors.red,
              () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchDeleteAssignmentSection(
                      teacher: widget.teacher,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
