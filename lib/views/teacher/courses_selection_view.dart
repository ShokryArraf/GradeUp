import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:grade_up/views/teacher/manage_course.dart';

class CoursesSelection extends StatelessWidget {
  final Teacher teacher;
  final int selectedGrade;

  const CoursesSelection(
      {super.key, required this.teacher, required this.selectedGrade});

  List<Map<String, dynamic>> getLessonsByGrade() {
    return teacher.lessonGradeMap.keys
        .map((lesson) => {
              'id': lesson,
              'title': lesson,
              'grades': teacher.lessonGradeMap[lesson],
            })
        .where((lesson) {
      final grades = lesson['grades'] as List<int>;
      return grades.contains(selectedGrade);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final lessons = getLessonsByGrade();

    return Scaffold(
      appBar: AppBar(
        title: Text('Courses for Grade $selectedGrade'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: lessons.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: lessons.map((lesson) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ManageCourse(
                            teacher: teacher,
                            grade: selectedGrade,
                            lesson: lesson['id'].toString(),
                          ),
                        ),
                      );
                    },
                    child: buildDashboardCard(
                      lesson['title'] == 'math'
                          ? Icons.calculate
                          : lesson['title'] == 'english'
                              ? Icons.explicit
                              : lesson['title'] == 'biology'
                                  ? Icons.biotech
                                  : lesson['title'] == 'geography'
                                      ? Icons.public
                                      : lesson['title'] == 'chemistry'
                                          ? Icons.science
                                          : lesson['title'] == 'hebrew'
                                              ? Icons.book
                                              : Icons.bookmark,
                      lesson['title'].toString().toUpperCase(),
                      lesson['title'] == 'math'
                          ? Colors.green
                          : lesson['title'] == 'english'
                              ? Colors.red
                              : lesson['title'] == 'biology'
                                  ? const Color.fromARGB(255, 131, 23, 50)
                                  : lesson['title'] == 'geography'
                                      ? Colors.brown
                                      : lesson['title'] == 'chemistry'
                                          ? Colors.yellow
                                          : lesson['title'] == 'hebrew'
                                              ? Colors.black
                                              : Colors.blue,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ManageCourse(
                              teacher: teacher,
                              grade: selectedGrade,
                              lesson: lesson['id'].toString(),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }).toList(),
              ),
            )
          : const Center(
              child: Text(
                "No courses available for this grade.",
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
