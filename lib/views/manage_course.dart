import 'dart:io';
import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/views/manage_material.dart';
import 'package:grade_up/service/teacher_courses_service.dart';

class ManageCourse extends StatefulWidget {
  final Teacher teacher;
  final int grade;
  final String lesson;

  const ManageCourse({super.key, required this.teacher, required this.grade, required this.lesson});

  @override

  

  State<ManageCourse> createState() =>
      _ManageCourseState();
}


class _ManageCourseState extends State<ManageCourse> {
  final _coursesService = TeacherCoursesService();
  final TextEditingController _contentController = TextEditingController();
  
  List<Map<String, dynamic>> _materials = []; // List to hold fetched materials
  bool _isLoading = true; // Loading state
  bool _isAddingContent = false; // Tracks if the "Add Content" box is open

  @override
  void initState() {
    super.initState();
    _fetchAndSetMaterials();
  }

  Future<void> _fetchAndSetMaterials() async {
    try {
      final materials = await _coursesService.fetchMaterials(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
      );
      setState(() {
        _materials = materials.reversed.toList(); // Save materials to the list
        _isLoading = false; // Set loading to false
      });
    } catch (error) {
      // Handle error
      print("Error fetching materials: $error");
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
    }
  }

  Future<void> _addContent() async {
    if (_contentController.text.isNotEmpty) {
    String newTitle = _contentController.text;

    // Call the addMaterial function to save the content in Firestore
    try {
      await _coursesService.addMaterial(
        widget.lesson, // lessonName passed from the ManageCourse widget
        grade: widget.grade, // grade passed from the ManageCourse widget
        teacher: widget.teacher, // teacher passed from the ManageCourse widget
        title: newTitle,
      );
ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Assignment created and assigned to students!')),
      );
      // Update the local _materials list
      setState(() {
        _materials.add({'title': newTitle});
        _isAddingContent = false;
        _contentController.clear(); // Clear the input
      });
    } catch (error) {
      exit(0);
    }
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
          ? const Center(child: CircularProgressIndicator()) // Show spinner while loading
          : ListView(
              children: [
                // "Add Content" section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  child: _isAddingContent
                      ? Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _contentController,
                                decoration: InputDecoration(
                                  hintText: 'Enter content title',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _addContent,
                              child: const Text('Add'),
                            ),
                          ],
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              _isAddingContent = true; // Switch to text box view
                            });
                          },
                          child: Container(
                            width: double.infinity,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add, color: Colors.black54),
                                SizedBox(width: 10),
                                Text(
                                  'Add Content',
                                  style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                ),
                // Dynamic list of materials
                ..._materials.map((material) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageMaterial(teacher: widget.teacher, grade: widget.grade, lesson: widget.lesson, materialID: material['id'], materialTitle: material['title'],),
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
                            material['title'] ?? 'No Title', // Display material title
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
                }).toList(),
              ],
            ),
    );
  }
}