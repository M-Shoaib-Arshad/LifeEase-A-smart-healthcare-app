import 'package:flutter/material.dart';
import '../../widgets/side_drawer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      drawer: const SideDrawer(),
      body: const Center(child: Text('Notifications coming soon')),
    );
  }
}
