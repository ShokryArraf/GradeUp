import 'package:flutter/material.dart';
import 'package:grade_up/constants/emergency_constants.dart';

class FirstAidView extends StatelessWidget {
  final String language;

  const FirstAidView({super.key, required this.language});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            language == 'English'
                ? 'First Aid Instructions'
                : 'הוראות עזרה ראשונה',
          ),
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
      body: Directionality(
        textDirection:
            language == 'English' ? TextDirection.ltr : TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                language == 'English' ? 'CPR Instructions:' : 'הוראות החייאה:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language == 'English'
                    ? EmergencyInstructions.cprEnglish
                    : EmergencyInstructions.cprHebrew,
              ),
              const SizedBox(height: 20),
              Text(
                language == 'English'
                    ? 'Burns Instructions:'
                    : 'הוראות לטיפול בכוויות:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language == 'English'
                    ? EmergencyInstructions.burnsEnglish
                    : EmergencyInstructions.burnsHebrew,
              ),
              const SizedBox(height: 20),
              Text(
                language == 'English'
                    ? 'Fracture Instructions:'
                    : 'הוראות לטיפול בשברים:',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                language == 'English'
                    ? EmergencyInstructions.fracturesEnglish
                    : EmergencyInstructions.fracturesHebrew,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
