import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart'; // Import image_picker package
import 'dart:io';  // To handle file paths
import 'package:grade_up/service/teacher_courses_service.dart';

class ManageContent extends StatefulWidget {
  final Teacher teacher;
  final int grade;
  final String lesson, materialID, contentID;

  const ManageContent({super.key, required this.teacher, required this.grade, required this.lesson, required this.materialID, required this.contentID});

  @override
  State<ManageContent> createState() =>
      _ManageContentState();
}


class _ManageContentState extends State<ManageContent> {
  final _coursesService = TeacherCoursesService();
  String? _selectedElement;
  List<Map<String, dynamic>> _contentList = [];
  bool _isLoading = true;

  File? _selectedImage;  // Holds the selected image file
  // Controllers for text inputs
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

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
        grade: widget.grade,
        teacher: widget.teacher,
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
        title: const Text('Add Content'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Add Element Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedElement == null
                        ? _buildElementSelectionBox()
                        : _buildElementInputBox(),
                  ),
                  const Divider(),
                  // Display existing content
                  ..._contentList.map((element) => _buildContentCard(element)),
                ],
              ),
            ),
    );
  }
  // Element Selection UI
  Widget _buildElementSelectionBox() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const Text(
            'Add New Content Element',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildElementCard(Icons.title, 'Title', 'title'),
              _buildElementCard(Icons.image, 'Media', 'media'),
              _buildElementCard(Icons.text_fields, 'Text', 'text'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildElementCard(IconData icon, String label, String type) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedElement = type;
        });
      },
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  Widget _buildElementInputBox() {
    switch (_selectedElement) {
      case 'title':
        return _buildTitleInput();
      case 'media':
        return _buildMediaInput();
      case 'text':
        return _buildTextInput();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildTitleInput() {
    return Column(
      children: [
        TextField(
          controller: _titleController,
          decoration: const InputDecoration(
            labelText: 'Enter Title',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (_titleController.text.isNotEmpty) {
              String newData = _titleController.text;
              try {
                await _coursesService.addBlock(
                  widget.lesson, grade: widget.grade, teacher: widget.teacher, materialID: widget.materialID, contentID: widget.contentID, type: 'title', data: newData
                );
                
                  setState(() {
                    _contentList.add({'type': 'title', 'data': _titleController.text});
                    _titleController.clear();
                    _selectedElement = null;
                  });
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Title block added successfully!')),
                    );
              } catch (error){
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding content: $error')),
                );
              }
            }
          },
          child: const Text('Add Title'),
        ),
      ],
    );
  }

  Widget _buildMediaInput() {
    return Column(
      children: [
        _selectedImage != null
            ? Image.file(_selectedImage!, height: 150)
            : const Icon(Icons.image, size: 100, color: Colors.blueAccent),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed:() {
          },
          child: const Text('Upload Media'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            if (_selectedImage != null) {
              setState(() {
                _contentList.add({'type': 'media', 'data': _selectedImage});
                _selectedImage = null;
                _selectedElement = null;
              });
            }
          },
          child: const Text('Add Media'),
        ),
      ],
    );
  }


  Widget _buildTextInput() {
    return Column(
      children: [
        TextField(
          controller: _textController,
          maxLines: 4,
          decoration: const InputDecoration(
            labelText: 'Enter Text',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async{
            if (_textController.text.isNotEmpty) {
              String newData = _textController.text;
              try {
                await _coursesService.addBlock(
                  widget.lesson, grade: widget.grade, teacher: widget.teacher, materialID: widget.materialID, contentID: widget.contentID, type: 'text', data: newData
                );
                
                  setState(() {
                    _contentList.add({'type': 'text', 'data': _textController.text}); //add locally
                    _contentList.add({'type': 'media', 'data': ''}); //add locally
                    _textController.clear();
                    _selectedElement = null;
                  });
                   ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Text block added successfully!')),
                    );
              } catch (error){
                ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error adding content: $error')),
                );
              }
            }
          },
          child: const Text('Add Text'),
        ),
      ],
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
        return Image.network(
          'https://creatorset.com/cdn/shop/files/Screenshot_2024-01-29_223308_1920x.png?v=1706560563',
          fit: BoxFit.cover, // Adjust how the image fits its container
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child; // Show the image when fully loaded
            return Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
              : null,
            ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.error); // Show an error icon if the image fails to load
          },
        );
      case 'text':
        return ListTile(
          title: Text(element['data']),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}