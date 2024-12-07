import 'package:flutter/material.dart';
import 'package:grade_up/constants/emergency_constants.dart';

class FirstAidView extends StatelessWidget {
  const FirstAidView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('First Aid Instructions/הוראות עזרה ראשונה'),
      ),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CPR Instructions (English):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(EmergencyInstructions.cprEnglish),
            SizedBox(height: 20),
            Text('CPR Instructions (Hebrew):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(EmergencyInstructions.cprHebrew),
            SizedBox(height: 20),
            Text('Burns Instructions (English):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(EmergencyInstructions.burnsEnglish),
            SizedBox(height: 20),
            Text('Burns Instructions (Hebrew):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(EmergencyInstructions.burnsHebrew),
            SizedBox(height: 20),
            Text('Fracture Instructions (English):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(EmergencyInstructions.fracturesEnglish),
            SizedBox(height: 20),
            Text('Fracture Instructions (Hebrew):',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text(EmergencyInstructions.fracturesHebrew),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
