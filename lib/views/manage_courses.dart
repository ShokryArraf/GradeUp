import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/views/manage_course.dart';

class ManageCourses extends StatefulWidget {
  final Teacher teacher;

  const ManageCourses({super.key, required this.teacher});

  @override
  State<ManageCourses> createState() =>
      _ManageCoursesState();
}

final List<Map<String, String>> _grades = [
  {'id': 'grade1', 'title': '6'},
  {'id': 'grade2', 'title': '7'},
  {'id': 'grade3', 'title': '8'},
  {'id': 'grade4', 'title': '9'},
];


 

class _ManageCoursesState extends State<ManageCourses> {
 // Retrieve lessons as a list of maps with their associated grades
  List<Map<String, dynamic>> get _lessons => widget.teacher.lessonGradeMap.keys
      .map((lesson) => {
            'id': lesson,
            'title': lesson,
            'grades': widget.teacher.lessonGradeMap[lesson], // Add grades info
          })
      .toList();

  List<int> getUniqueGrades() {
  // Create a Set to store unique grades
  final uniqueGrades = <int>{};

  // Iterate over the lessons and add their grades to the Set
  widget.teacher.lessonGradeMap.forEach((lesson, grades) {
    uniqueGrades.addAll(grades); // Add all grades of the current lesson
  });

  // Convert the Set to a List and return
  return uniqueGrades.toList()..sort(); // Sort the list if necessary
}
    
      
  String? _selectedLesson;
  String? _selectedGrade; // Example if you have other dependent dropdowns
  
  @override
  Widget build(BuildContext context) {
    final gradesL = getUniqueGrades();
  return Scaffold(
    appBar: AppBar(
      title: const Text('Manage Courses'),
      centerTitle: true,
      backgroundColor: Colors.blueAccent,
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(  // Change from GridView to Column
        crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch horizontally
        children: [
          if(gradesL.isNotEmpty)
            // Dropdown taking full width
          DropdownButtonFormField<int>(
            decoration: InputDecoration(
              labelText: 'Select Grade',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
              items: gradesL.map((grade) {
                return DropdownMenuItem<int>(
                  value: grade,
                  child: Text("Grade $grade"),
                );
              }).toList(),
              onChanged: (int? newValue) {
                setState(() {
                  _selectedGrade = newValue.toString();
                });
              },
              isExpanded: true, // Makes the dropdown take full width
            )
              else
                const Center(
                  child: Text(
                    'You don\'t teach in any grades or any courses, please come back when you have something to teach',
                    style: TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
          
          const SizedBox(height: 20),  // Add some spacing
          // GridView below for other items
          Expanded(
  child: GridView.count(
    crossAxisCount: 2,
    crossAxisSpacing: 16,
    mainAxisSpacing: 16,
    // Filter lessons based on selectedGrade before mapping
    children: _lessons
        .where((lesson) {
          // Check if the selectedGrade exists in the lesson's grades
          List<int> grades = lesson['grades'] as List<int>;
          return _selectedGrade != null && grades.contains(int.parse(_selectedGrade!));
        })
        .map((lesson) {
          bool isSelected = _selectedLesson == lesson['id']; // Check if this card is selected
          
          return GestureDetector( // Wrap the card in a GestureDetector
            onTap: () {
              setState(() {
                _selectedLesson = lesson['id']; // Update selected lesson
              });
              
              // Navigate to a new screen
              
            },
            child: buildDashboardCard(
              lesson['title'] == 'math' ? Icons.calculate 
              : lesson['title'] == 'english' ? Icons.explicit 
              : lesson['title'] == 'biology' ? Icons.biotech
              : lesson['title'] == 'geography' ? Icons.public
              : lesson['title'] == 'chemistry' ? Icons.science
              : lesson['title'] == 'hebrew' ? Icons.book
              : Icons.help,
              lesson['title'].toString().toUpperCase(),
              lesson['title'] == 'math' ? Colors.green
              : lesson['title'] == 'english' ? Colors.red
              : lesson['title'] == 'biology' ? Color.fromARGB(255, 131, 23, 50)
              : lesson['title'] == 'geography' ? Colors.brown
              : lesson['title'] == 'chemistry' ? Colors.yellow
              : lesson['title'] == 'hebrew' ? Colors.black
              :Colors.blue, // Change color when selected
              () {
                _selectedLesson = lesson['id'];
                Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ManageCourse(
                    teacher: widget.teacher, grade: int.parse(_selectedGrade!), lesson: _selectedLesson.toString()
                  ),
                ),
              );
              },
              
            ),
          );
        }).toList(), // Convert the iterable to a list of widgets
  ),
),
        ],
      ),
    ),
  );
}

}
