import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/utilities/build_detail_card.dart';
import 'package:grade_up/utilities/format_date.dart';
import 'package:grade_up/utilities/open_file.dart';

class SubmissionDetailsPage extends StatefulWidget {
  final String schoolId;
  final String gradeId;
  final String studentId;
  final String assignmentId;

  const SubmissionDetailsPage({
    super.key,
    required this.schoolId,
    required this.gradeId,
    required this.studentId,
    required this.assignmentId,
  });

  @override
  SubmissionDetailsPageState createState() => SubmissionDetailsPageState();
}

class SubmissionDetailsPageState extends State<SubmissionDetailsPage> {
  // Variables to store fetched data
  Map<String, String> _submittedAnswers = {};
  String? _submittedFileUrl;
  String? _additionalInput;
  String? _score;
  String? _dueDate;
  String? _status;
  String? _review;
  String? _teacherReview;

  @override
  void initState() {
    super.initState();
    _fetchSubmissionDetails();
  }

  // Fetch the submission details from Firestore
  Future<void> _fetchSubmissionDetails() async {
    final submissionRef = FirebaseFirestore.instance
        .collection('schools')
        .doc(widget.schoolId)
        .collection('grades')
        .doc(widget.gradeId)
        .collection('students')
        .doc(widget.studentId)
        .collection('assignmentsToDo')
        .doc(widget.assignmentId);

    // Fetch the submission data from Firestore
    final docSnapshot = await submissionRef.get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();

      // Get the answers (assuming it's stored in a map-like format)
      if (data != null && data['answers'] != null) {
        setState(() {
          _submittedAnswers = Map<String, String>.from(data['answers']);
          _submittedFileUrl = data['uploadedFileUrl'];
          _additionalInput = data['additionalInput'];
          _score = data['score']?.toString();
          _dueDate = formatDueDate(data['dueDate']);
          _status = data['status'];
          _review = data['review'];
          _teacherReview = data['teacherReviewed'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text('Your Submission'),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          )),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Assignment Details:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Status & Submission Date
              buildDetailCard('Status', _status ?? 'Not Submitted',
                  Icons.assignment, Colors.blue),
              buildDetailCard('Due Date', _dueDate ?? 'N/A',
                  Icons.calendar_today, Colors.orange),

              const SizedBox(height: 20),

              // Display answers
              const Text(
                'Submitted Answers:',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              if (_submittedAnswers.isNotEmpty)
                ..._submittedAnswers.entries.toList().asMap().entries.map(
                  (entry) {
                    // Add 1 to make the index start from 1 (Answer 1, Answer 2, etc.)
                    int index = entry.key + 1;
                    String answerTitle =
                        'Answer $index'; // Create dynamic answer titles

                    // Extract the answer value correctly
                    String answerValue =
                        entry.value.value; // Access the value of the map entry

                    // Return the DetailCard with dynamic title and value
                    return buildDetailCard(answerTitle, answerValue,
                        Icons.question_answer, Colors.green);
                  },
                ),
              const SizedBox(height: 20),

              // Additional Input
              if (_additionalInput != null && _additionalInput!.isNotEmpty)
                buildDetailCard('Additional Input', _additionalInput!,
                    Icons.notes, Colors.purple),

              const SizedBox(height: 20),

              // Score
              if (_score != null)
                buildDetailCard('Score', _score!, Icons.grade, Colors.red),

              const SizedBox(height: 20),

              // Review
              if (_review != null && _teacherReview != null)
                buildDetailCard('Teacher $_teacherReview Review', _review!,
                    Icons.reviews, Colors.grey),

              const SizedBox(height: 20),

              // Optionally show the submitted file if available
              if (_submittedFileUrl != null)
                ElevatedButton.icon(
                  onPressed: () {
                    openFile(_submittedFileUrl!);
                  },
                  icon: const Icon(Icons.attach_file),
                  label: const Text('View Submitted File '),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    textStyle: const TextStyle(fontSize: 17),
                  ),
                ),
              if (_submittedFileUrl == null)
                const Text('No file submitted',
                    style: TextStyle(fontStyle: FontStyle.italic)),
            ],
          ),
        ),
      ),
    );
  }
}
