import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/student_service.dart';
import 'package:grade_up/utilities/build_content_card.dart';

class ContentView extends StatefulWidget {
  final Student student;
  final String lesson, materialID, contentID;

  const ContentView(
      {super.key,
      required this.student,
      required this.lesson,
      required this.materialID,
      required this.contentID});

  @override
  State<ContentView> createState() => _ContentViewState();
}

class _ContentViewState extends State<ContentView> {
  final _coursesService = StudentService();
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
        contentID: widget.contentID,
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
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Display existing content
                  ..._contentList.map((element) => buildContentCard(element)),
                ],
              ),
            ),
    );
  }
}
