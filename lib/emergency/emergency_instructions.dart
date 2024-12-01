import 'package:flutter/material.dart';

class EmergencyInstruction extends StatelessWidget {
  const EmergencyInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('מדור חירום'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'הנחיות לשעת חירום',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
              textAlign: TextAlign.right, // Align text to the right for Hebrew
            ),
            SizedBox(height: 16),
            Text(
              '1. יש להגיע למרחב מוגן קרוב בעת שמיעת אזעקה.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 8),
            Text(
              '2. יש להישאר בתוך המרחב המוגן לפחות 10 דקות לאחר תום האזעקה.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 8),
            Text(
              '3. החזיקו ערכת חירום הכוללת מים, מזון, פנס ומסמכים חשובים.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 8),
            Text(
              '4. עקבו אחר עדכונים במקורות חדשות אמינים או באפליקציית פיקוד העורף.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
            SizedBox(height: 16),
            Text(
              'למידע נוסף, בקרו באתר או באפליקציה של פיקוד העורף.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.right,
            ),
          ],
        ),
      ),
    );
  }
}
