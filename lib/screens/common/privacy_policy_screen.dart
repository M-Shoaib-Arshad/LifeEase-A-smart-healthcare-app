import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Policy')),
      drawer: const SideDrawer(),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Privacy policy content placeholder.'),
      ),
    );
  }
}
