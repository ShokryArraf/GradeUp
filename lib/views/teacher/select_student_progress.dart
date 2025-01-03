import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/views/teacher/progress_view.dart';
import 'package:grade_up/views/teacher/student_progress_game_view.dart';

class StudentProgressOptions extends StatefulWidget {
  final Teacher teacher;

  const StudentProgressOptions({super.key, required this.teacher});

  @override
  State<StudentProgressOptions> createState() => _StudentProgressOptionsState();
}

class _StudentProgressOptionsState extends State<StudentProgressOptions> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Student progress'),
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
                      Icons.bar_chart,
                      'Student Progress',
                      Colors.tealAccent,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgressView(
                              teacher: widget.teacher,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: 200,
                    height: 200,
                    child: buildDashboardCard(
                      Icons.star,
                      'Student Game Progress',
                      Colors.deepPurple,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                StudentProgressView(teacher: widget.teacher),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
