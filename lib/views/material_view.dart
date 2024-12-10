import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/views/content_view.dart';
import 'package:grade_up/service/student_courses_service.dart';

class MaterialView extends StatefulWidget {
  final Student student;
  final String lesson, materialID, materialTitle;

  const MaterialView({super.key, required this.student, required this.lesson, required this.materialID, required this.materialTitle});

  @override
  State<MaterialView> createState() =>
      _MaterialViewState();
}

class _MaterialViewState extends State<MaterialView> {
  final _coursesService = StudentCoursesService();
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
        lessonName: widget.lesson, 
        student: widget.student, 
        materialID: widget.materialID, 
      );
      setState(() {
        _contentList = content; // Update the content list with fetched data
        _isLoading = false; // Stop loading when data is fetched
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
      print("Error fetching content: $error");
    }
  }
  @override
  Widget build(BuildContext context) {
    String sTitle = widget.materialTitle;
    return Scaffold(
      appBar: AppBar(
        title: Text(sTitle),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Show loading indicator while fetching
          :ListView.builder(
            itemCount: _contentList.length, 
            itemBuilder: (context, index) {
              final content = _contentList[index];
            // Regular content cards
            return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    child: GestureDetector(
                      onTap: () {
                        // Navigate to ManageContent or handle content card tap
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ContentView(student: widget.student, lesson: widget.lesson, materialID: widget.materialID, contentID: content['id'],),
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
                            content['title'] ?? 'No Title', // Display content title from Firestore
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
        },
      ),
    );
  }
}

