import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency Contacts')),
      drawer: const SideDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Add your emergency contacts here.'),
      ),
    );
  }
}
