import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});

  @override
  _SupportScreenState createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  final _feedbackController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadLastFeedback();
  }

  Future<void> _loadLastFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _feedbackController.text = prefs.getString('last_feedback') ?? '';
    });
  }

  Future<void> _saveFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_feedback', _feedbackController.text);
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      drawer: const SideDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Get Support', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            TextField(
              controller: _feedbackController,
              decoration: const InputDecoration(
                labelText: 'Your Feedback or Issue',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: () async {
                if (_feedbackController.text.isNotEmpty) {
                  setState(() => _isLoading = true);
                  await _saveFeedback();
                  setState(() => _isLoading = false);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Feedback submitted')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please enter feedback')),
                  );
                }
              },
              child: const Text('Submit Feedback'),
            ),
            TextButton(
              onPressed: () {
                // Navigate to FAQs or help resources
              },
              child: const Text('View FAQs'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) context.go(userProvider.role == 'patient' ? '/patient/home' : userProvider.role == 'doctor' ? '/doctor/home' : '/admin/dashboard');
          if (index == 1) context.go(userProvider.role == 'patient' ? '/patient/profile' : userProvider.role == 'doctor' ? '/doctor/profile' : '/admin/user-management');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }
}