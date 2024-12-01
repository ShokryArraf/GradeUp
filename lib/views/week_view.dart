import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:grade_up/views/content_view.dart';

class WeekView extends StatefulWidget {
  final Student student;

  const WeekView({super.key, required this.student});

  @override
  State<WeekView> createState() =>
      _WeekViewState();
}

class _WeekViewState extends State<WeekView> {

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
            // Regular content cards
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: GestureDetector(
              onTap: () {
                // Navigate to ManageWeek and pass the week number
                Navigator.push(
                  context,
                  MaterialPageRoute(
                        builder: (context) => ContentView(student: widget.student),
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
        },
      ),
    );
  }
}

