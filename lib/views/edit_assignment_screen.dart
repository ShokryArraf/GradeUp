import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/assignment_service.dart';

class EditAssignmentScreen extends StatefulWidget {
  final Map<String, dynamic> assignmentData;
  final String lessonId;
  final String grade;
  final Teacher teacher;

  const EditAssignmentScreen({
    super.key,
    required this.assignmentData,
    required this.lessonId,
    required this.grade,
    required this.teacher,
  });

  @override
  State<EditAssignmentScreen> createState() => _EditAssignmentScreenState();
}

class _EditAssignmentScreenState extends State<EditAssignmentScreen> {
  final AssignmentService _assignmentService = AssignmentService();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _subjectController;
  late TextEditingController _linkController;
  late TextEditingController _questionsController;
  late DateTime? _dueDate;
  late bool isEditable;

  @override
  void initState() {
    super.initState();
    _titleController =
        TextEditingController(text: widget.assignmentData['title']);
    _descriptionController =
        TextEditingController(text: widget.assignmentData['description']);
    _subjectController =
        TextEditingController(text: widget.assignmentData['subject']);
    _linkController =
        TextEditingController(text: widget.assignmentData['link']);
    _questionsController = TextEditingController(
        text: widget.assignmentData['questions']?.join(', ') ?? '');
    _dueDate = widget.assignmentData['dueDate'] != null
        ? DateTime.parse(widget.assignmentData['dueDate'])
        : null;

// Determine if the assignment is editable
    isEditable = _dueDate == null ||
        _dueDate!.isAfter(DateTime.now()) ||
        (_dueDate!.year == DateTime.now().year &&
            _dueDate!.month == DateTime.now().month &&
            _dueDate!.day == DateTime.now().day);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _subjectController.dispose();
    _linkController.dispose();
    _questionsController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final subject = _subjectController.text.trim();
    final link = _linkController.text.trim();
    final questions = _questionsController.text
        .split(',')
        .map((q) => q.trim())
        .where((q) => q.isNotEmpty)
        .toList();

    if (title.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Title and description are required.')),
      );
      return;
    }

    try {
      // Call the updateAssignment function (adjusted to your actual implementation)
      await _assignmentService.updateAssignment(
        lessonId: widget.lessonId,
        assignmentId: widget.assignmentData['id'],
        grade: widget.grade,
        teacher: widget.teacher,
        title: title,
        description: description,
        dueDate: _dueDate,
        questions: questions.isEmpty ? null : questions,
        subject: subject.isNotEmpty ? subject : null,
        link: link.isNotEmpty ? link : null,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment updated successfully.')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update assignment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Assignment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!isEditable)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                color: Colors.redAccent.withOpacity(0.2),
                child: const Text(
                  'This assignment cannot be edited because the due date has already passed.',
                  style:
                      TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ),
            Expanded(
              child: ListView(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Title'),
                    enabled: isEditable,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _descriptionController,
                    decoration: const InputDecoration(labelText: 'Description'),
                    enabled: isEditable,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _subjectController,
                    decoration: const InputDecoration(labelText: 'Subject'),
                    enabled: isEditable,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _linkController,
                    decoration: const InputDecoration(labelText: 'Link'),
                    enabled: isEditable,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _questionsController,
                    decoration: const InputDecoration(
                        labelText: 'Questions (comma-separated)'),
                    enabled: isEditable,
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    title: const Text('Due Date'),
                    subtitle: Text(
                      _dueDate != null
                          ? _dueDate!.toLocal().toString().split(' ')[0]
                          : 'Not set',
                    ),
                    trailing: isEditable
                        ? IconButton(
                            icon: const Icon(Icons.calendar_today),
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: _dueDate ?? DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );

                              if (selectedDate != null) {
                                setState(() {
                                  _dueDate = selectedDate;
                                });
                              }
                            },
                          )
                        : null,
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: isEditable ? _saveChanges : null,
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
