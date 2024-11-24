import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/views/manage_week.dart';

class ManageCourse extends StatefulWidget {
  final Teacher teacher;

  const ManageCourse({super.key, required this.teacher});

  @override
  State<ManageCourse> createState() =>
      _ManageCourseState();
}

final List<Map<String, String>> _grades = [
  {'id': 'grade1', 'title': '6'},
  {'id': 'grade2', 'title': '7'},
  {'id': 'grade3', 'title': '8'},
  {'id': 'grade4', 'title': '9'},
];

class _ManageCourseState extends State<ManageCourse> {

  String? _selectedLesson;
  String? _selectedGrade; // Example if you have other dependent dropdowns

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Overview'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: 10, // Total number of weeks
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: GestureDetector(
              onTap: () {
                // Navigate to ManageWeek and pass the week number
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageWeek(teacher: widget.teacher),
                  ),
                );
              },
            child: Container(
              width: double.infinity,  // Full width
              height: 60,  // Set a fixed height for each box
              decoration: BoxDecoration(
                color: Colors.blueAccent,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),  // Shadow position
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  'Week #${index + 1}',  // Week number
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
          ));
        },
      ),
    );
  }
}

