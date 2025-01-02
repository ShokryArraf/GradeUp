import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/service/storage_service.dart';
import 'package:grade_up/utilities/format_date.dart';
import 'package:grade_up/utilities/open_file.dart';
import 'package:grade_up/views/student/submission_details_view.dart';

class AssignmentDetailView extends StatefulWidget {
  final Map<String, dynamic> assignment;
  final Student student;

  const AssignmentDetailView({
    super.key,
    required this.assignment,
    required this.student,
  });

  @override
  State<AssignmentDetailView> createState() => _AssignmentDetailViewState();
}

class _AssignmentDetailViewState extends State<AssignmentDetailView> {
  final Map<String, TextEditingController> _answersControllers = {};
  final TextEditingController _additionalInputController =
      TextEditingController();
  final StorageService _storageService = StorageService();

  PlatformFile? _selectedFile;
  bool _isSubmitted = false;
  bool _isLoading = false;

  DateTime? _dueDate;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    final questions = widget.assignment['questions'] as List<dynamic>? ?? [];
    for (var i = 0; i < questions.length; i++) {
      _answersControllers[i.toString()] = TextEditingController();
    }
    _initializeAssignment();
  }

  Future<void> _initializeAssignment() async {
    final firestore = FirebaseFirestore.instance;
    final school = widget.student.school;
    final grade = widget.student.grade.toString();
    final studentId = widget.student.studentId;
    final assignmentId = widget.assignment['id'];

    final dueDateString = widget.assignment['dueDate'];
    _dueDate = DateTime.tryParse(dueDateString);

    try {
      final doc = await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(studentId)
          .collection('assignmentsToDo')
          .doc(assignmentId)
          .get();

      if (doc.exists) {
        final data = doc.data();
        setState(() {
          _isSubmitted = data?['status'] == 'submitted';
          _statusMessage =
              _isSubmitted ? 'You have already submitted this assignment.' : '';
        });
      }

      if (!doc.exists &&
          _dueDate != null &&
          DateTime.now().isAfter(_dueDate!)) {
        await firestore
            .collection('schools')
            .doc(school)
            .collection('grades')
            .doc(grade)
            .collection('students')
            .doc(studentId)
            .collection('assignmentsToDo')
            .doc(assignmentId)
            .set({
          'status': 'missed',
          'submissionDate': null,
          'title': widget.assignment['title'],
          'score': 0,
          'dueDate': dueDateString,
        });
        setState(() {
          _statusMessage = 'Assignment missed. Score: 0';
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to fetch assignment status!')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var controller in _answersControllers.values) {
      controller.dispose();
    }
    _additionalInputController
        .dispose(); // Added: Dispose the additional input controller
    super.dispose();
  }

  Future<void> _submitAnswers() async {
    if (_isLoading) return; // Prevent duplicate submissions

    setState(() {
      _isLoading = true;
    });

    final answers = _answersControllers.map(
      (key, controller) => MapEntry(key, controller.text.trim()),
    );
    final additionalInput = _additionalInputController.text.trim().isEmpty
        ? null
        : _additionalInputController.text.trim();

    if (answers.values.any((answer) => answer.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('All questions must be answered!')),
      );
      return;
    }

    final firestore = FirebaseFirestore.instance;
    final school = widget.student.school;
    final grade = widget.student.grade.toString();
    final studentId = widget.student.studentId;
    final assignmentId = widget.assignment['id'];
    final title = widget.assignment['title'] ?? 'No Title';
    final dueDateStr = widget.assignment['dueDate'];
    final questions = widget.assignment['questions'] ?? 'No Questions';

    final dueDate = DateTime.tryParse(dueDateStr);
    if (dueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid due date!')),
      );
      return;
    }

    final currentTime = DateTime.now();

    try {
      if (currentTime.isAfter(dueDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('You cannot submit after the due date!')),
        );
        return; // Prevent submission after due date.
      }
      final uploadedFileUrl = await _uploadFile();

      await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(studentId)
          .collection('assignmentsToDo')
          .doc(assignmentId)
          .set({
        'status': 'submitted',
        'submissionDate': FieldValue.serverTimestamp(),
        'title': title,
        'score': null,
        'dueDate': dueDateStr,
        'answers': answers,
        'questions': questions,
        'additionalInput': additionalInput,
        'uploadedFileUrl': uploadedFileUrl,
      }, SetOptions(merge: true));

      setState(() {
        _isSubmitted = true; // Disable resubmission after first submission.
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Answers submitted successfully!')),
      );

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to submit answers!')),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: [
          'pdf',
          'doc',
          'docx'
        ], // Limit to specific file types
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to pick file!')),
      );
    }
  }

  Future<String?> _uploadFile() async {
    // Early return if no file is selected
    if (_selectedFile == null) {
      return null;
    }

    final filePath = _selectedFile!.path;
    final fileName = _selectedFile!.name;

    if (filePath == null) {
      return null; // In case path is somehow null
    }

    final file = File(filePath);

    // Check for valid file types (e.g., pdf, docx)
    final fileExtension = fileName.split('.').last.toLowerCase();
    final allowedExtensions = ['pdf', 'docx', 'doc'];

    if (!allowedExtensions.contains(fileExtension)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unsupported file type: $fileExtension')),
      );
      return null; // Return null if the file type is unsupported
    }

    try {
      // Upload file using the existing storage service method
      final uploadedUrl = await _storageService.uploadFile(file, fileName);
      return uploadedUrl; // Return the file URL or null if upload fails
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('File upload failed')),
      );
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final assignment = widget.assignment;
    return Scaffold(
      appBar: AppBar(
          title: const Text('Assignment'),
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
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  color: Colors.teal.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          assignment['title'] ?? 'No Title',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _statusMessage,
                          style: TextStyle(
                            fontSize: 18,
                            color: _isSubmitted ? Colors.green : Colors.red,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Due: ${formatDueDate(_dueDate)}',
                              style: const TextStyle(fontSize: 18),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(height: 20, color: Colors.grey),
                const SizedBox(height: 20),
                Text(
                  'Subject: ${assignment['subject'] ?? 'Unknown'}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow
                      .ellipsis, // Adds ellipsis if the text overflows
                ),
                const SizedBox(height: 20),
                const Divider(height: 20, color: Colors.grey),
                Text(
                  assignment['description'] ?? 'No description provided.',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (assignment['additionalNotes'] != null &&
                    assignment['additionalNotes']!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  const Divider(height: 20, color: Colors.grey),
                  const Text(
                    'Additional Notes:',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    assignment['additionalNotes']!,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
                if (assignment['uploadedFileUrl'] != null &&
                    assignment['uploadedFileUrl']!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Handle file download or open
                      openFile(widget.assignment['uploadedFileUrl']!);
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text('Download Attached File',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                    ),
                  ),
                ],
                const SizedBox(height: 10),
                const Divider(height: 20, color: Colors.grey),
                if (!_isSubmitted ||
                    (_isSubmitted && _dueDate == null) ||
                    DateTime.now().isBefore(_dueDate!))
                  ...((assignment['questions'] as List<dynamic>? ?? [])
                      .asMap()
                      .entries
                      .map((entry) {
                    final index = entry.key;
                    final question =
                        entry.value as String? ?? 'No question provided';
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${index + 1}. $question',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 5),
                        TextField(
                          controller: _answersControllers[index.toString()],
                          decoration: InputDecoration(
                            labelText: 'Your Answer',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
                    );
                  }).toList()),
                if (!_isSubmitted || DateTime.now().isBefore(_dueDate!)) ...[
                  const Divider(height: 20, color: Colors.grey),
                  TextField(
                    controller: _additionalInputController,
                    maxLines: 10,
                    decoration: InputDecoration(
                      labelText: 'Additional Notes',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const Divider(height: 20, color: Colors.grey),
                  ElevatedButton.icon(
                    onPressed: _pickFile, // Pick file function
                    icon: const Icon(Icons.attach_file),
                    label: const Text('Attach Word/PDF File'),
                  ),
                  if (_selectedFile != null)
                    Row(
                      children: [
                        Text('Selected File: ${_selectedFile!.name}'),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            setState(() {
                              _selectedFile = null; // Clear selected file
                            });
                          },
                        ),
                      ],
                    ),
                ],
                if (!_isSubmitted || DateTime.now().isBefore(_dueDate!)) ...[
                  const Divider(height: 20, color: Colors.grey),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading
                          ? null
                          : _submitAnswers, // Disable when loading
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade50,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      child: const Text('Submit Answers'),
                    ),
                  ),
                ],
                if (_isSubmitted) ...[
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SubmissionDetailsPage(
                            schoolId: widget.student.school,
                            gradeId: widget.student.grade.toString(),
                            studentId: widget.student.studentId,
                            assignmentId: widget.assignment['id'],
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      textStyle: const TextStyle(fontSize: 16),
                    ),
                    child: const Text(' View Your Submission/Score & Review '),
                  )
                ],
              ],
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black54, // Semi-transparent background
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }
}
