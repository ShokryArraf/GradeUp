import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_manage_card.dart';
import 'package:grade_up/utilities/show_error_dialog.dart';
import 'package:grade_up/views/teacher/manage_content.dart';
import 'package:grade_up/service/teacher_service.dart';

class ManageMaterial extends StatefulWidget {
  final Teacher teacher;
  final int grade;
  final String lesson, materialID, materialTitle;

  const ManageMaterial({
    super.key,
    required this.teacher,
    required this.grade,
    required this.lesson,
    required this.materialID,
    required this.materialTitle,
  });

  @override
  State<ManageMaterial> createState() => _ManageMaterialState();
}

class _ManageMaterialState extends State<ManageMaterial> {
  final _coursesService = TeacherService();
  bool showAddContentBox = true;
  final TextEditingController _titleController = TextEditingController();
  bool _isLoading = true;
  List<Map<String, dynamic>> _contentList = [];

  @override
  void initState() {
    super.initState();
    _fetchContent();
  }

  Future<void> _fetchContent() async {
    try {
      final content = await _coursesService.fetchContent(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: widget.materialID,
      );
      setState(() {
        _contentList = content;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      showErrorDialog(context, 'שגיאה בטעינת נתונים');
    }
  }

  Future<void> _editContent(String contentID, String newTitle) async {
    try {
      await _coursesService.editContent(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: widget.materialID,
        contentID: contentID,
        newTitle: newTitle,
      );
      await _fetchContent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content updated successfully!')),
      );
    } catch (error) {
      showErrorDialog(context, 'Error updating content.');
    }
  }

  Future<void> _deleteContent(String contentID) async {
    try {
      await _coursesService.deleteContent(
        lessonName: widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: widget.materialID,
        contentID: contentID,
      );
      await _fetchContent();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Content deleted successfully!')),
      );
    } catch (error) {
      showErrorDialog(context, 'Error deleting content.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage \'${widget.materialTitle}\''),
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
              itemCount: _contentList.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _buildAddContentBox();
                } else {
                  final content = _contentList[index - 1];
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
              child: buildCard('Add Content', Icons.add),
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
                builder: (context) => ManageContent(
                  teacher: widget.teacher,
                  grade: widget.grade,
                  lesson: widget.lesson,
                  materialID: widget.materialID,
                  contentID: content['id'],
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
      await _coursesService.addContent(
        widget.lesson,
        grade: widget.grade,
        teacher: widget.teacher,
        materialID: widget.materialID,
        title: title,
      );
      _titleController.clear();
      showAddContentBox = true;
      await _fetchContent();
    } catch (error) {
      showErrorDialog(context, 'Error adding content.');
    }
  }
}
