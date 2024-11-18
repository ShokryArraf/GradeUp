import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/assignment_service.dart';

class CreateAssignmentView extends StatefulWidget {
  final Teacher teacher;

  const CreateAssignmentView({super.key, required this.teacher});

  @override
  CreateAssignmentViewState createState() => CreateAssignmentViewState();
}

class CreateAssignmentViewState extends State<CreateAssignmentView> {
  final _formKey = GlobalKey<FormState>();
  final _assignmentService = AssignmentService();

  String? _selectedLesson;
  int? _selectedGrade;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _questionsController = TextEditingController();
  DateTime? _dueDate;

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
      // Create the assignment
      DocumentReference assignmentRef =
          await _assignmentService.createAssignment(
        _selectedLesson!,
        title: _titleController.text,
        description: _descriptionController.text,
        dueDate: _dueDate!,
        questions: _questionsController.text.split(','),
        grade: _selectedGrade!,
        teacherName: widget.teacher.name,
      );

      // Assign to all enrolled students
      await _assignmentService.assignToEnrolledStudents(
        _selectedLesson!,
        assignmentRef.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Assignment created and assigned to students!')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill out all fields and select a lesson.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Assignment'),
        centerTitle: true,
      ),
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
                controller: _descriptionController,
                maxLines: 3,
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
                decoration: InputDecoration(
                  labelText: 'Questions (comma-separated)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter questions'
                    : null,
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
                  onPressed: _createAndAssignToStudents,
                  child: const Text('Create Assignment'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
