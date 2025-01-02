import 'package:flutter/material.dart';

Widget buildQuestionsAndAnswers(dynamic questions, dynamic answers) {
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        question ?? 'No question text available',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      const SizedBox(height: 8.0),
                      Text(
                        'Answer: $answer',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.green),
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
    return const Center(child: Text('Invalid question or answer data'));
  }
}
