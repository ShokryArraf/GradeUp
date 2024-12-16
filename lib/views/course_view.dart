import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/material_view.dart';
import 'package:grade_up/service/student_courses_service.dart';

class CourseView extends StatefulWidget {
  final Student student;
  final String lesson;

  const CourseView({super.key, required this.student, required this.lesson});

  @override
  State<CourseView> createState() => _CourseViewState();
}

class _CourseViewState extends State<CourseView> {
  final _coursesService = StudentCoursesService();
  List<Map<String, dynamic>> _materials = []; // List to hold fetched materials
  bool _isLoading = true; // Loading state

  @override
  void initState() {
    super.initState();
    _fetchAndSetMaterials();
  }

  Future<void> _fetchAndSetMaterials() async {
    try {
      final materials = await _coursesService.fetchMaterials(
        lessonName: widget.lesson,
        student: widget.student,
      );
      setState(() {
        _materials = materials.reversed.toList(); // Save materials to the list
        _isLoading = false; // Set loading to false
      });
    } catch (error) {
      // Handle error
      showErrorDialog(context, 'Error fetching materials');
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials Overview'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator()) // Show spinner while loading
          : ListView(
              children: [
                // Dynamic list of materials
                ..._materials.map((material) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MaterialView(
                              student: widget.student,
                              lesson: widget.lesson,
                              materialID: material['id'],
                              materialTitle: material['title'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              spreadRadius: 2,
                              blurRadius: 5,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            material['title'] ??
                                'No Title', // Display material title
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
