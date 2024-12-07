import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/assignment_service.dart';
import 'package:grade_up/views/edit_assignment_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class SearchDeleteAssignmentSection extends StatefulWidget {
  final Teacher teacher;

  const SearchDeleteAssignmentSection({super.key, required this.teacher});

  @override
  State<SearchDeleteAssignmentSection> createState() =>
      SearchDeleteAssignmentSectionState();
}

class SearchDeleteAssignmentSectionState
    extends State<SearchDeleteAssignmentSection> {
  final TextEditingController _gradeSearchController = TextEditingController();
  final AssignmentService _assignmentService = AssignmentService();

  String? _selectedLesson;
  List<int> _gradesList = [];
  List<int> _filteredGrades = [];
  List<Map<String, dynamic>> _assignments = [];
  bool _isLoading = false;

  // Update grades list when a lesson is selected
  void _updateGradesList(String selectedLesson) {
    setState(() {
      _gradesList = widget.teacher.lessonGradeMap[selectedLesson] ?? [];
      _filteredGrades = List.from(_gradesList); // Initialize filtered grades
    });
  }

  // Filter grades dynamically based on search input
  void _filterGrades(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredGrades = List.from(_gradesList);
      });
      return;
    }

    final searchGrade = int.tryParse(query);
    if (searchGrade != null) {
      setState(() {
        _filteredGrades =
            _gradesList.where((grade) => grade == searchGrade).toList();
      });
    } else {
      setState(() {
        _filteredGrades = [];
      });
    }
  }

  // Search assignments by grade
  Future<void> _searchAssignmentsByGrade(int grade) async {
    if (_selectedLesson == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final assignments = await _assignmentService.fetchAssignments(
        lessonName: _selectedLesson!,
        grade: grade,
        teacher: widget.teacher,
      );

      setState(() {
        _assignments = assignments;
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Delete an assignment
  Future<void> _deleteAssignment(
      String lessonName, String assignmentId, String grade) async {
    try {
      await _assignmentService.deleteAssignment(
          lessonName, assignmentId, widget.teacher.school, grade);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Assignment deleted successfully.')),
      );

      // Remove the deleted assignment from the list
      setState(() {
        _assignments
            .removeWhere((assignment) => assignment['id'] == assignmentId);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting assignment: $e')),
      );
    }
  }

  @override
  void dispose() {
    _gradeSearchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search and Delete Assignments'),
        backgroundColor: Colors.blueAccent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
              const Text(
                'Search and Delete Assignments',
                style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent),
              ),
              const SizedBox(height: 16),

              // Dropdown to select a lesson
              DropdownButtonFormField<String>(
                value: _selectedLesson,
                decoration: const InputDecoration(
                  labelText: 'Select Lesson',
                  border: OutlineInputBorder(),
                ),
                items: widget.teacher.lessonGradeMap.keys.map((lesson) {
                  return DropdownMenuItem<String>(
                    value: lesson,
                    child: Text(lesson),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLesson = value!;
                    _updateGradesList(value);
                  });
                },
              ),
              const SizedBox(height: 16),

              // Grade search input
              if (_selectedLesson != null)
                TextField(
                  controller: _gradeSearchController,
                  decoration: const InputDecoration(
                    labelText: 'Search Grade',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: _filterGrades,
                ),

              const SizedBox(height: 16),

              // Display filtered grades
              if (_selectedLesson != null && _filteredGrades.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _filteredGrades.length,
                  itemBuilder: (context, index) {
                    final grade = _filteredGrades[index];
                    return ListTile(
                      title: Text('Grade: $grade'),
                      trailing: IconButton(
                        icon: const Icon(Icons.search, color: Colors.blue),
                        onPressed: () => _searchAssignmentsByGrade(grade),
                      ),
                    );
                  },
                ),

              // Message if no grades match
              if (_selectedLesson != null && _filteredGrades.isEmpty)
                const Text(
                  'No grades match your search.',
                  style: TextStyle(color: Colors.red),
                ),

              const SizedBox(height: 16),

              // Assignments List
              if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading && _assignments.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: _assignments.length,
                  itemBuilder: (context, index) {
                    final assignment = _assignments[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        title: Text(
                          assignment['lessonName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.blueAccent,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              'Grade: ${assignment['grade']}',
                              style: const TextStyle(
                                  fontSize: 16, color: Colors.grey),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Title: ${assignment['title']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Subject: ${assignment['subject']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Description: ${assignment['description']}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Questions:',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children:
                                  (assignment['questions'] as List<dynamic>)
                                      .map((question) => Padding(
                                            padding: const EdgeInsets.only(
                                                left: 8.0, top: 4.0),
                                            child: Text(
                                              '- $question',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  color: Colors.black87),
                                            ),
                                          ))
                                      .toList(),
                            ),
                            if (assignment['link'] != null &&
                                assignment['link'].isNotEmpty) ...[
                              const SizedBox(height: 4),
                              GestureDetector(
                                onTap: () async {
                                  final url = Uri.parse(assignment['link']);
                                  if (await canLaunchUrl(url)) {
                                    await launchUrl(url);
                                  } else {
                                    throw 'Could not launch $url';
                                  }
                                },
                                child: Text(
                                  'Link: ${assignment['link']}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.green),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditAssignmentScreen(
                                        assignmentData:
                                            assignment, // Pass the assignment data
                                        lessonId: assignment['lessonName'],
                                        grade: assignment['grade'].toString(),
                                        teacher: widget.teacher),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteAssignment(
                                  assignment['lessonName'],
                                  assignment['id'],
                                  assignment['grade'].toString()),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              if (!_isLoading &&
                  _assignments.isEmpty &&
                  _selectedLesson != null)
                const Text(
                  'No assignments found for the selected grade.',
                  style: TextStyle(color: Colors.red),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
