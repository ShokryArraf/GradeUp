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
        const SnackBar(content: Text("שגיאה בטעינת תוכן")),
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
            'הוספת פריט תוכן',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildElementCard(Icons.title, 'כותרת', 'title'),
              _buildElementCard(Icons.image, 'מדיה', 'media'),
              _buildElementCard(Icons.text_fields, 'טקסט', 'text'),
              _buildElementCard(Icons.link, 'קישור', 'link'),
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
            labelText: 'הכנס קישור',
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
                  const SnackBar(content: Text('קישור הוסף בהצלחה')),
                );
                await _fetchBlocks();
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('שגיאה בהוספת קישור')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('להזין קישור בבקשה')),
              );
            }
          },
          child: const Text('הוספת קישור'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _linkController.clear();
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('ביטול'),
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
            labelText: 'הוספת כותרת',
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
                  const SnackBar(content: Text('כותרת הוספה בהצלחה')),
                );
                await _fetchBlocks();
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('שגיאה בהוספת תוכן')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('להזין כותרת בבקשה')),
              );
            }
          },
          child: const Text('הוספת כותרת'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _titleController.clear();
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('ביטול'),
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
          child: const Text('בחר תמונה'),
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
                        const SnackBar(content: Text('תמונה הוספה בהצלחה')),
                      );
                      await _fetchBlocks();
                    } catch (error) {
                      setState(() {
                        _isUploading = false; // Reset on error
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(':שגיאה בהוספת תוכן $error')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('לא נבחרה תמונה')),
                    );
                  }
                },
                child: const Text('הוספת תמונה'),
              ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _selectedImage = null; // Clear the selected image
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('ביטול'),
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
            labelText: 'הזין טקסט',
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
                  const SnackBar(content: Text('טקסט הוסף בהצלחה')),
                );
                await _fetchBlocks();
              } catch (_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('שגיאה בהוספת תוכן')),
                );
              }
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('הזין טקסט בבקשה')),
              );
            }
          },
          child: const Text('הוספת טקסט'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            setState(() {
              _textController.clear();
              _selectedElement = null; // Reset selection
            });
          },
          child: const Text('ביטול'),
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
          const SnackBar(content: Text('קובץ הוסף בהצלחה')),
        );
        await _fetchBlocks();
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('הוספת קובץ נכשלה')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('הוספת תוכן'),
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
                    label: const Text('PDF/Word העלאת קובץ'),
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

  // Widget buildContentCard(Map<String, dynamic> element) {
  //   switch (element['type']) {
  //     case 'title':
  //       return ListTile(
  //         title: Text(
  //           element['data'],
  //           style: const TextStyle(
  //               fontSize: 24,
  //               fontWeight: FontWeight.bold,
  //               decoration: TextDecoration.underline),
  //         ),
  //         trailing: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.edit),
  //               onPressed: () async {
  //                 final newTitle = await _showEditDialog(element['data']);
  //                 if (newTitle != null) {
  //                   await _editBlock(element['id'], newTitle);
  //                 }
  //               },
  //             ),
  //             IconButton(
  //               icon: const Icon(
  //                 Icons.delete,
  //                 color: Colors.red,
  //               ),
  //               onPressed: () async {
  //                 final shouldDelete = await _showDeleteConfirmationDialog();
  //                 if (shouldDelete == true) {
  //                   _deleteBlock(element['id']);
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     case 'image': // Handle image type
  //       return buildImage(element);
  //     case 'text':
  //       return ListTile(
  //         title: Text(element['data']),
  //         trailing: Row(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.edit),
  //               onPressed: () async {
  //                 final newTitle =
  //                     await _showEditDialog(element['data'], isText: true);
  //                 if (newTitle != null) {
  //                   await _editBlock(element['id'], newTitle);
  //                 }
  //               },
  //             ),
  //             IconButton(
  //               icon: const Icon(
  //                 Icons.delete,
  //                 color: Colors.red,
  //               ),
  //               onPressed: () async {
  //                 final shouldDelete = await _showDeleteConfirmationDialog();
  //                 if (shouldDelete == true) {
  //                   _deleteBlock(element['id']);
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );

  //     case 'pdf': // Handle PDF type
  //       return ListTile(
  //         leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
  //         title: Text(element['filename'] ?? 'No filename available'),
  //         trailing: Row(
  //           mainAxisSize: MainAxisSize
  //               .min, // Ensure the trailing icons don't take up excessive space
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.open_in_new),
  //               onPressed: () => openFile(element['data']),
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.delete, color: Colors.red),
  //               onPressed: () async {
  //                 final shouldDelete = await _showDeleteConfirmationDialog();
  //                 if (shouldDelete == true) {
  //                   _deleteBlock(element['id']);
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );

  //     //Handle Word file type
  //     case 'doc':
  //     case 'docx':
  //       return ListTile(
  //         leading: const Icon(Icons.description, color: Colors.blue),
  //         title: Text(element['filename'] ?? 'No filename available'),
  //         trailing: Row(
  //           mainAxisSize: MainAxisSize
  //               .min, // Ensure the trailing icons don't take up excessive space
  //           children: [
  //             IconButton(
  //               icon: const Icon(Icons.open_in_new),
  //               onPressed: () => openFile(element['data']),
  //             ),
  //             IconButton(
  //               icon: const Icon(Icons.delete, color: Colors.red),
  //               onPressed: () async {
  //                 final shouldDelete = await _showDeleteConfirmationDialog();
  //                 if (shouldDelete == true) {
  //                   _deleteBlock(element['id']);
  //                 }
  //               },
  //             ),
  //           ],
  //         ),
  //       );
  //     case 'link': // Handle link type
  //       final url = element['data'];
  //       if (url == null || url.isEmpty) {
  //         return const Text(
  //           'Invalid URL',
  //           style: TextStyle(color: Colors.red),
  //         );
  //       }
  //       return Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           Expanded(
  //             child: GestureDetector(
  //               onTap: () async {
  //                 final uri = Uri.parse(url);
  //                 if (await canLaunchUrl(uri)) {
  //                   await launchUrl(uri, mode: LaunchMode.externalApplication);
  //                 }
  //               },
  //               child: Text(
  //                 url,
  //                 style: const TextStyle(
  //                     color: Colors.blue, decoration: TextDecoration.underline),
  //                 overflow: TextOverflow.ellipsis, // Prevent overflow
  //               ),
  //             ),
  //           ),
  //           IconButton(
  //             icon: const Icon(
  //               Icons.delete,
  //               color: Colors.red,
  //             ),
  //             onPressed: () async {
  //               final shouldDelete = await _showDeleteConfirmationDialog();
  //               if (shouldDelete == true) {
  //                 _deleteBlock(element['id']);
  //               }
  //             },
  //           ),
  //         ],
  //       );
  //     default:
  //       return const SizedBox.shrink();
  //   }
  // }

  bool isHebrew(String text) {
    final hebrewRegex = RegExp(r'[\u0590-\u05FF]'); // Hebrew Unicode range
    return hebrewRegex.hasMatch(text);
  }

  Widget buildContentCard(Map<String, dynamic> element) {
    String? textData = element['data'];
    String? fileName = element['filename'];
    bool useRTL = textData != null && isHebrew(textData);

    Widget buildTextWidget(String text, {TextStyle? style}) {
      return Directionality(
        textDirection: useRTL ? TextDirection.rtl : TextDirection.ltr,
        child: Text(text, style: style),
      );
    }

    switch (element['type']) {
      case 'title':
        return ListTile(
          title: buildTextWidget(
            textData!,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newTitle = await _showEditDialog(textData);
                  if (newTitle != null) {
                    await _editBlock(element['id'], newTitle);
                  }
                },
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
      case 'image':
        return buildImage(element);
      case 'text':
        return ListTile(
          title: buildTextWidget(textData!),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newText = await _showEditDialog(textData, isText: true);
                  if (newText != null) {
                    await _editBlock(element['id'], newText);
                  }
                },
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
      case 'pdf':
        return ListTile(
          leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
          title: buildTextWidget(fileName ?? 'No filename available'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => openFile(textData!),
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
      case 'doc':
      case 'docx':
        return ListTile(
          leading: const Icon(Icons.description, color: Colors.blue),
          title: buildTextWidget(fileName ?? 'No filename available'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.open_in_new),
                onPressed: () => openFile(textData!),
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
      case 'link':
        final url = textData;
        if (url == null || url.isEmpty) {
          return buildTextWidget('Invalid URL',
              style: const TextStyle(color: Colors.red));
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
                  overflow: TextOverflow.ellipsis,
                ),
              ),
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
      default:
        return const SizedBox.shrink();
    }
  }

  Future<bool?> _showDeleteConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('אישור למחיקה'),
          content: const Text('האם אתה בטוח שברצונך למחוק את זה?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('ביטול'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('מחוק'),
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
        const SnackBar(content: Text('התוכן עודכן בהצלחה.')),
      );
      await _fetchBlocks();
    } catch (_) {
      showErrorDialog(context, 'עדכון התוכן נכשל.');
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
        const SnackBar(content: Text('התוכן נמחק בהצלחה.')),
      );
      await _fetchBlocks();
    } catch (_) {
      showErrorDialog(context, 'מחיקת התוכן נכשלה.');
    }
  }

  Future<String?> _showEditDialog(String initialTitle, {bool isText = false}) {
    final controller = TextEditingController(text: initialTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('ערוך תוכן'),
          content: TextField(
            controller: controller,
            maxLines: isText ? 5 : 1, // Larger box for text type
            decoration: const InputDecoration(labelText: 'כותרת חדשה'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ביטול'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: const Text('שמירה'),
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
