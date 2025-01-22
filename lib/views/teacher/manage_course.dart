import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/teacher/manage_material.dart';
import 'package:grade_up/service/teacher_service.dart';

class ManageCourse extends StatefulWidget {
  final Teacher teacher;
  final int grade;
  final String lesson;

  const ManageCourse(
      {super.key,
      required this.teacher,
      required this.grade,
      required this.lesson});

  @override
  State<ManageCourse> createState() => _ManageCourseState();
}

class _ManageCourseState extends State<ManageCourse> {
  final _coursesService = TeacherService();
  bool showAddContentBox = true;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _materials = [];

  @override
  void initState() {
    super.initState();
    _fetchAndSetMaterials();
  }

  Future<void> _fetchAndSetMaterials() async {
    try {
      final materials = await _coursesService.fetchMaterials(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
      );
      setState(() {
        _materials = materials.reversed.toList();
        _isLoading = false;
      });
    } catch (error) {
      showErrorDialog(context, 'Error fetching materials.');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _editContent(String id, String updatedTitle) async {
    try {
      await _coursesService.updateMaterial(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: id,
        updatedFields: updatedTitle,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content updated successfully.')),
      );
      await _fetchAndSetMaterials();
    } catch (_) {
      showErrorDialog(context, 'Failed to update the content.');
    }
  }

  Future<void> _deleteContent(String id) async {
    try {
      await _coursesService.deleteMaterial(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: id,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content deleted successfully.')),
      );
      await _fetchAndSetMaterials();
    } catch (_) {
      showErrorDialog(context, 'Failed to delete the content.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Materials Overview'),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _materials.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddContentBox();
                } else {
                  final content = _materials[index - 1];
                  return _buildContentCard(content);
                }
              },
            ),
    );
  }

  Widget _buildAddContentBox() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: showAddContentBox
          ? GestureDetector(
              onTap: () {
                setState(() {
                  showAddContentBox = false;
                });
              },
              child: _buildCard('Add Content', Icons.add),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter Subject',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _handleAddContent,
                  child: const Text('Add'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAddContentBox = true;
                      _titleController.clear();
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
    );
  }

  Widget _buildContentCard(Map<String, dynamic> content) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Card(
        color: Colors.teal.shade200,
        child: ListTile(
          title: Text(content['title'] ?? 'No Title'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  final newTitle = await _showEditDialog(content['title']);
                  if (newTitle != null) {
                    await _editContent(content['id'], newTitle);
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _deleteContent(content['id']),
              ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ManageMaterial(
                  teacher: widget.teacher,
                  grade: widget.grade,
                  lesson: widget.lesson,
                  materialID: content['id'],
                  materialTitle: content['title'],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<String?> _showEditDialog(String initialTitle) {
    final controller = TextEditingController(text: initialTitle);
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Content'),
          content: TextField(
            controller: controller,
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

  void _handleAddContent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a title.')),
      );
      return;
    }
    try {
      await _coursesService.addMaterial(
        widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        title: title, // Removed materialID
      );
      _titleController.clear();
      setState(() {
        showAddContentBox = true;
      });
      await _fetchAndSetMaterials(); // Fixed call to _fetchAndSetMaterials
    } catch (error) {
      showErrorDialog(context, 'Error adding content.');
    }
  }

  Widget _buildCard(String title, IconData icon) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.black54),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
