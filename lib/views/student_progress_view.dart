import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class StudentProgressView extends StatelessWidget {
  const StudentProgressView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Student Progress"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream:
            FirebaseFirestore.instance.collection('userprogress').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No student progress found.'));
          }

          return ListView(
            children: snapshot.data!.docs.map((doc) {
              final data = doc.data() as Map<String, dynamic>;
              return ListTile(
                title: Text("Student ID: ${doc.id}"),
                subtitle: Text(
                  "Level: ${data['currentLesson']}\n"
                  "Points: ${data['points']}\n"
                  "Correct Answers: ${data['currentQuestionID']}",
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}
