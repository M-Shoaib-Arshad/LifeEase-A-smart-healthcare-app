import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';

class PatientMessagesScreen extends StatelessWidget {
  const PatientMessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Messages')),
      drawer: const SideDrawer(),
      body: const Center(child: Text('Messages feature coming soon')),
    );
  }
}
