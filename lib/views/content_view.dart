import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart'; // Import image_picker package
import 'dart:io';  // To handle file paths
import 'package:grade_up/service/student_courses_service.dart';

class ContentView extends StatefulWidget {
  final Student student;
  final String lesson, materialID, contentID;

  const ContentView({super.key, required this.student, required this.lesson, required this.materialID, required this.contentID});

  @override
  State<ContentView> createState() =>
      _ContentViewState();
}


class _ContentViewState extends State<ContentView> {
  final _coursesService = StudentCoursesService();
  bool _isLoading = true; // Loading state for fetching content
  List<Map<String, dynamic>> _contentList = []; // List to store fetched content
 

  @override
  void initState() {
    super.initState();
    _fetchBlocks(); // Fetch content blocks when the page loads
  }

  // Method to fetch blocks from the database
  Future<void> _fetchBlocks() async {
    try {
      final blocks = await _coursesService.fetchBlocks(
        lessonName: widget.lesson,
        student: widget.student,
        materialID: widget.materialID,
        contentID: widget.contentID
      );
      setState(() {
        _contentList = blocks; // Update the content list with fetched blocks
        _isLoading = false; // Stop loading
      });
    } catch (error) {
      setState(() {
        _isLoading = false; // Stop loading even if there is an error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching blocks: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Content'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display existing content
                  ..._contentList.map((element) => _buildContentCard(element)),
                ],
              ),
            ),
    );
  }


  // Render each content card dynamically
  Widget _buildContentCard(Map<String, dynamic> element) {
    switch (element['type']) {
      case 'title':
        return ListTile(
          title: Text(
            element['data'],
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        );
      case 'media':
        return Image.file(element['data'], height: 150);
      case 'text':
        return ListTile(
          title: Text(element['data']),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}