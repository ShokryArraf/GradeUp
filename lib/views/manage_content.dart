import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart'; // File picker for selecting files
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for file uploads
import 'package:grade_up/models/teacher.dart'; // Import image_picker package
import 'dart:io'; // To handle file paths
import 'package:grade_up/service/teacher_courses_service.dart';

class ManageContent extends StatefulWidget {
  final Teacher teacher;
  final int grade;
  final String lesson, materialID, contentID;

  const ManageContent(
      {super.key,
      required this.teacher,
      required this.grade,
      required this.lesson,
      required this.materialID,
      required this.contentID});

  @override
  State<ManageContent> createState() => _ManageContentState();
}

class _ManageContentState extends State<ManageContent> {
  final _coursesService = TeacherCoursesService();
  String? _selectedElement;
  List<Map<String, dynamic>> _contentList = [];
  bool _isLoading = true;

  File? _selectedImage; // Holds the selected image file
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
          contentID: widget.contentID);
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
                await _coursesService.addBlock(widget.lesson,
                    grade: widget.grade,
                    teacher: widget.teacher,
                    materialID: widget.materialID,
                    contentID: widget.contentID,
                    type: 'title',
                    data: newData);

                setState(() {
                  _contentList
                      .add({'type': 'title', 'data': _titleController.text});
                  _titleController.clear();
                  _selectedElement = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Title block added successfully!')),
                );
              } catch (error) {
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

  String _getFileType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(extension)) return 'image';
    if (['mp4'].contains(extension)) return 'video';
    if (['pdf'].contains(extension)) return 'pdf';
    return 'unknown';
  }

  Widget _buildFilePreview(File file) {
    final fileType = _getFileType(file);

    if (fileType == 'image') {
      return Image.file(file, height: 150, fit: BoxFit.cover);
    } else if (fileType == 'video') {
      return const Icon(Icons.videocam, size: 100, color: Colors.blueAccent);
    } else if (fileType == 'pdf') {
      return const Icon(Icons.picture_as_pdf,
          size: 100, color: Colors.redAccent);
    } else {
      return const Icon(Icons.file_present, size: 100, color: Colors.grey);
    }
  }

  Widget _buildMediaInput() {
    return Column(
      children: [
        _selectedImage != null
            ? _buildFilePreview(_selectedImage!)
            : const Icon(Icons.file_present,
                size: 100, color: Colors.blueAccent),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            // Open the file picker
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: [
                'jpg',
                'jpeg',
                'png',
                'mp4',
                'pdf'
              ], // Specify allowed file types
            );

            if (result != null) {
              final file = File(result.files.single.path!);
              setState(() {
                _selectedImage = file; // Set the selected file
              });
            }
          },
          child: const Text('Select File'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (_selectedImage != null) {
              try {
                // Determine file type for path and metadata
                final fileType = _getFileType(_selectedImage!);
                final fileName =
                    '${DateTime.now().millisecondsSinceEpoch}.$fileType';
                final storageRef =
                    FirebaseStorage.instance.ref().child('uploads/$fileName');

                // Upload the file to Firebase Storage

                // Get the download URL
                final downloadURL = await storageRef.getDownloadURL();

                // Update content list with the download URL and type
                setState(() {
                  _contentList.add({'type': fileType, 'data': downloadURL});
                  _selectedImage = null;
                  _selectedElement = null;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('File uploaded successfully!')),
                );
              } catch (error) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error uploading file: $error')),
                );
              }
            }
          },
          child: const Text('Upload File'),
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
          onPressed: () async {
            if (_textController.text.isNotEmpty) {
              String newData = _textController.text;
              try {
                await _coursesService.addBlock(widget.lesson,
                    grade: widget.grade,
                    teacher: widget.teacher,
                    materialID: widget.materialID,
                    contentID: widget.contentID,
                    type: 'text',
                    data: newData);

                setState(() {
                  _contentList.add({
                    'type': 'text',
                    'data': _textController.text
                  }); //add locally
                  _contentList.add({'type': 'media', 'data': ''}); //add locally
                  _textController.clear();
                  _selectedElement = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Text block added successfully!')),
                );
              } catch (error) {
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
        final fileType = element['type'];
        final fileData = element['data'];

        if (fileType == 'image') {
          return Image.network(
            fileData,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: progress.expectedTotalBytes != null
                      ? progress.cumulativeBytesLoaded /
                          progress.expectedTotalBytes!
                      : null,
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error);
            },
          );
        } else if (fileType == 'video') {
          return ListTile(
            leading: const Icon(Icons.videocam, color: Colors.blueAccent),
            title: Text('Video: $fileData'),
            onTap: () {
              // Handle video preview or playback
            },
          );
        } else if (fileType == 'pdf') {
          return ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
            title: Text('PDF: $fileData'),
            onTap: () {
              // Handle PDF opening
            },
          );
        } else {
          return ListTile(
            leading: const Icon(Icons.file_present),
            title: Text('Unknown file: $fileData'),
          );
        }
      case 'text':
        return ListTile(
          title: Text(element['data']),
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
