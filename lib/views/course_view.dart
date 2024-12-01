import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/views/week_view.dart';
import 'package:grade_up/views/mycourses.dart';

class CourseView extends StatefulWidget {
  final Student student;

  const CourseView({super.key, required this.student});

  @override
  State<CourseView> createState() =>
      _CourseViewState();
}


class _CourseViewState extends State<CourseView> {

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
                    builder: (context) => WeekView(student: widget.student),
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

