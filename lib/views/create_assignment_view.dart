import 'package:flutter/material.dart';
import 'package:grade_up/service/assignment_service.dart';

class CreateAssignmentView extends StatefulWidget {
  final String teacherId; // Pass the teacherId when navigating to this page

  const CreateAssignmentView({super.key, required this.teacherId});

  @override
  CreateAssignmentViewState createState() => CreateAssignmentViewState();
}

class CreateAssignmentViewState extends State<CreateAssignmentView> {
  final _formKey = GlobalKey<FormState>();
  final AssignmentService assignmentService = AssignmentService();

  List<Map<String, dynamic>> _lessons = [];
  String? _selectedLessonId;
  String? _assignmentTitle;
  String? _assignmentDescription;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _loadLessons();
  }

  Future<void> _loadLessons() async {
    _lessons = await assignmentService.getAssignedLessons(widget.teacherId);
    setState(() {});
  }

  Future<void> _createAssignment() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final assignmentData = {
        'title': _assignmentTitle,
        'description': _assignmentDescription,
        'dueDate': _dueDate?.toIso8601String(),
        'questions': [], // Empty array initially; questions can be added later
      };

      // Now createAssignment will return a DocumentReference
      final assignmentRef = await assignmentService.createAssignment(
        _selectedLessonId!,
        assignmentData,
      );

      // Use assignmentRef.id to assign to students
      await assignmentService.assignToEnrolledStudents(
        _selectedLessonId!,
        assignmentRef.id,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment created and assigned!')),
      );

      Navigator.pop(context); // Close the assignment creation page
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_lessons.isNotEmpty)
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Select Lesson'),
                  items: _lessons.map<DropdownMenuItem<String>>((lesson) {
                    return DropdownMenuItem<String>(
                      value: lesson['id'] as String,
                      child: Text(lesson['title'] as String),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedLessonId = value;
                    });
                  },
                  value: _selectedLessonId,
                ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Assignment Title'),
                onSaved: (value) => _assignmentTitle = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a title'
                    : null,
              ),
              TextFormField(
                decoration:
                    const InputDecoration(labelText: 'Assignment Description'),
                onSaved: (value) => _assignmentDescription = value,
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a description'
                    : null,
              ),
              const SizedBox(height: 20),
              TextButton.icon(
                onPressed: () async {
                  _dueDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  setState(() {}); // Refresh to show selected date
                },
                icon: const Icon(Icons.calendar_today),
                label: Text(
                  _dueDate == null
                      ? 'Select Due Date'
                      : 'Due Date: ${_dueDate!.toLocal().toShortDateString()}',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _createAssignment,
                child: const Text('Create Assignment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

extension DateFormatting on DateTime {
  String toShortDateString() {
    return '${this.year}-${this.month.toString().padLeft(2, '0')}-${this.day.toString().padLeft(2, '0')}';
  }
}
