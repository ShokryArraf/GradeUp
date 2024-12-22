import 'package:flutter/material.dart';
import 'package:grade_up/emergency/emergency_contacts_view.dart';
import 'package:grade_up/emergency/first_aid_view.dart';
import 'package:grade_up/utilities/build_dashboard_card.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyView extends StatefulWidget {
  const EmergencyView({super.key});

  @override
  State<EmergencyView> createState() => _EmergencyViewState();
}

class _EmergencyViewState extends State<EmergencyView> {
  String selectedLanguage = 'English'; // Default language

  @override
  Widget build(BuildContext context) {
    // Set text direction based on the selected language
    final isHebrew = selectedLanguage == 'Hebrew';
    final textDirection = isHebrew ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isHebrew ? 'מדור חירום' : 'Emergency Section',
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
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: DropdownButton<String>(
                value: selectedLanguage,
                icon: const Icon(Icons.language, color: Colors.black),
                underline: const SizedBox(), // Remove default underline
                dropdownColor: Colors.blue[800],
                items: const [
                  DropdownMenuItem(
                    value: 'English',
                    child: Text(
                      'English',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  DropdownMenuItem(
                    value: 'Hebrew',
                    child: Text(
                      'עברית',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    selectedLanguage = value!;
                  });
                },
              ),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  isHebrew ? 'הוראות חירום' : 'Emergency Instructions',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isHebrew
                      ? '1. גשו למרחב המוגן הקרוב ביותר כשאתם שומעים אזעקה.'
                      : '1. Go to the nearest protected area when you hear the siren.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  isHebrew
                      ? '2. הישארו במרחב המוגן לפחות 10 דקות לאחר תום האזעקה.'
                      : '2. Stay inside for at least 10 minutes after the siren ends.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  isHebrew
                      ? '3. שמרו ערכת חירום עם מים, מזון, פנס ומסמכים חשובים.'
                      : '3. Keep an emergency kit with water, food, flashlight, and important documents.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 8),
                Text(
                  isHebrew
                      ? '4. עקבו אחר עדכונים ממקורות חדשותיים אמינים או אפליקציית פיקוד העורף.'
                      : '4. Follow updates on trusted news sources or the Home Front Command app.',
                  style: const TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 16),
                Text(
                  isHebrew
                      ? 'למידע נוסף, בקרו באתר או באפליקציה של פיקוד העורף.'
                      : 'For more information, visit the Home Front Command website or app.',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      launchEmergencyWebsite();
                    },
                    icon: const Icon(Icons.link),
                    label: Text(
                      isHebrew
                          ? 'בקרו באתר פיקוד העורף'
                          : 'Visit Home Front Command',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade50,
                    ),
                  ),
                ),
                buildDashboardCard(
                  Icons.phone,
                  isHebrew ? 'קשרי חירום' : 'Emergency Contacts',
                  Colors.green,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EmergencyContactsView(),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                buildDashboardCard(
                  Icons.health_and_safety,
                  isHebrew ? 'הוראות עזרה ראשונה' : 'First Aid Instructions',
                  Colors.red,
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FirstAidView(
                          language: selectedLanguage,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void launchEmergencyWebsite() {
    const url = 'https://www.oref.org.il/';
    launchUrl(Uri.parse(url));
  }
}
