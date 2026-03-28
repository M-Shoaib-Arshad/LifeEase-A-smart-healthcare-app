import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      drawer: const SideDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('LifeEase - About placeholder.'),
      ),
    );
  }
}
