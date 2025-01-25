import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_manage_card.dart';
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
      showErrorDialog(context, 'שגיאה בהבאת חומרים');
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
        const SnackBar(content: Text('התוכן עודכן בהצלחה')),
      );
      await _fetchAndSetMaterials();
    } catch (_) {
      showErrorDialog(context, 'עדכון התוכן נכשל');
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
        const SnackBar(content: Text('התוכן נמחק בהצלחה')),
      );
      await _fetchAndSetMaterials();
    } catch (_) {
      showErrorDialog(context, 'מחיקת התוכן נכשלה');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('סקירת חומרים'),
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
              child: buildCard('הוסף תוכן', Icons.add),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'שבוע 1',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _handleAddContent,
                  child: const Text('הוספה'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showAddContentBox = true;
                      _titleController.clear();
                    });
                  },
                  child: const Text('ביטול'),
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
          title: Text(content['title'] ?? 'אין כותרת'),
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
          title: const Text('ערוך תוכן'),
          content: TextField(
            controller: controller,
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

  void _handleAddContent() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('נא להזין כותרת')),
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
      showErrorDialog(context, 'שגיאה בהוספת תוכן');
    }
  }
}
