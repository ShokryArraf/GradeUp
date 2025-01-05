import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/assignment_service.dart';
import 'package:grade_up/service/storage_service.dart';

class CreateAssignmentView extends StatefulWidget {
  final Teacher teacher;

  const CreateAssignmentView({super.key, required this.teacher});

  @override
  CreateAssignmentViewState createState() => CreateAssignmentViewState();
}

class CreateAssignmentViewState extends State<CreateAssignmentView> {
  final _formKey = GlobalKey<FormState>();
  final _assignmentService = AssignmentService();
  final StorageService _storageService = StorageService();

  String? _selectedLesson;
  int? _selectedGrade;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();
  final TextEditingController _linkController = TextEditingController();
  final TextEditingController _selectedSubject = TextEditingController();
  final TextEditingController _additionalInputController =
      TextEditingController();
  PlatformFile? _selectedFile;
  DateTime? _dueDate;
  bool _isLoading = false;

  // Retrieve lessons as a list of maps with their associated grades
  List<Map<String, dynamic>> get _lessons => widget.teacher.lessonGradeMap.keys
      .map((lesson) => {
            'id': lesson,
            'title': lesson,
            'grades': widget.teacher.lessonGradeMap[lesson], // Add grades info
          })
      .toList();

  // Dynamically fetch grades for the selected lesson
  List<int> get _grades => _selectedLesson != null
      ? (widget.teacher.lessonGradeMap[_selectedLesson!] ?? [])
      : [];

  Future<void> _createAndAssignToStudents() async {
    if (_formKey.currentState!.validate() &&
        _selectedLesson != null &&
        _selectedGrade != null &&
        _dueDate != null) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });
      try {
        final uploadedFileUrl = await _uploadFile();

        // Create the assignment
        DocumentReference assignmentRef =
            await _assignmentService.createAssignment(
          _selectedLesson!,
          title: _titleController.text,
          description: _descriptionController.text,
          dueDate: _dueDate!,
          questions: _questionsController.text
              .split('\n')
              .map((question) => question.trim())
              .where((question) => question.isNotEmpty)
              .toList(),
          grade: _selectedGrade!,
          teacherName: widget.teacher.name,
          teacher: widget.teacher,
          subject: _selectedSubject.text,
          link: _linkController.text.isNotEmpty ? _linkController.text : null,
          additionalNotes: _additionalInputController.text.isNotEmpty
              ? _additionalInputController.text
              : null,
          uploadedFileUrl: uploadedFileUrl,
        );

        // Assign to all enrolled students
        await _assignmentService.assignToEnrolledStudents(
          _selectedLesson!,
          assignmentRef.id,
          _selectedGrade.toString(),
          widget.teacher,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Assignment created and assigned to students!')),
        );
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error occurred while creating assignment.'),
          ),
        );
      } finally {
        setState(() {
          _isLoading = false; // Hide loading indicator
        });
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields and select a lesson.'),
        ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Manage Assignments'),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assignment Details',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
              const SizedBox(height: 16),
              if (_lessons.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: 'Select Lesson',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _lessons.map((lesson) {
                    return DropdownMenuItem<String>(
                      value: lesson['id'] as String,
                      child: Text(lesson['title'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLesson = value;
                      _selectedGrade = null; // Reset grade when lesson changes
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a lesson' : null,
                )
              else
                const Center(
                  child: Text(
                    'No lessons assigned. Please assign lessons to create assignments.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              if (_grades.isNotEmpty)
                DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: 'Select Grade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  items: _grades.map((grade) {
                    return DropdownMenuItem<int>(
                      value: grade,
                      child: Text('Grade $grade'),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedGrade = value;
                    });
                  },
                  validator: (value) =>
                      value == null ? 'Please select a grade' : null,
                )
              else
                const Center(
                  child: Text(
                    'No grades available for the selected lesson.',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Assignment Title',
                  hintText: 'Homework 1',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _selectedSubject,
                decoration: InputDecoration(
                  labelText: 'Assignment Subject',
                  hintText: 'Geometry',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a subject'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Assignment Description',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _questionsController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: 'Questions (one per line)',
                  hintText:
                      '1. The lines........\n2. if the........\n3. What is........',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter questions'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _linkController,
                decoration: InputDecoration(
                  labelText: 'Optional Link',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
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
                onPressed: _pickFile, // Added: Pick file function
                icon: const Icon(Icons.attach_file),
                label: const Text('Attach Word/PDF File'),
              ),
              if (_selectedFile != null)
                Row(
                  children: [
                    Expanded(
                      // Ensures the text takes only the available space
                      child: Text(
                        'Selected File: ${_selectedFile!.name}',
                        overflow: TextOverflow
                            .ellipsis, // Adds an ellipsis if the text overflows
                        maxLines: 1, // Limits the text to one line
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedFile = null; // Clear the selected file
                        });
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _dueDate == null
                        ? 'Select Due Date'
                        : 'Due Date: ${_dueDate!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      DateTime? selectedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2101),
                      );
                      if (selectedDate != null) {
                        setState(() {
                          _dueDate = selectedDate;
                        });
                      }
                    },
                    child: const Text('Pick Date'),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : _createAndAssignToStudents, // Disable when loading
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Create Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
