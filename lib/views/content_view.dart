import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart'; // Import image_picker package
import 'dart:io';  // To handle file paths

class ContentView extends StatefulWidget {
  final Student student;

  const ContentView({super.key, required this.student});

  @override
  State<ContentView> createState() =>
      _ContentViewState();
}


class _ContentViewState extends State<ContentView> {

  String? _selectedLesson;
  String? _selectedGrade; // Example if you have other dependent dropdowns
  String? _selectedElement;
  List<Map<String, dynamic>> _contentList = [];
  
  // Controllers for text inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  
  File? _selectedImage;  // Holds the selected image file
  
  @override
  Widget build(BuildContext context) {
    
    _contentList.add({'type': 'title', 'data': 'THIS IS A TITLE'});
    _contentList.add({'type': 'text', 'data': 'Some random ass text for the sake presentation Some random ass text for the sake presentation Some random ass text for the sake presentation Some random ass text for the sake presentation Some random ass text for the sake presentation Some random ass text for the sake presentation'});
    


    return Scaffold(
      appBar: AppBar(
        title: const Text('Content title'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Element Section
            const Divider(),
            // Display existing content
            ..._contentList.map((element) => _buildContentCard(element)).toList(),
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