import 'package:flutter/material.dart';
import 'package:grade_up/models/teacher.dart';
import 'package:grade_up/views/teacher/courses_selection_view.dart';

class GradeSelection extends StatelessWidget {
  final Teacher teacher;

  const GradeSelection({super.key, required this.teacher});

  List<int> getUniqueGrades() {
    final uniqueGrades = <int>{};
    teacher.lessonGradeMap.forEach((lesson, grades) {
      uniqueGrades.addAll(grades);
    });
    return uniqueGrades.toList()..sort();
  }

  @override
  Widget build(BuildContext context) {
    final grades = getUniqueGrades();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Grade'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
      ),
      body: grades.isNotEmpty
          ? GridView.builder(
              padding: const EdgeInsets.all(16.0),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Number of cards per row
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2, // Adjust the size of the cards
              ),
              itemCount: grades.length,
              itemBuilder: (context, index) {
                final grade = grades[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CoursesSelection(
                          teacher: teacher,
                          selectedGrade: grade,
                        ),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: const Color.fromARGB(255, 118, 255, 68),
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          colors: [
                            Colors.blue.shade300,
                            const Color.fromARGB(255, 118, 255, 68),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.white,
                            child: Text(
                              grade.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color.fromARGB(255, 118, 255, 68),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Grade $grade',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )
          : const Center(
              child: Text(
                "You don't teach any grades yet.",
                style: TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              ),
            ),
    );
  }
}
