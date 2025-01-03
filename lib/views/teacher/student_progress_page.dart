import 'package:flutter/material.dart';

class StudentProgressPage extends StatelessWidget {
  final int grade;
  final List<Map<String, dynamic>> studentProgress;

  const StudentProgressPage({
    super.key,
    required this.grade,
    required this.studentProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Grade $grade Progress'),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: studentProgress.isEmpty
            ? const Center(child: Text('No student progress available.'))
            : ListView.builder(
                itemCount: studentProgress.length,
                itemBuilder: (context, index) {
                  final student = studentProgress[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16.0),
                    elevation: 4,
                    child: ListTile(
                      title: Text(student['name']),
                      subtitle: Text(
                          'Completed: ${student['completed']} / ${student['total']} assignments'),
                      trailing: Icon(
                        Icons.check_circle,
                        color: student['completed'] == student['total']
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
