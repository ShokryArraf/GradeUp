import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart'; // Import image_picker package
import 'package:grade_up/service/storage_service.dart';
import 'dart:io'; // To handle file paths
import 'package:grade_up/service/teacher_service.dart';
import 'package:grade_up/utilities/build_content_card.dart';
import 'package:image_picker/image_picker.dart';

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
  final StorageService _storageService = StorageService();
  final _coursesService = TeacherService();
  String? _selectedElement;
  List<Map<String, dynamic>> _contentList = [];
  bool _isLoading = true;
  bool _isUploading = false; // Track upload status

  File? _selectedImage; // Holds the selected image file
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchBlocks(); // Fetch content blocks when the page loads
  }

  Future<void> _fetchBlocks() async {
    try {
      final blocks = await _coursesService.fetchBlocks(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: widget.materialID,
        contentID: widget.contentID,
        orderBy: 'timestamp',
      );
      setState(() {
        _contentList = blocks;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error fetching blocks")),
      );
    }
  }

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
              _buildElementCard(Icons.link, 'Link', 'link'),
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
      case 'link':
        return _buildLinkInput();
      default:
        return const SizedBox.shrink();
    }
  }

  final TextEditingController _linkController = TextEditingController();

  Widget _buildLinkInput() {
    return Column(
      children: [
        TextField(
          controller: _linkController,
          decoration: const InputDecoration(
            labelText: 'Enter Link URL',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            if (_linkController.text.isNotEmpty) {
              String newLink = _linkController.text;
              try {
                await _coursesService.addBlock(
                  lessonName: widget.lesson,
                  grade: widget.grade,
                  teacher: widget.teacher,
                  materialID: widget.materialID,
                  contentID: widget.contentID,
                  type: 'link',
                  data: newLink,
                  timestamp: DateTime.now().toIso8601String(),
                );

                setState(() {
                  _contentList.add({'type': 'link', 'data': newLink});
                  _linkController.clear();
                  _selectedElement = null;
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Link added successfully!')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error adding link')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter a link URL.')),
              );
            }
          },
          child: const Text('Add Link'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _linkController.clear();
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('Cancel'),
        ),
      ],
    );
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
                  lessonName: widget.lesson,
                  grade: widget.grade,
                  teacher: widget.teacher,
                  materialID: widget.materialID,
                  contentID: widget.contentID,
                  type: 'title',
                  data: newData,
                  timestamp: DateTime.now().toIso8601String(),
                );

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
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error adding content')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Please enter the content title to add.')),
              );
            }
          },
          child: const Text('Add Title'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _titleController.clear();
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  String _getFileType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png'].contains(extension)) return 'image';
    return 'unknown'; // Only consider image files
  }

  Widget _buildFilePreview(File file) {
    final fileType = _getFileType(file);

    if (fileType == 'image') {
      return Image.file(
        file,
        height: 150,
        fit: BoxFit.cover,
      );
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
            final pickedImage = await ImagePicker().pickImage(
              source: ImageSource.gallery,
            );
            if (pickedImage != null) {
              setState(() {
                _selectedImage = File(pickedImage.path);
              });
            }
          },
          child: const Text('Pick Image'),
        ),
        const SizedBox(height: 10),
        _isUploading
            ? const CircularProgressIndicator() // Show progress indicator during upload
            : ElevatedButton(
                onPressed: () async {
                  if (_selectedImage != null) {
                    setState(() {
                      _isUploading = true; // Start uploading
                    });

                    try {
                      final String? downloadURL =
                          await _storageService.uploadImage(_selectedImage!);

                      // Save the image block to Firestore
                      await _coursesService.addBlock(
                        lessonName: widget.lesson,
                        grade: widget.grade,
                        teacher: widget.teacher,
                        materialID: widget.materialID,
                        contentID: widget.contentID,
                        type: 'image',
                        data: downloadURL!, // Save the image URL
                        timestamp: DateTime.now().toIso8601String(),
                      );

                      setState(() {
                        _contentList
                            .add({'type': 'image', 'data': downloadURL});
                        _selectedImage = null;
                        _selectedElement = null;
                        _isUploading = false; // Finish uploading
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Image uploaded successfully!')),
                      );
                    } catch (error) {
                      setState(() {
                        _isUploading = false; // Reset on error
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Error uploading image: $error')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No image selected')),
                    );
                  }
                },
                child: const Text('Upload Image'),
              ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedImage = null; // Clear the selected image
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('Cancel'),
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
                await _coursesService.addBlock(
                  lessonName: widget.lesson,
                  grade: widget.grade,
                  teacher: widget.teacher,
                  materialID: widget.materialID,
                  contentID: widget.contentID,
                  type: 'text',
                  data: newData,
                  timestamp: DateTime.now().toIso8601String(),
                );

                setState(() {
                  _contentList
                      .add({'type': 'text', 'data': _textController.text});
                  _textController.clear();
                  _selectedElement = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text('Text block added successfully!')),
                );
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error adding content')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please enter the text to add.')),
              );
            }
          },
          child: const Text('Add Text'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _textController.clear();
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('Cancel'),
        ),
      ],
    );
  }

  Future<void> _uploadFile() async {
    try {
      // Pick file
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result == null || result.files.isEmpty) return;

      final filePath = result.files.first.path;
      final fileName = result.files.first.name;

      if (filePath != null) {
        final file = File(filePath);

        // Extract file type dynamically from the extension
        final fileType = fileName.split('.').last.toLowerCase();

        setState(() {
          _isLoading = true;
        });

        // Upload file via FirebaseService
        final downloadUrl = await _storageService.uploadFile(file, fileName);

        if (downloadUrl != null) {
          await _coursesService.addBlock(
            lessonName: widget.lesson,
            grade: widget.grade,
            teacher: widget.teacher,
            materialID: widget.materialID,
            contentID: widget.contentID,
            type: fileType,
            data: downloadUrl,
            timestamp: DateTime.now().toIso8601String(),
            filename: fileName,
          );
          setState(() {
            _contentList.add({
              'data': downloadUrl,
              'filename': fileName,
              'type': fileType, // Dynamically set file type
            });
          });
        }

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File uploaded successfully')),
        );
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File upload failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Add Content'),
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedElement == null
                        ? _buildElementSelectionBox()
                        : _buildElementInputBox(),
                  ),
                  ElevatedButton.icon(
                    onPressed: _uploadFile,
                    icon: const Icon(Icons.upload_file),
                    label: const Text('Upload PDF/Word File'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C6FF),
                    ),
                  ),
                  const Divider(),
                  ..._contentList.map((element) => buildContentCard(element)),
                ],
              ),
            ),
    );
  }
}
