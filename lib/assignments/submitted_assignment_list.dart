import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/utilities/format_date.dart';
import 'package:grade_up/utilities/open_file.dart';

class SubmittedAssignmentsList extends StatelessWidget {
  final String school;
  final String grade;
  final String lesson;

  const SubmittedAssignmentsList({
    super.key,
    required this.school,
    required this.grade,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Set this height
        title: Text('Submitted Assignments \n $lesson - Grade $grade'),
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('schools')
            .doc(school)
            .collection('grades')
            .doc(grade)
            .collection('students')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'No students found for this grade and lesson.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final student = students[index];
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('schools')
                    .doc(school)
                    .collection('grades')
                    .doc(grade)
                    .collection('students')
                    .doc(student.id)
                    .collection('assignmentsToDo')
                    .where('status', isEqualTo: 'submitted')
                    .get(),
                builder: (context, assignmentSnapshot) {
                  if (!assignmentSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final assignments = assignmentSnapshot.data!.docs;

                  if (assignments.isEmpty) {
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      elevation: 4.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 20.0),
                        title: Text(
                          'Student: ${student['name']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'No submissions yet.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ExpansionTile(
                      tilePadding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 16.0),
                      title: Text(
                        'Student: ${student['name']}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent),
                      ),
                      children: assignments.map((assignment) {
                        return Card(
                          margin: const EdgeInsets.all(8.0),
                          elevation: 3.0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Assignment: ${assignment['title']}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'Submitted on: ${assignment['submissionDate'] != null ? (assignment['submissionDate'] as Timestamp).toDate().toString() : 'N/A'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8.0),
                                if (assignment['dueDate'] != null) ...[
                                  Text(
                                    'Due Date: ${formatDueDate(DateTime.tryParse(assignment['dueDate']))}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ] else ...[
                                  const Text('Due Date: N/A',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                                const SizedBox(height: 8.0),
                                // Display Score
                                if (assignment['score'] != null)
                                  Text(
                                    'Score: ${assignment['score']}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                const SizedBox(height: 8.0),
                                // Allow opening the uploaded file
                                if (assignment['uploadedFileUrl'] != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () => openFile(
                                          assignment['uploadedFileUrl']),
                                      child: const Text('Open Uploaded File'),
                                    ),
                                  ),
                                ] else ...[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons
                                              .warning_amber_outlined, // Use a warning icon
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text('No file uploaded.'),
                                      ],
                                    ),
                                  ),
                                ],
                                // Display questions and answers
                                if (assignment['questions'] != null &&
                                    assignment['answers'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: _buildQuestionsAndAnswers(
                                      assignment['questions'] as List<dynamic>,
                                      assignment['answers']
                                          as Map<String, dynamic>,
                                    ),
                                  ),
                                const SizedBox(height: 8.0),
                                // Display additional notes
                                if (assignment['additionalInput'] != null)
                                  Container(
                                    padding: const EdgeInsets.all(
                                        12.0), // Padding inside the box
                                    decoration: BoxDecoration(
                                      color: Colors
                                          .grey[200], // Light background color
                                      borderRadius: BorderRadius.circular(
                                          8.0), // Rounded corners
                                      border: Border.all(
                                        color:
                                            Colors.grey[400]!, // Border color
                                        width: 1.0, // Border width
                                      ),
                                    ),
                                    child: Text(
                                      'Notes: ${assignment['additionalInput']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent, // Text color
                                      ),
                                    ),
                                  ),
                                // Allow teacher to input a score and review
                                const SizedBox(height: 25),
                                const Text(
                                  'Provide Score and Review:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                // Score input field
                                const SizedBox(height: 10),

                                TextField(
                                  decoration: const InputDecoration(
                                    labelText: 'Enter score',
                                    border: OutlineInputBorder(),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                  ),
                                  keyboardType: TextInputType.number,
                                  onChanged: (value) {
                                    // Ensure the value is a number and within the valid range (0-100)
                                    int? score = int.tryParse(value);
                                    if (score != null &&
                                        score >= 0 &&
                                        score <= 100) {
                                      // Update score value logic
                                    } else {
                                      // Handle invalid score input, e.g., show a warning or reset the field
                                    }
                                  },
                                ),
                                const SizedBox(height: 15),
                                // Review input field (large text area)
                                TextField(
                                  maxLines: 5,
                                  decoration: const InputDecoration(
                                    labelText: 'Write your review...',
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (value) {
                                    // Update review logic
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildQuestionsAndAnswers(dynamic questions, dynamic answers) {
    if (questions is List && answers is Map) {
      return ListView.builder(
        shrinkWrap: true,
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final question = questions[index];
          final answerKey = (index)
              .toString(); // Convert index to string key like "0", "1", etc.
          final answer = answers.containsKey(answerKey)
              ? answers[answerKey]
              : 'No answer provided';

          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            elevation: 2.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Q: $question',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          'A: $answer',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.green, // Text color
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } else {
      return const Center(
          child: Text("Invalid data format for questions or answers"));
    }
  }
}
