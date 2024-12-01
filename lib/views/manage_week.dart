import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/views/manage_content.dart';

class ManageWeek extends StatefulWidget {
  final Teacher teacher;

  const ManageWeek({super.key, required this.teacher});

  @override
  State<ManageWeek> createState() =>
      _ManageWeekState();
}

final List<Map<String, String>> _grades = [
  {'id': 'grade1', 'title': '6'},
  {'id': 'grade2', 'title': '7'},
  {'id': 'grade3', 'title': '8'},
  {'id': 'grade4', 'title': '9'},
];

class _ManageWeekState extends State<ManageWeek> {

  String? _selectedLesson;
  String? _selectedGrade; // Example if you have other dependent dropdowns
  bool showAddContentBox = true; // Toggle flag
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Week'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: ListView.builder(
        itemCount: 3, // 2 existing items + 1 "Add Content" item
        itemBuilder: (context, index) {
          if (index == 0) {
            // Special "Add Content" card at the top
            return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: showAddContentBox
          ? GestureDetector(
              onTap: () {
                setState(() {
                  showAddContentBox = false; // Show textbox on tap
                });
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.add, color: Colors.black54),
                    SizedBox(width: 10),
                    Text(
                      'Add Content',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      hintText: 'Enter content title',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () {
                    // Handle the "Add" button press (save title, etc.)
                    if (_titleController.text.isNotEmpty) {
                      // Perform your desired action with the title
                      
                      setState(() {
                        showAddContentBox = true; // Show "Add Content" box again
                        _titleController.clear();  // Clear the text field
                      });
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                        builder: (context) => ManageContent(teacher: widget.teacher),
                      ),
                      );
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
    );
          } else {
            // Regular content cards
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: GestureDetector(
              onTap: () {
                // Navigate to ManageWeek and pass the week number
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageContent(teacher: widget.teacher),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Content #${index}', // Adjust index for content cards
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ));
          }
        },
      ),
    );
  }
}

