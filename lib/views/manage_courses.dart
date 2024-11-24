import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/views/create_assignment_view.dart';
import 'package:grade_up/views/delete_assignment_section_view.dart';
import 'package:grade_up/views/manage_course.dart';

class ManageCourses extends StatefulWidget {
  final Teacher teacher;

  const ManageCourses({super.key, required this.teacher});

  @override
  State<ManageCourses> createState() =>
      _ManageCoursesState();
}

final List<Map<String, String>> _grades = [
  {'id': 'grade1', 'title': '6'},
  {'id': 'grade2', 'title': '7'},
  {'id': 'grade3', 'title': '8'},
  {'id': 'grade4', 'title': '9'},
];

class _ManageCoursesState extends State<ManageCourses> {

  String? _selectedLesson;
  String? _selectedGrade; // Example if you have other dependent dropdowns

  @override
  Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Manage Courses'),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(  // Change from GridView to Column
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch horizontally
        children: [
          // Dropdown taking full width
          DropdownButtonFormField<String>(
            decoration: InputDecoration(
              labelText: 'Select Grade',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            items: _grades.map((grade) {
              return DropdownMenuItem<String>(
                value: grade['id'] as String,
                child: Text(grade['title'] as String),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedGrade = value;
                _selectedLesson = null;
              });
            },
            validator: (value) =>
                value == null ? 'Please select a grade' : null,
            value: _selectedLesson,
          ),
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
                            ManageCourse(teacher: widget.teacher),
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
                            ManageCourse(teacher: widget.teacher),
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
