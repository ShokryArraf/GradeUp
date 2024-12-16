import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/views/course_view.dart';

class MyCourses extends StatefulWidget {
  final Student student;

  const MyCourses({super.key, required this.student});

  @override
  State<MyCourses> createState() => _MyCoursesState();
}

class _MyCoursesState extends State<MyCourses> {
  @override
  Widget build(BuildContext context) {
    final courses = widget.student.enrolledLessons;
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Courses'),
          centerTitle: true,
          backgroundColor: Colors.blueAccent,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            // Change from GridView to Column
            crossAxisAlignment:
                CrossAxisAlignment.stretch, // Stretch horizontally
            children: [
              // Dropdown taking full width
              const SizedBox(height: 20), // Add some spacing
              // GridView below for other items
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  children: courses.map((course) {
                    // Build a card for each course
                    return GestureDetector(
                      child: buildDashboardCard(
                        course == 'math'
                            ? Icons.calculate
                            : course == 'english'
                                ? Icons.explicit
                                : course == 'biology'
                                    ? Icons.biotech
                                    : course == 'geography'
                                        ? Icons.public
                                        : course == 'chemistry'
                                            ? Icons.science
                                            : course == 'hebrew'
                                                ? Icons.book
                                                : Icons.help,
                        course.toString().toUpperCase(),
                        course == 'math'
                            ? Colors.green
                            : course == 'english'
                                ? Colors.red
                                : course == 'biology'
                                    ? const Color.fromARGB(255, 131, 23, 50)
                                    : course == 'geography'
                                        ? Colors.brown
                                        : course == 'chemistry'
                                            ? Colors.yellow
                                            : course == 'hebrew'
                                                ? Colors.black
                                                : Colors
                                                    .blue, // Change color when selected
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => CourseView(
                                  student: widget.student, lesson: course),
                            ),
                          );
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ));
  }
}
