import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
      ),
      drawer: const SideDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: EdgeInsets.all(isMobile ? 16.0 : 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(isMobile ? 20 : 24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [Colors.blue[800]!, Colors.blue[600]!]
                          : [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.25),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.admin_panel_settings,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Welcome Back!',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: isMobile ? 14 : 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Admin Dashboard',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 24 : 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Manage your healthcare platform with ease',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.95),
                          fontSize: isMobile ? 12 : 14,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  'Quick Overview',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 14),
                isMobile
                    ? Column(
                        children: [
                          _buildStatCard(
                            icon: Icons.people,
                            title: 'Total Users',
                            value: '1,234',
                            color: Colors.green,
                            isDark: isDark,
                          ),
                          const SizedBox(height: 12),
                          _buildStatCard(
                            icon: Icons.article,
                            title: 'Content Items',
                            value: '89',
                            color: Colors.orange,
                            isDark: isDark,
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.people,
                              title: 'Total Users',
                              value: '1,234',
                              color: Colors.green,
                              isDark: isDark,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: _buildStatCard(
                              icon: Icons.article,
                              title: 'Content Items',
                              value: '89',
                              color: Colors.orange,
                              isDark: isDark,
                            ),
                          ),
                        ],
                      ),
                const SizedBox(height: 28),
                Text(
                  'Management Tools',
                  style: TextStyle(
                    fontSize: isMobile ? 18 : 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 14),
                _buildManagementCard(
                  context: context,
                  icon: Icons.group,
                  title: 'User Management',
                  subtitle: 'Manage user accounts, roles, and permissions',
                  color: Colors.blue,
                  onTap: () => context.push('/admin/user-management'),
                  isDark: isDark,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 12),
                _buildManagementCard(
                  context: context,
                  icon: Icons.content_paste,
                  title: 'Content Management',
                  subtitle: 'Manage articles, resources, and medical content',
                  color: Colors.purple,
                  onTap: () => context.push('/admin/content-management'),
                  isDark: isDark,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 12),
                _buildManagementCard(
                  context: context,
                  icon: Icons.analytics,
                  title: 'Analytics & Reports',
                  subtitle: 'View platform statistics and generate reports',
                  color: Colors.teal,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Analytics feature coming soon!')),
                    );
                  },
                  isDark: isDark,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 12),
                _buildManagementCard(
                  context: context,
                  icon: Icons.settings,
                  title: 'System Settings',
                  subtitle: 'Configure system preferences and security',
                  color: Colors.red,
                  onTap: () => context.push('/settings'),
                  isDark: isDark,
                  isMobile: isMobile,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/admin/dashboard');
          if (index == 1) context.go('/admin/user-management');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: (isDark ? Colors.grey[700] : Colors.grey[100])!,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildManagementCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
    required bool isDark,
    required bool isMobile,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: (isDark ? Colors.grey[700] : Colors.grey[100])!,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          highlightColor: color.withOpacity(0.05),
          splashColor: color.withOpacity(0.1),
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 14 : 18),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: isMobile ? 15 : 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : Colors.black87,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          height: 1.4,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                  color: isDark ? Colors.grey[500] : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
