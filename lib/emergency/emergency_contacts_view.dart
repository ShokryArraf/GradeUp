import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyContactsView extends StatelessWidget {
  const EmergencyContactsView({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> emergencyContacts = [
      {'name': 'Police/משטרה', 'number': '100'},
      {'name': 'Ambulance/אמבולנס', 'number': '101'},
      {'name': 'Fire Department/כיבוי אש', 'number': '102'},
      {'name': 'Home Front Command/פיקוד העורף', 'number': '104'},
    ];

    return Scaffold(
      appBar: AppBar(
          toolbarHeight: 80,
          title: const Text('Emergency Contacts\n/קשרי חירום'),
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
      body: ListView.builder(
        itemCount: emergencyContacts.length,
        itemBuilder: (context, index) {
          final contact = emergencyContacts[index];
          return ListTile(
            leading: const Icon(Icons.phone, color: Colors.green),
            title: Text(contact['name']!),
            subtitle: Text(contact['number']!),
            trailing: const Icon(Icons.call, color: Colors.blue),
            onTap: () {
              final Uri telUri = Uri(
                scheme: 'tel',
                path: contact['number'],
              );
              launchUrl(telUri);
            },
          );
        },
      ),
    );
  }
}
