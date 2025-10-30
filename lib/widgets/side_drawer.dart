import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({super.key});

  @override
  State<SideDrawer> createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  final bool _isExpanded = false;

  // Sample user data - in real app, this would come from UserProvider
  final Map<String, dynamic> _userData = {
    'name': 'Dr. Jane Smith',
    'email': 'jane.smith@hospital.com',
    'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
    'specialization': 'Cardiologist',
    'hospital': 'City General Hospital',
    'licenseNumber': 'MD123456',
    'experience': '10 years',
    'rating': 4.8,
    'totalPatients': 1250,
    'isVerified': true,
    'lastLogin': DateTime.now().subtract(const Duration(hours: 2)),
    'notifications': 5,
    'emergencyAlerts': 2,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.3, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<UserProvider>(context, listen: false).logout();
              context.go('/login');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Logout', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.emergency, color: Colors.red[700]),
            const SizedBox(width: 8),
            const Text('Emergency Protocols'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.local_hospital, color: Colors.red[600]),
              title: const Text('Code Blue'),
              subtitle: const Text('Cardiac/Respiratory Arrest'),
              onTap: () {
                Navigator.pop(context);
                // Handle Code Blue
              },
            ),
            ListTile(
              leading: Icon(Icons.warning, color: Colors.orange[600]),
              title: const Text('Code Yellow'),
              subtitle: const Text('Missing Patient'),
              onTap: () {
                Navigator.pop(context);
                // Handle Code Yellow
              },
            ),
            ListTile(
              leading: Icon(Icons.security, color: Colors.purple[600]),
              title: const Text('Code Silver'),
              subtitle: const Text('Security Threat'),
              onTap: () {
                Navigator.pop(context);
                // Handle Code Silver
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String role = userProvider.role;

    return Drawer(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              children: [
                _buildDrawerHeader(role),
                Expanded(
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      _buildQuickStats(role),
                      const SizedBox(height: 8),
                      _buildNavigationSection(role),
                      const SizedBox(height: 8),
                      _buildMedicalSection(role),
                      const SizedBox(height: 8),
                      _buildSystemSection(role),
                      const SizedBox(height: 8),
                      _buildEmergencySection(),
                    ],
                  ),
                ),
                _buildFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(String role) {
    return Container(
      height: 280,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade600,
            Colors.blue.shade800,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 35,
                          backgroundImage: NetworkImage(_userData['profileImage']),
                        ),
                      ),
                      if (_userData['isVerified'])
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.verified,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _userData['name'],
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _userData['specialization'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _userData['hospital'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildHeaderStat('Rating', '${_userData['rating']}⭐'),
                        _buildHeaderStat('Patients', '${_userData['totalPatients']}+'),
                        _buildHeaderStat('Experience', _userData['experience']),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Colors.white.withOpacity(0.8),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Last login: ${_getTimeAgo(_userData['lastLogin'])}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats(String role) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildQuickStatItem(
                  'Notifications',
                  _userData['notifications'].toString(),
                  Icons.notifications,
                  Colors.orange,
                ),
              ),
              Expanded(
                child: _buildQuickStatItem(
                  'Alerts',
                  _userData['emergencyAlerts'].toString(),
                  Icons.warning,
                  Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationSection(String role) {
    return _buildSection(
      'Navigation',
      Icons.navigation,
      Colors.blue,
      [
        _buildDrawerItem(
          Icons.home_rounded,
          'Home',
              () => context.go(role == 'patient' ? '/patient/home' : role == 'doctor' ? '/doctor/home' : '/admin/dashboard'),
        ),
        _buildDrawerItem(
          Icons.person_rounded,
          'Profile',
              () => context.go(role == 'patient' ? '/patient/profile' : role == 'doctor' ? '/doctor/profile' : '/admin/dashboard'),
          badge: _userData['notifications'] > 0 ? _userData['notifications'] : null,
        ),
        if (role == 'doctor') ...[
          _buildDrawerItem(
            Icons.people_rounded,
            'Patients',
                () => context.go('/doctor/patients'),
          ),
          _buildDrawerItem(
            Icons.calendar_today_rounded,
            'Schedule',
                () => context.go('/doctor/schedule'),
          ),
        ],
        if (role == 'patient') ...[
          _buildDrawerItem(
            Icons.calendar_today_rounded,
            'Appointments',
                () => context.go('/patient/appointments'),
          ),
          _buildDrawerItem(
            Icons.medical_services_rounded,
            'Medical Records',
                () => context.go('/patient/medical-records'),
          ),
        ],
      ],
    );
  }

  Widget _buildMedicalSection(String role) {
    return _buildSection(
      'Medical Tools',
      Icons.medical_services,
      Colors.green,
      [
        if (role == 'doctor') ...[
          _buildDrawerItem(
            Icons.video_call_rounded,
            'Telemedicine',
                () => context.go('/doctor/telemedicine'),
          ),
          _buildDrawerItem(
            Icons.medication_rounded,
            'Prescriptions',
                () => context.go('/doctor/prescriptions'),
          ),
          _buildDrawerItem(
            Icons.science_rounded,
            'Lab Results',
                () => context.go('/doctor/lab-results'),
          ),
          _buildDrawerItem(
            Icons.image_rounded,
            'Medical Imaging',
                () => context.go('/doctor/imaging'),
          ),
        ],
        if (role == 'patient') ...[
          _buildDrawerItem(
            Icons.medication_rounded,
            'My Medications',
                () => context.go('/patient/medications'),
          ),
          _buildDrawerItem(
            Icons.favorite_rounded,
            'Vital Signs',
                () => context.go('/patient/vitals'),
          ),
          _buildDrawerItem(
            Icons.chat_rounded,
            'Messages',
                () => context.go('/patient/messages'),
          ),
        ],
        _buildDrawerItem(
          Icons.health_and_safety_rounded,
          'Health Records',
              () => context.go('/health-records'),
        ),
      ],
    );
  }

  Widget _buildSystemSection(String role) {
    return _buildSection(
      'System',
      Icons.settings,
      Colors.purple,
      [
        _buildDrawerItem(
          Icons.settings_rounded,
          'Settings',
              () => context.go('/settings'),
        ),
        _buildDrawerItem(
          Icons.notifications_rounded,
          'Notifications',
              () => context.go('/notifications'),
          badge: _userData['notifications'] > 0 ? _userData['notifications'] : null,
        ),
        _buildDrawerItem(
          Icons.help_rounded,
          'Help & Support',
              () => context.go('/support'),
        ),
        _buildDrawerItem(
          Icons.privacy_tip_rounded,
          'Privacy Policy',
              () => context.go('/privacy'),
        ),
        _buildDrawerItem(
          Icons.info_rounded,
          'About',
              () => context.go('/about'),
        ),
      ],
    );
  }

  Widget _buildEmergencySection() {
    return _buildSection(
      'Emergency',
      Icons.emergency,
      Colors.red,
      [
        _buildDrawerItem(
          Icons.emergency_rounded,
          'Emergency Protocols',
          _showEmergencyDialog,
          textColor: Colors.red[700],
        ),
        _buildDrawerItem(
          Icons.local_hospital_rounded,
          'Emergency Contacts',
              () => context.go('/emergency-contacts'),
          textColor: Colors.red[700],
        ),
        _buildDrawerItem(
          Icons.warning_rounded,
          'Safety Guidelines',
              () => context.go('/safety-guidelines'),
          textColor: Colors.red[700],
        ),
      ],
    );
  }

  Widget _buildSection(String title, IconData icon, Color color, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildDrawerItem(
      IconData icon,
      String title,
      VoidCallback onTap, {
        int? badge,
        Color? textColor,
      }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? Colors.grey[700],
        size: 22,
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: textColor ?? Colors.black87,
              ),
            ),
          ),
          if (badge != null && badge > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red[600],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge > 99 ? '99+' : badge.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      dense: true,
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade200),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.go('/profile-edit');
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit Profile'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.logout, size: 16),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Version 2.1.0 • Build 2024.12.18',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
