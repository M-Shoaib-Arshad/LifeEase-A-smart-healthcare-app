import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';

class SafetyGuidelinesScreen extends StatelessWidget {
  const SafetyGuidelinesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Safety Guidelines')),
      drawer: const SideDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('General safety guidelines placeholder.'),
      ),
    );
  }
}
