import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package for charts

class StudentProgressPage extends StatelessWidget {
  final int grade;
  final List<Map<String, dynamic>> studentProgress;

  const StudentProgressPage({
    super.key,
    required this.grade,
    required this.studentProgress,
  });

  double _calculateOverallProgress() {
    if (studentProgress.isEmpty) return 0.0;
    final totalAssignments = studentProgress.fold<int>(
        0, (sum, student) => sum + ((student['total'] ?? 0) as int));
    final completedAssignments = studentProgress.fold<int>(
        0, (sum, student) => sum + ((student['completed'] ?? 0) as int));

    return totalAssignments > 0 ? completedAssignments / totalAssignments : 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final overallProgress = _calculateOverallProgress();

    return Scaffold(
      appBar: AppBar(
        title: Text('התקדמות כיתה $grade'),
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
      body: Column(
        children: [
          // Overall Progress Summary
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'התקדמות הכיתה הכללית',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: LinearProgressIndicator(
                        value: overallProgress,
                        backgroundColor: Colors.grey[300],
                        color: overallProgress == 1.0
                            ? Colors.blueAccent
                            : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      '${(overallProgress * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 150,
                  child: PieChart(
                    PieChartData(
                      sections: studentProgress.map((student) {
                        final progress = student['total'] > 0
                            ? student['completed'] / student['total']
                            : 0.0;
                        return PieChartSectionData(
                          value: progress * 100,
                          color: progress == 1.0
                              ? Colors.blueAccent
                              : Colors.green,
                          title: '${student['name']}',
                          radius: 50,
                          titleStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Student List
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: studentProgress.isEmpty
                  ? const Center(
                      child: Text(
                        'אין תלמידים להצגה',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: studentProgress.length,
                      itemBuilder: (context, index) {
                        final student = studentProgress[index];
                        final progress = (student['total'] > 0)
                            ? (student['completed'] / student['total'])
                            : 0.0;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          elevation: 6,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      student['name'],
                                      style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Icon(
                                      Icons.check_circle,
                                      color: student['completed'] ==
                                              student['total']
                                          ? Colors.blue
                                          : Colors.orange,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Completed ${student['completed']} of ${student['total']} assignments',
                                  style: const TextStyle(fontSize: 14),
                                ),
                                const SizedBox(height: 8),
                                LinearProgressIndicator(
                                  value: progress,
                                  backgroundColor: Colors.grey[300],
                                  color: progress == 1.0
                                      ? Colors.blueAccent
                                      : Colors.green,
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Progress: ${(progress * 100).toStringAsFixed(1)}%',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
