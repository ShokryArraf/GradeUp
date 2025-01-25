import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/service/game_service.dart';

class StudentProgressGameView extends StatefulWidget {
  final Teacher teacher;

  const StudentProgressGameView({super.key, required this.teacher});

  @override
  StudentProgressGameViewState createState() => StudentProgressGameViewState();
}

class StudentProgressGameViewState extends State<StudentProgressGameView> {
  final GameService _gameService = GameService();
  final int _pageSize = 3; // Number of progress items per chunk
  late Future<List<Map<String, dynamic>>> _studentsFuture;

  // Add search-related fields
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _allStudents = [];
  List<Map<String, dynamic>> _filteredStudents = [];

  @override
  void initState() {
    super.initState();
    _studentsFuture = _fetchStudents();
  }

  Future<List<Map<String, dynamic>>> _fetchStudents() async {
    final List<Map<String, dynamic>> students = [];

    for (var entry in widget.teacher.lessonGradeMap.entries) {
      final String lesson = entry.key;
      final List<int> grades = entry.value;

      for (var grade in grades) {
        // Call the Firebase interaction function to fetch progress data
        final studentProgressForGrade =
            await _gameService.fetchStudentDataFromFirestore(
          school: widget.teacher.school,
          grade: grade,
          lesson: lesson,
        );

        // Append the fetched data to the main list
        students.addAll(studentProgressForGrade);
      }
    }

    // Initialize the filtered list with all students initially
    _allStudents = students;
    _filteredStudents = students;

    return students;
  }

  void _filterStudents(String query) {
    if (query.isEmpty) {
      setState(() {
        _filteredStudents = _allStudents;
      });
    } else {
      setState(() {
        _filteredStudents = _allStudents
            .where((student) =>
                student['name'].toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'התקדמות משחק לתלמיד',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
        ),
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
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterStudents,
              decoration: InputDecoration(
                hintText: 'חיפוש לפי שם תלמיד',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _studentsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = _filteredStudents; // Use the filtered list
          if (students.isEmpty) {
            return const Center(
              child: Text(
                'לא נמצא תלמידים',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
              ),
            );
          }

          // Group students by their ID
          final groupedStudents = <String, List<Map<String, dynamic>>>{};
          for (var student in students) {
            groupedStudents.putIfAbsent(student['id'], () => []).add(student);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: groupedStudents.keys.length,
            itemBuilder: (context, index) {
              final studentId = groupedStudents.keys.elementAt(index);
              final studentProgress = groupedStudents[studentId]!;

              return PaginatedProgressCard(
                studentData: studentProgress[0],
                progressData: studentProgress,
                pageSize: _pageSize,
              );
            },
          );
        },
      ),
    );
  }
}

class PaginatedProgressCard extends StatefulWidget {
  final Map<String, dynamic> studentData;
  final List<Map<String, dynamic>> progressData;
  final int pageSize;

  const PaginatedProgressCard({
    super.key,
    required this.studentData,
    required this.progressData,
    required this.pageSize,
  });

  @override
  PaginatedProgressCardState createState() => PaginatedProgressCardState();
}

class PaginatedProgressCardState extends State<PaginatedProgressCard> {
  int _currentPage = 0;

  @override
  Widget build(BuildContext context) {
    final startIndex = _currentPage * widget.pageSize;
    final endIndex = startIndex + widget.pageSize;
    final hasMore = endIndex < widget.progressData.length;

    final currentPageData = widget.progressData.sublist(
      startIndex,
      endIndex > widget.progressData.length
          ? widget.progressData.length
          : endIndex,
    );

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ListTile(
              contentPadding: const EdgeInsets.all(0),
              title: Row(
                mainAxisAlignment: MainAxisAlignment.end, // Aligns the entire row to the right
                children: [
                  Text(
                    '${widget.studentData['name']} - כיתה ${widget.studentData['grade']}',
                    textAlign: TextAlign.right,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8.0), // Add spacing between the text and avatar
                  CircleAvatar(
                    backgroundColor: Colors.blueAccent,
                    child: Text(
                      widget.studentData['name'][0],
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            ...currentPageData.map((progress) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('שיעור: ${progress['lesson']}'),
                    Text('רמה: ${progress['level']}'),
                    Text('נקודות: ${progress['points']}'),
                    Text('תשובות נכונות: ${progress['rightAnswers']}'),
                    Text('תשובות שגויות: ${progress['wrongAnswers']}'),
                  ],
                ),
              );
            }),
            if (hasMore)
              TextButton(
                onPressed: () {
                  setState(() {
                    _currentPage++;
                  });
                },
                child: const Text('הצג עוד'),
              ),
          ],
        ),
      ),
    );
  }
}
