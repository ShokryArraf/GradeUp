import 'package:flutter/material.dart';
import 'package:grade_up/assignments/create_assignment_view.dart';
import 'package:grade_up/assignments/submitted_assignment_view.dart';
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
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Wrap(
                spacing: 16.0,
                runSpacing: 16.0,
                alignment: WrapAlignment.center,
                children: [
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: buildDashboardCard(
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
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: buildDashboardCard(
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
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 200,
                height: 200,
                child: buildDashboardCard(
                  Icons.assignment_turned_in,
                  'View Submitted Assignments',
                  Colors.blue,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewSubmittedAssignmentsView(
                          teacher: widget.teacher,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
