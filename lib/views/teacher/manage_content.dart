// import 'package:firebase_core/firebase_core.dart';
// import 'package:flutter/material.dart';
// import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for file uploads
// import 'package:grade_up/models/teacher.dart'; // Import image_picker package
// import 'dart:io'; // To handle file paths
// import 'package:grade_up/service/teacher_courses_service.dart';
// import 'package:image_picker/image_picker.dart';

// class ManageContent extends StatefulWidget {
//   final Teacher teacher;
//   final int grade;
//   final String lesson, materialID, contentID;

//   const ManageContent(
//       {super.key,
//       required this.teacher,
//       required this.grade,
//       required this.lesson,
//       required this.materialID,
//       required this.contentID});

//   @override
//   State<ManageContent> createState() => _ManageContentState();
// }

// class _ManageContentState extends State<ManageContent> {
//   final _coursesService = TeacherCoursesService();
//   String? _selectedElement;
//   List<Map<String, dynamic>> _contentList = [];
//   bool _isLoading = true;

//   File? _selectedImage; // Holds the selected image file
//   // Controllers for text inputs
//   final TextEditingController _titleController = TextEditingController();
//   final TextEditingController _textController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _fetchBlocks(); // Fetch content blocks when the page loads
//   }

//   // Method to fetch blocks from the database
//   Future<void> _fetchBlocks() async {
//     try {
//       final blocks = await _coursesService.fetchBlocks(
//         lessonName: widget.lesson,
//         grade: widget.grade,
//         teacher: widget.teacher,
//         materialID: widget.materialID,
//         contentID: widget.contentID,
//         orderBy: 'timestamp', // Ensure blocks are ordered by timestamp
//       );
//       setState(() {
//         _contentList = blocks; // Update the content list with fetched blocks
//         _isLoading = false; // Stop loading
//       });
//     } catch (_) {
//       setState(() {
//         _isLoading = false; // Stop loading even if there is an error
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Error fetching blocks")),
//       );
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Content'),
//         centerTitle: true,
//         backgroundColor: Colors.blueAccent,
//       ),
//       body: _isLoading
//           ? const Center(child: CircularProgressIndicator())
//           : SingleChildScrollView(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Add Element Section
//                   Padding(
//                     padding: const EdgeInsets.all(16.0),
//                     child: _selectedElement == null
//                         ? _buildElementSelectionBox()
//                         : _buildElementInputBox(),
//                   ),
//                   const Divider(),
//                   // Display existing content
//                   ..._contentList.map((element) => _buildContentCard(element)),
//                 ],
//               ),
//             ),
//     );
//   }

//   // Element Selection UI
//   Widget _buildElementSelectionBox() {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[200],
//         borderRadius: BorderRadius.circular(10),
//       ),
//       child: Column(
//         children: [
//           const Text(
//             'Add New Content Element',
//             style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//           ),
//           const SizedBox(height: 10),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceAround,
//             children: [
//               _buildElementCard(Icons.title, 'Title', 'title'),
//               _buildElementCard(Icons.image, 'Media', 'media'),
//               _buildElementCard(Icons.text_fields, 'Text', 'text'),
//             ],
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildElementCard(IconData icon, String label, String type) {
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _selectedElement = type;
//         });
//       },
//       child: Column(
//         children: [
//           Icon(icon, size: 40, color: Colors.blueAccent),
//           const SizedBox(height: 8),
//           Text(label),
//         ],
//       ),
//     );
//   }

//   Widget _buildElementInputBox() {
//     switch (_selectedElement) {
//       case 'title':
//         return _buildTitleInput();
//       case 'media':
//         return _buildMediaInput();
//       case 'text':
//         return _buildTextInput();
//       default:
//         return const SizedBox.shrink();
//     }
//   }

//   Widget _buildTitleInput() {
//     return Column(
//       children: [
//         TextField(
//           controller: _titleController,
//           decoration: const InputDecoration(
//             labelText: 'Enter Title',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: () async {
//             if (_titleController.text.isNotEmpty) {
//               String newData = _titleController.text;
//               try {
//                 await _coursesService.addBlock(
//                   lessonName: widget.lesson,
//                   grade: widget.grade,
//                   teacher: widget.teacher,
//                   materialID: widget.materialID,
//                   contentID: widget.contentID,
//                   type: 'title',
//                   data: newData,
//                   timestamp: DateTime.now().toIso8601String(), // Add timestamp
//                 );

//                 setState(() {
//                   _contentList
//                       .add({'type': 'title', 'data': _titleController.text});
//                   _titleController.clear();
//                   _selectedElement = null;
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Title block added successfully!')),
//                 );
//               } catch (error) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error adding content: $error')),
//                 );
//               }
//             }
//           },
//           child: const Text('Add Title'),
//         ),
//       ],
//     );
//   }

//   String _getFileType(File file) {
//     final extension = file.path.split('.').last.toLowerCase();
//     if (['jpg', 'jpeg', 'png'].contains(extension)) return 'image';
//     if (['mp4'].contains(extension)) return 'video';
//     if (['pdf'].contains(extension)) return 'pdf';
//     return 'unknown';
//   }

//   Widget _buildFilePreview(File file) {
//     final fileType = _getFileType(file);

//     if (fileType == 'image') {
//       return Image.file(file, height: 150, fit: BoxFit.cover);
//     } else if (fileType == 'video') {
//       return const Icon(Icons.videocam, size: 100, color: Colors.blueAccent);
//     } else if (fileType == 'pdf') {
//       return const Icon(Icons.picture_as_pdf,
//           size: 100, color: Colors.redAccent);
//     } else {
//       return const Icon(Icons.file_present, size: 100, color: Colors.grey);
//     }
//   }

//   Widget _buildMediaInput() {
//     return Column(
//       children: [
//         _selectedImage != null
//             ? _buildFilePreview(_selectedImage!)
//             : const Icon(Icons.file_present,
//                 size: 100, color: Colors.blueAccent),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: () async {
//             // Pick an image from the camera or gallery
//             final pickedImage = await ImagePicker().pickImage(
//               source: ImageSource.gallery, // Or ImageSource.camera
//             );
//             if (pickedImage != null) {
//               setState(() {
//                 _selectedImage =
//                     File(pickedImage.path); // Update the selected image
//               });
//             }
//           },
//           child: const Text('Pick Image'),
//         ),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: () async {
//             if (_selectedImage != null) {
//               try {
//                 // Create a unique file name based on timestamp
//                 final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';

//                 // Initialize FirebaseStorage instance with the custom bucket
//                 FirebaseStorage storage = FirebaseStorage.instanceFor(
//                   app: Firebase.app(), // Use the default Firebase app
//                   bucket:
//                       'gs://grade-up-project1.firebasestorage.app', // Custom bucket URL
//                 );

//                 // Reference for the file in Firebase Storage
//                 final storageRef = storage.ref().child('uploads/$fileName');

//                 // Upload the file to Firebase Storage
//                 final uploadTask = storageRef.putFile(_selectedImage!);

//                 // Await the completion of the upload
//                 await uploadTask;

//                 // Get the download URL of the uploaded file
//                 final downloadURL = await storageRef.getDownloadURL();

//                 // Add the uploaded image URL to the content list
//                 setState(() {
//                   _contentList.add({'type': 'image', 'data': downloadURL});
//                   _selectedImage = null; // Clear the selected image
//                   _selectedElement = null;
//                 });

//                 // Show success message
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Image uploaded successfully!')),
//                 );
//               } catch (error) {
//                 // Handle errors during upload
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error uploading image: $error')),
//                 );
//               }
//             } else {
//               ScaffoldMessenger.of(context).showSnackBar(
//                 const SnackBar(content: Text('No image selected')),
//               );
//             }
//           },
//           child: const Text('Upload Image'),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextInput() {
//     return Column(
//       children: [
//         TextField(
//           controller: _textController,
//           maxLines: 4,
//           decoration: const InputDecoration(
//             labelText: 'Enter Text',
//             border: OutlineInputBorder(),
//           ),
//         ),
//         const SizedBox(height: 10),
//         ElevatedButton(
//           onPressed: () async {
//             if (_textController.text.isNotEmpty) {
//               String newData = _textController.text;
//               try {
//                 await _coursesService.addBlock(
//                   lessonName: widget.lesson,
//                   grade: widget.grade,
//                   teacher: widget.teacher,
//                   materialID: widget.materialID,
//                   contentID: widget.contentID,
//                   type: 'text',
//                   data: newData,
//                   timestamp: DateTime.now().toIso8601String(), // Add timestamp
//                 );

//                 setState(() {
//                   _contentList.add({
//                     'type': 'text',
//                     'data': _textController.text
//                   }); //add locally
//                   _contentList.add({'type': 'media', 'data': ''}); //add locally
//                   _textController.clear();
//                   _selectedElement = null;
//                 });
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(
//                       content: Text('Text block added successfully!')),
//                 );
//               } catch (error) {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Error adding content: $error')),
//                 );
//               }
//             }
//           },
//           child: const Text('Add Text'),
//         ),
//       ],
//     );
//   }

//   // Render each content card dynamically
//   Widget _buildContentCard(Map<String, dynamic> element) {
//     switch (element['type']) {
//       case 'title':
//         return ListTile(
//           title: Text(
//             element['data'],
//             style: const TextStyle(
//               fontSize: 24,
//               fontWeight: FontWeight.bold,
//               decoration: TextDecoration.underline,
//             ),
//           ),
//         );
//       case 'media':
//         final fileType = element['type'];
//         final fileData = element['data'];

//         if (fileType == 'image') {
//           return Image.network(
//             fileData,
//             fit: BoxFit.cover,
//             loadingBuilder: (context, child, progress) {
//               if (progress == null) return child;
//               return Center(
//                 child: CircularProgressIndicator(
//                   value: progress.expectedTotalBytes != null
//                       ? progress.cumulativeBytesLoaded /
//                           progress.expectedTotalBytes!
//                       : null,
//                 ),
//               );
//             },
//             errorBuilder: (context, error, stackTrace) {
//               return const Icon(Icons.error);
//             },
//           );
//         } else if (fileType == 'video') {
//           return ListTile(
//             leading: const Icon(Icons.videocam, color: Colors.blueAccent),
//             title: Text('Video: $fileData'),
//             onTap: () {
//               // Handle video preview or playback
//             },
//           );
//         } else if (fileType == 'pdf') {
//           return ListTile(
//             leading: const Icon(Icons.picture_as_pdf, color: Colors.redAccent),
//             title: Text('PDF: $fileData'),
//             onTap: () {
//               // Handle PDF opening
//             },
//           );
//         } else {
//           return ListTile(
//             leading: const Icon(Icons.file_present),
//             title: Text('Unknown file: $fileData'),
//           );
//         }
//       case 'text':
//         return ListTile(
//           title: Text(element['data']),
//         );
//       default:
//         return const SizedBox.shrink();
//     }
//   }
// }

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Firebase Storage for file uploads
import 'package:grade_up/models/teacher.dart'; // Import image_picker package
import 'dart:io'; // To handle file paths
import 'package:grade_up/service/teacher_courses_service.dart';
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
  final _coursesService = TeacherCoursesService();
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
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: _selectedElement == null
                        ? _buildElementSelectionBox()
                        : _buildElementInputBox(),
                  ),
                  const Divider(),
                  ..._contentList.map((element) => _buildContentCard(element)),
                ],
              ),
            ),
    );
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
    return 'unknown'; // Only consider image files
  }

  Widget _buildFilePreview(File file) {
    final fileType = _getFileType(file);

    if (fileType == 'image') {
      return Image.file(file, height: 150, fit: BoxFit.cover);
    } else {
      return const Icon(Icons.file_present, size: 100, color: Colors.grey);
    }
  }

  // Widget _buildMediaInput() {
  //   return Column(
  //     children: [
  //       _selectedImage != null
  //           ? _buildFilePreview(_selectedImage!)
  //           : const Icon(Icons.file_present,
  //               size: 100, color: Colors.blueAccent),
  //       const SizedBox(height: 10),
  //       ElevatedButton(
  //         onPressed: () async {
  //           final pickedImage = await ImagePicker().pickImage(
  //             source: ImageSource.gallery,
  //           );
  //           if (pickedImage != null) {
  //             setState(() {
  //               _selectedImage = File(pickedImage.path);
  //             });
  //           }
  //         },
  //         child: const Text('Pick Image'),
  //       ),
  //       const SizedBox(height: 10),
  //       _isUploading
  //           ? const CircularProgressIndicator() // Show progress indicator during upload
  //           : ElevatedButton(
  //               onPressed: () async {
  //                 if (_selectedImage != null) {
  //                   setState(() {
  //                     _isUploading = true; // Start uploading
  //                   });

  //                   try {
  //                     final fileName =
  //                         '${DateTime.now().millisecondsSinceEpoch}.jpg';
  //                     FirebaseStorage storage = FirebaseStorage.instanceFor(
  //                       app: Firebase.app(),
  //                       bucket: 'gs://grade-up-project1.firebasestorage.app',
  //                     );
  //                     final storageRef =
  //                         storage.ref().child('uploads/$fileName');
  //                     final uploadTask = storageRef.putFile(_selectedImage!);
  //                     await uploadTask;
  //                     final downloadURL = await storageRef.getDownloadURL();

  //                     setState(() {
  //                       _contentList
  //                           .add({'type': 'image', 'data': downloadURL});
  //                       _selectedImage = null;
  //                       _selectedElement = null;
  //                       _isUploading = false; // Finish uploading
  //                     });

  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                           content: Text('Image uploaded successfully!')),
  //                     );
  //                   } catch (error) {
  //                     setState(() {
  //                       _isUploading = false; // Reset on error
  //                     });
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       SnackBar(
  //                           content: Text('Error uploading image: $error')),
  //                     );
  //                   }
  //                 } else {
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(content: Text('No image selected')),
  //                   );
  //                 }
  //               },
  //               child: const Text('Upload Image'),
  //             ),
  //     ],
  //   );
  // }

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
                      final fileName =
                          '${DateTime.now().millisecondsSinceEpoch}.jpg';
                      FirebaseStorage storage = FirebaseStorage.instanceFor(
                        app: Firebase.app(),
                        bucket: 'gs://grade-up-project1.firebasestorage.app',
                      );
                      final storageRef =
                          storage.ref().child('uploads/$fileName');
                      final uploadTask = storageRef.putFile(_selectedImage!);
                      await uploadTask;
                      final downloadURL = await storageRef.getDownloadURL();

                      // Save the image block to Firestore
                      await _coursesService.addBlock(
                        lessonName: widget.lesson,
                        grade: widget.grade,
                        teacher: widget.teacher,
                        materialID: widget.materialID,
                        contentID: widget.contentID,
                        type: 'image',
                        data: downloadURL, // Save the image URL
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

  Widget _buildContentCard(Map<String, dynamic> element) {
    switch (element['type']) {
      case 'title':
        return ListTile(
          title: Text(element['data'],
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.underline)),
        );
      case 'image':
        return ListTile(
          title: Image.network(element['data']),
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
