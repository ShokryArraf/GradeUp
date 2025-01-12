import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:grade_up/utilities/build_questions_answers.dart';
import 'package:grade_up/utilities/format_date.dart';
import 'package:grade_up/utilities/open_file.dart';

class SubmittedAssignmentsList extends StatefulWidget {
  final String school;
  final String grade;
  final String lesson;
  final String teachername;

  const SubmittedAssignmentsList({
    super.key,
    required this.school,
    required this.grade,
    required this.lesson,
    required this.teachername,
  });

  @override
  SubmittedAssignmentsListState createState() =>
      SubmittedAssignmentsListState();
}

class SubmittedAssignmentsListState extends State<SubmittedAssignmentsList> {
  // Controllers for score and review inputs
  final TextEditingController scoreController = TextEditingController();
  final TextEditingController reviewController = TextEditingController();
  bool isEditing = false;
  String? editingAssignmentId;

  @override
  void dispose() {
    scoreController.dispose();
    reviewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80, // Set this height
        title: Text(
            'מטלות מוגשות \n ${widget.lesson} - כיתה ${widget.grade}'),
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
            .doc(widget.school)
            .collection('grades')
            .doc(widget.grade)
            .collection('students')
            .where('enrolledLessons', arrayContains: widget.lesson)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final students = snapshot.data!.docs;

          if (students.isEmpty) {
            return const Center(
              child: Text(
                'אין תלמידים עבור הכיתה והשיעור הזה',
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
                    .doc(widget.school)
                    .collection('grades')
                    .doc(widget.grade)
                    .collection('students')
                    .doc(student.id)
                    .collection('assignmentsToDo')
                    .where('status', isEqualTo: 'submitted')
                    .where('lesson', isEqualTo: widget.lesson)
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
                          'תלמיד: ${student['name']}',
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: const Text(
                          'עדיין אין הגשות',
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
                        'תלמיד: ${student['name']}',
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
                                  'מטלה: ${assignment['title']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                Text(
                                  'מועד הנשה: ${assignment['submissionDate'] != null ? (assignment['submissionDate'] as Timestamp).toDate().toString() : 'לא ידוע'}',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 8.0),
                                if (assignment['dueDate'] != null) ...[
                                  Text(
                                    'מועד אחרון להגשה: ${formatDueDate(assignment['dueDate'])}',
                                    style: const TextStyle(color: Colors.grey),
                                  ),
                                ] else ...[
                                  const Text('מועד אחרון להגשה: N/A',
                                      style: TextStyle(color: Colors.grey)),
                                ],
                                const SizedBox(height: 8.0),
                                if (assignment['uploadedFileUrl'] != null) ...[
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: ElevatedButton(
                                      onPressed: () => openFile(
                                          assignment['uploadedFileUrl']),
                                      child: const Text('פתח קובץ מצורף'),
                                    ),
                                  ),
                                ] else ...[
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber_outlined,
                                          color: Colors.red,
                                        ),
                                        SizedBox(width: 8.0),
                                        Text('אין קובץ מצורף'),
                                      ],
                                    ),
                                  ),
                                ],
                                if (assignment['questions'] != null &&
                                    assignment['answers'] != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: buildQuestionsAndAnswers(
                                      assignment['questions'] as List<dynamic>,
                                      assignment['answers']
                                          as Map<String, dynamic>,
                                    ),
                                  ),
                                const SizedBox(height: 8.0),
                                if (assignment['additionalInput'] != null)
                                  Container(
                                    padding: const EdgeInsets.all(12.0),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: BorderRadius.circular(8.0),
                                      border: Border.all(
                                        color: Colors.grey[400]!,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Text(
                                      'הערות: ${assignment['additionalInput']}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (assignment['score'] != null &&
                                        assignment['review'] != null &&
                                        assignment['teacherReviewed'] != null)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(
                                            height: 10,
                                          ),
                                          Text(
                                            'ניקוד נוכחי: ${assignment['score']}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'בדיקה נוכחית: ${assignment['review']}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          Text(
                                            'נבדק ע"י : ${assignment['teacherReviewed']}',
                                            style:
                                                const TextStyle(fontSize: 16),
                                          ),
                                          const SizedBox(height: 15),
                                          ElevatedButton(
                                            onPressed: () {
                                              scoreController.clear();
                                              reviewController.clear();
                                              setState(() {
                                                editingAssignmentId = assignment
                                                    .id; // Only this assignment is being edited
                                              });
                                            },
                                            child: const Text(
                                              'עריכת ניקוד ובדיקה',
                                            ),
                                          ),
                                        ],
                                      ),
                                    if (editingAssignmentId == assignment.id ||
                                        assignment['score'] == null ||
                                        assignment['review'] == null)
                                      Column(
                                        children: [
                                          const SizedBox(height: 8.0),
                                          const Text(
                                            'ניקוד ובדיקה:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: scoreController,
                                            decoration: const InputDecoration(
                                              labelText: 'הכנס ניקוד',
                                              border: OutlineInputBorder(),
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                      vertical: 10.0,
                                                      horizontal: 20.0),
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                          const SizedBox(height: 15),
                                          TextField(
                                            controller: reviewController,
                                            maxLines: 5,
                                            decoration: const InputDecoration(
                                              labelText: 'כתוב הערות בדיקה',
                                              border: OutlineInputBorder(),
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          ElevatedButton(
                                            onPressed: () async {
                                              int? score = int.tryParse(
                                                  scoreController.text);

                                              if (score == null ||
                                                  score < 0 ||
                                                  score > 100) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'ניקוד לא תקין. יש לכתוב ערך בין 0 ל-100')),
                                                );
                                                return;
                                              }

                                              String review =
                                                  reviewController.text;

                                              try {
                                                await FirebaseFirestore.instance
                                                    .collection('schools')
                                                    .doc(widget.school)
                                                    .collection('grades')
                                                    .doc(widget.grade)
                                                    .collection('students')
                                                    .doc(student.id)
                                                    .collection(
                                                        'assignmentsToDo')
                                                    .doc(assignment.id)
                                                    .update({
                                                  'score': score,
                                                  'review': review,
                                                  'teacherReviewed':
                                                      widget.teachername,
                                                });

                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'ניקוד ובדיקה הוגשו בהצלחה')),
                                                );
                                                scoreController.clear();
                                                reviewController.clear();
                                                setState(() {
                                                  editingAssignmentId =
                                                      null; // Stop editing
                                                });
                                              } catch (_) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text('שגיאה')),
                                                );
                                              }
                                            },
                                            child: const Text(
                                                'ניקוד ובידקה הוגשו בהצלחה'),
                                          ),
                                        ],
                                      ),
                                  ],
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
}
