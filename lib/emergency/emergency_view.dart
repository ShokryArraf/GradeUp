import 'package:flutter/material.dart';
import 'package:grade_up/emergency/emergency_contacts_view.dart';
import 'package:grade_up/emergency/first_aid_view.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyView extends StatelessWidget {
  const EmergencyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Section'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Emergency Instructions',
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 16),
            const Text(
              '1. Go to the nearest protected area when you hear the siren.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '2. Stay inside for at least 10 minutes after the siren ends.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '3. Keep an emergency kit with water, food, flashlight, and important documents.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            const Text(
              '4. Follow updates on trusted news sources or the Home Front Command app.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'For more information, visit the Home Front Command website or app.',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Open Home Front Command website
                  launchEmergencyWebsite();
                },
                icon: const Icon(Icons.link),
                label: const Text('Visit Home Front Command / פיקוד העורף'),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Colors.red, // Use backgroundColor instead of primary
                ),
              ),
            ),
            buildDashboardCard(
                Icons.phone, 'Emergency Contacts/קשרי חירום', Colors.green, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EmergencyContactsView(),
                ),
              );
            }),
            const SizedBox(height: 10),
            buildDashboardCard(Icons.health_and_safety,
                'First Aid Instructions/הוראות עזרה ראשונה', Colors.red, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const FirstAidView(),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void launchEmergencyWebsite() {
    const url = 'https://www.oref.org.il/'; // Official website of פיקוד העורף
    launchUrl(Uri.parse(url));
  }
}
