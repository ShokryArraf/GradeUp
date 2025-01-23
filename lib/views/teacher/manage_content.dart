import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart'; // Import image_picker package
import 'package:grade_up/service/storage_service.dart';
import 'dart:io'; // To handle file paths
import 'package:grade_up/service/teacher_service.dart';
import 'package:grade_up/utilities/open_file.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

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
                await _fetchBlocks();
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
                await _fetchBlocks();
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
                      await _fetchBlocks();
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
                await _fetchBlocks();
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
        await _fetchBlocks();
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

  Widget buildContentCard(Map<String, dynamic> element) {
    switch (element['type']) {
      case 'title':
        return ListTile(
          title: Text(
            element['data'],
            style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newTitle = await _showEditDialog(element['data']);
                  if (newTitle != null) {
                    await _editBlock(element['id'], newTitle);
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete == true) {
                    _deleteBlock(element['id']);
                  }
                },
              ),
            ],
          ),
        );
      case 'image': // Handle image type
        return buildImage(element);
      case 'text':
        return ListTile(
          title: Text(element['data']),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newTitle =
                      await _showEditDialog(element['data'], isText: true);
                  if (newTitle != null) {
                    await _editBlock(element['id'], newTitle);
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  color: Colors.red,
                ),
                onPressed: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete == true) {
                    _deleteBlock(element['id']);
                  }
                },
              ),
            ],
          ),
        );

      case 'pdf': // Handle PDF type
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: Text(element['filename'] ?? 'No filename available'),
          trailing: Row(
            mainAxisSize: MainAxisSize
                .min, // Ensure the trailing icons don't take up excessive space
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => openFile(element['data']),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete == true) {
                    _deleteBlock(element['id']);
                  }
                },
              ),
            ],
          ),
        );

      //Handle Word file type
      case 'doc':
      case 'docx':
        return ListTile(
          leading: const Icon(Icons.description, color: Colors.blue),
          title: Text(element['filename'] ?? 'No filename available'),
          trailing: Row(
            mainAxisSize: MainAxisSize
                .min, // Ensure the trailing icons don't take up excessive space
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => openFile(element['data']),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  final shouldDelete = await _showDeleteConfirmationDialog();
                  if (shouldDelete == true) {
                    _deleteBlock(element['id']);
                  }
                },
              ),
            ],
          ),
        );
      case 'link': // Handle link type
        final url = element['data'];
        if (url == null || url.isEmpty) {
          return const Text(
            'Invalid URL',
            style: TextStyle(color: Colors.red),
          );
        }
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final uri = Uri.parse(url);
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                  }
                },
                child: Text(
                  url,
                  style: const TextStyle(
                      color: Colors.blue, decoration: TextDecoration.underline),
                  overflow: TextOverflow.ellipsis, // Prevent overflow
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () async {
                final shouldDelete = await _showDeleteConfirmationDialog();
                if (shouldDelete == true) {
                  _deleteBlock(element['id']);
                }
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const Text('Are you sure you want to delete this?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editBlock(String id, String updatedBlock) async {
    try {
      await _coursesService.editBlock(
          lessonName: widget.lesson,
          grade: widget.grade,
          teacher: widget.teacher,
          materialID: widget.materialID,
          contentID: widget.contentID,
          newData: updatedBlock,
          blockID: id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content updated successfully.')),
      );
      await _fetchBlocks();
    } catch (_) {
      showErrorDialog(context, 'Failed to update the content.');
    }
  }

  Future<void> _deleteBlock(String id) async {
    try {
      await _coursesService.deleteBlock(
          lessonName: widget.lesson,
          grade: widget.grade,
          teacher: widget.teacher,
          materialID: widget.materialID,
          contentID: widget.contentID,
          blockID: id);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content deleted successfully.')),
      );
      await _fetchBlocks();
    } catch (_) {
      showErrorDialog(context, 'Failed to delete the content.');
    }
  }

  Future<String?> _showEditDialog(String initialTitle, {bool isText = false}) {
    final controller = TextEditingController(text: initialTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Content'),
          content: TextField(
            controller: controller,
            maxLines: isText ? 5 : 1, // Larger box for text type
            decoration: const InputDecoration(labelText: 'New Title'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget buildImage(Map<String, dynamic> element) {
    String url = element['data'];
    if (kIsWeb) {
      // For web: Use Image.network with loading and error handling
      return Image.network(
        url,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.error, color: Colors.red, size: 100);
        },
        fit: BoxFit.cover,
      );
    } else {
// For mobile: Use the same approach
      return Stack(
        alignment: Alignment.topRight,
        children: [
          Image.network(
            url,
            loadingBuilder: (context, child, progress) {
              if (progress == null) return child;
              return const Center(child: CircularProgressIndicator());
            },
            errorBuilder: (context, error, stackTrace) {
              return const Icon(Icons.error, color: Colors.red, size: 100);
            },
            fit: BoxFit.cover,
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final shouldDelete = await _showDeleteConfirmationDialog();
              if (shouldDelete == true) {
                _deleteBlock(element['id']);
              }
            },
          ),
        ],
      );
    }
  }
}
