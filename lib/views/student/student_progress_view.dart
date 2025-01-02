import 'package:flutter/material.dart';
import 'package:grade_up/models/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart'; // For charts
import 'package:google_fonts/google_fonts.dart'; // For custom fonts
import 'package:pdf/widgets.dart' as pw;

class StudentProgressSummaryView extends StatefulWidget {
  final Student student;

  const StudentProgressSummaryView({super.key, required this.student});

  @override
  State<StudentProgressSummaryView> createState() =>
      _StudentProgressSummaryViewState();
}

class _StudentProgressSummaryViewState
    extends State<StudentProgressSummaryView> {
  bool _isLoading = true;
  int _totalAssignments = 0;
  int _completedAssignments = 0;
  int _pendingAssignments = 0;
  double _averageScore = 0.0;
  Map<String, double> _lessonScores = {};

  @override
  void initState() {
    super.initState();
    _fetchStudentProgress();
  }

  Future<void> _fetchStudentProgress() async {
    final firestore = FirebaseFirestore.instance;
    final studentId = widget.student.studentId;
    final school = widget.student.school;
    final grade = widget.student.grade.toString();

    try {
      final assignmentsSnapshot = await firestore
          .collection('schools')
          .doc(school)
          .collection('grades')
          .doc(grade)
          .collection('students')
          .doc(studentId)
          .collection('assignmentsToDo')
          .get();

      int totalAssignments = 0;
      int completedAssignments = 0;
      double totalScore = 0.0;
      int scoredAssignments = 0;
      Map<String, double> lessonScores = {};

      for (var doc in assignmentsSnapshot.docs) {
        final data = doc.data();
        totalAssignments++;

        if (data['status'] == 'submitted') {
          completedAssignments++;
        }

        if (data['score'] != null) {
          final score = data['score'] as int;
          totalScore += score;
          scoredAssignments++;
          final lesson = data['lesson'] ?? 'General';
          lessonScores[lesson] = (lessonScores[lesson] ?? 0.0) + score;
        }
      }

      if (scoredAssignments > 0) {
        totalScore /= scoredAssignments;
        lessonScores.updateAll(
          (lesson, score) => score / scoredAssignments,
        );
      }

      setState(() {
        _totalAssignments = totalAssignments;
        _completedAssignments = completedAssignments;
        _pendingAssignments = totalAssignments - completedAssignments;
        _averageScore = totalScore;
        _lessonScores = lessonScores;
        _isLoading = false;
      });
    } catch (e) {
      print('Error fetching student progress: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _generatePDF() async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('Progress Summary',
                style: const pw.TextStyle(fontSize: 24)),
            pw.SizedBox(height: 10),
            pw.Text('Total Assignments: $_totalAssignments'),
            pw.Text('Completed Assignments: $_completedAssignments'),
            pw.Text('Pending Assignments: $_pendingAssignments'),
            pw.Text('Average Score: ${_averageScore.toStringAsFixed(1)}'),
          ],
        ),
      ),
    );
    // Save PDF to device or share
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progress Summary'),
        backgroundColor: const Color(0xFF0072FF), // Blue tone
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              // Add scrolling to the body
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Total Progress Summary
                    Card(
                      color: const Color(0xFFCCE4FF), // Light blue
                      child: SizedBox(
                        width: double
                            .infinity, // Ensures the card spans the full width
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Overall Progress',
                                style: GoogleFonts.roboto(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF003366), // Dark blue
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Total Assignments: $_totalAssignments',
                                style: GoogleFonts.roboto(fontSize: 16),
                              ),
                              Text(
                                'Completed Assignments: $_completedAssignments',
                                style: GoogleFonts.roboto(fontSize: 16),
                              ),
                              Text(
                                'Pending Assignments: $_pendingAssignments',
                                style: GoogleFonts.roboto(fontSize: 16),
                              ),
                              Text(
                                'Average Score: ${_averageScore.toStringAsFixed(1)}',
                                style: GoogleFonts.roboto(fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Lesson-wise Average Scores
                    Card(
                      color: const Color(0xFFB3D9FF), // Medium blue
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Average Scores by Lesson',
                              style: GoogleFonts.roboto(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF003366),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ..._lessonScores.entries.map(
                              (entry) => Text(
                                '${entry.key}: ${entry.value.toStringAsFixed(1)}',
                                style: GoogleFonts.roboto(fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Assignment Completion Chart
                    Text(
                      'Assignment Completion',
                      style: GoogleFonts.roboto(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        color: const Color(0xFF003366),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 200, // Set a specific height for the chart
                      child: PieChart(
                        PieChartData(
                          sections: [
                            PieChartSectionData(
                              value: _completedAssignments.toDouble(),
                              title: 'Completed',
                              color: Colors.blue, // Blue tone
                              radius: 50,
                              titleStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            PieChartSectionData(
                              value: _pendingAssignments.toDouble(),
                              title: 'Pending',
                              color: Colors.lightBlue, // Light blue
                              radius: 50,
                              titleStyle: GoogleFonts.roboto(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                          sectionsSpace: 2,
                          centerSpaceRadius: 40,
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),

                    Column(
                      children: [
                        Text(
                          'Score Trends Over Time',
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            color: const Color(0xFF003366),
                          ),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              titlesData: const FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval:
                                        10, // Adjust interval for better readability
                                    reservedSize: 40,
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: 1,
                                    reservedSize: 30,
                                  ),
                                ),
                              ),
                              borderData: FlBorderData(
                                show: true,
                                border:
                                    Border.all(color: Colors.grey, width: 1),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _lessonScores.entries
                                      .toList()
                                      .asMap()
                                      .entries
                                      .map((entry) => FlSpot(
                                          entry.key.toDouble(),
                                          entry.value.value))
                                      .toList(),
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 4,
                                  isStrokeCapRound: true,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment
                              .center, // Aligns the icon and text
                          children: [
                            IconButton(
                              icon: const Icon(Icons.picture_as_pdf),
                              onPressed: _generatePDF,
                            ),
                            const SizedBox(
                                width: 8), // Space between the icon and text
                            const Text(
                              'Generate your summary PDF',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
