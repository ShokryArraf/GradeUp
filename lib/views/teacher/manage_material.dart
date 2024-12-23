import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/teacher/manage_content.dart';
import 'package:grade_up/service/teacher_courses_service.dart';

class ManageMaterial extends StatefulWidget {
  final Teacher teacher;
  final int grade;
  final String lesson, materialID, materialTitle;

  const ManageMaterial(
      {super.key,
      required this.teacher,
      required this.grade,
      required this.lesson,
      required this.materialID,
      required this.materialTitle});

  @override
  State<ManageMaterial> createState() => _ManageMaterialState();
}

class _ManageMaterialState extends State<ManageMaterial> {
  final _coursesService = TeacherCoursesService();
  // Example if you have other dependent dropdowns
  bool showAddContentBox = true; // Toggle flag
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = true; // Loading state for fetching content
  List<Map<String, dynamic>> _contentList = []; // List to store fetched content

  @override
  void initState() {
    super.initState();
    _fetchContent(); // Fetch content when the widget is initialized
  }

  // Function to fetch content from Firestore
  Future<void> _fetchContent() async {
    try {
      final content = await _coursesService.fetchContent(
        lessonName: widget.lesson, // Passed from the ManageMaterial widget
        grade: widget.grade, // Passed from the ManageMaterial widget
        teacher: widget.teacher, // Passed from the ManageMaterial widget
        materialID: widget.materialID, // Passed from the ManageMaterial widget
      );
      setState(() {
        _contentList = content; // Update the content list with fetched data
        _isLoading = false; // Stop loading when data is fetched
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
      showErrorDialog(context, 'Error fetching content.');
    }
  }

  @override
  Widget build(BuildContext context) {
    String titleS = widget.materialTitle;
    return Scaffold(
      appBar: AppBar(
          title: Text('Manage \'$titleS\''),
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
      body: _isLoading
          ? const Center(
              child:
                  CircularProgressIndicator()) // Show loading indicator while fetching
          : ListView.builder(
              itemCount:
                  _contentList.length + 1, // 1 extra for "Add Content" card
              itemBuilder: (context, index) {
                if (index == 0) {
                  // Special "Add Content" card at the top
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: showAddContentBox
                        ? GestureDetector(
                            onTap: () {
                              setState(() {
                                showAddContentBox =
                                    false; // Show textbox on tap
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
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
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
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _titleController,
                                  decoration: InputDecoration(
                                    hintText: 'Enter Subject',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () async {
                                  if (_titleController.text.isNotEmpty) {
                                    String newTitle = _titleController.text;

                                    try {
                                      // Add the new content to Firestore
                                      await _coursesService.addContent(
                                        widget
                                            .lesson, // Lesson name passed from the widget
                                        grade: widget
                                            .grade, // Grade passed from the widget
                                        teacher: widget
                                            .teacher, // Teacher passed from the widget
                                        materialID: widget
                                            .materialID, // Material ID passed from the widget
                                        title:
                                            newTitle, // Content title from the TextField
                                      );

                                      // Update the local UI and reset the state
                                      setState(() {
                                        _contentList.add({
                                          'title': newTitle
                                        }); // Add the new content to the list
                                        showAddContentBox =
                                            true; // Show "Add Content" box again
                                        _titleController
                                            .clear(); // Clear the text field
                                      });

                                      _fetchContent();

                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content: Text(
                                                'Content added successfully!')),
                                      );
                                    } catch (_) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                            content:
                                                Text('Error adding content:')),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please enter the content title to add.')),
                                    );
                                  }
                                },
                                child: const Text('Add'),
                              ),
                              const SizedBox(width: 10),
                              ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    showAddContentBox =
                                        true; // Switch back to the default view
                                    _titleController
                                        .clear(); // Clear the text field if canceling
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                  );
                } else {
                  // Regular content cards based on fetched data
                  final content =
                      _contentList[index - 1]; // Adjust index for content list
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to ManageContent or handle content card tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageContent(
                              teacher: widget.teacher,
                              grade: widget.grade,
                              lesson: widget.lesson,
                              materialID: widget.materialID,
                              contentID: content['id'],
                            ),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.teal.shade200,
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
                            content['title'] ??
                                'No Title', // Display content title from Firestore
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
                }
              },
            ),
    );
  }
}
