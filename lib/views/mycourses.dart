import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/views/course_view.dart';

class MyCourses extends StatefulWidget {
  final Student student;

  const MyCourses({super.key, required this.student});

  @override
  State<MyCourses> createState() =>
      _MyCoursesState();
}


class _MyCoursesState extends State<MyCourses> {

  String? _selectedLesson;
  String? _selectedGrade; // Example if you have other dependent dropdowns

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('My Courses'),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(  // Change from GridView to Column
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch horizontally
        children: [
          // Dropdown taking full width
          const SizedBox(height: 20),  // Add some spacing
          // GridView below for other items
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                buildDashboardCard(
                  Icons.plus_one,
                  'Math',
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseView(student: widget.student),
                      ),
                    );
                  },
                ),
                buildDashboardCard(
                  Icons.biotech,
                  'Biology',
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CourseView(student: widget.student),
                      ),
                    );
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
