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
      {'name': 'פיקוד העורף', 'number': '104'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Contacts/קשרי חירום'),
      ),
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
