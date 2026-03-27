import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../utils/app_colors.dart';

class PatientsListScreen extends StatefulWidget {
  const PatientsListScreen({super.key});

  @override
  State<PatientsListScreen> createState() => _PatientsListScreenState();
}

class _PatientsListScreenState extends State<PatientsListScreen> {
  String _searchQuery = '';
  String _filterStatus = 'All';

  // Sample patient data - in production, this would come from a service/provider
  final List<Map<String, dynamic>> _patients = [
    {
      'id': 'P001',
      'name': 'John Smith',
      'age': 45,
      'gender': 'Male',
      'lastVisit': DateTime.now().subtract(const Duration(days: 3)),
      'condition': 'Hypertension',
      'status': 'Active',
      'profileImage': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'id': 'P002',
      'name': 'Sarah Johnson',
      'age': 32,
      'gender': 'Female',
      'lastVisit': DateTime.now().subtract(const Duration(days: 7)),
      'condition': 'Diabetes Type 2',
      'status': 'Active',
      'profileImage': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'id': 'P003',
      'name': 'Michael Brown',
      'age': 58,
      'gender': 'Male',
      'lastVisit': DateTime.now().subtract(const Duration(days: 14)),
      'condition': 'Cardiac Arrhythmia',
      'status': 'Follow-up',
      'profileImage': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'id': 'P004',
      'name': 'Emily Davis',
      'age': 28,
      'gender': 'Female',
      'lastVisit': DateTime.now().subtract(const Duration(days: 1)),
      'condition': 'Asthma',
      'status': 'Active',
      'profileImage': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'id': 'P005',
      'name': 'Robert Wilson',
      'age': 67,
      'gender': 'Male',
      'lastVisit': DateTime.now().subtract(const Duration(days: 30)),
      'condition': 'Osteoarthritis',
      'status': 'Inactive',
      'profileImage': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
  ];

  List<Map<String, dynamic>> get filteredPatients {
    return _patients.where((patient) {
      final matchesSearch = patient['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          patient['condition']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _filterStatus == 'All' || patient['status'] == _filterStatus;
      return matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'My Patients',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add new patient')),
              );
            },
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: Column(
        children: [
          // Header card
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.textLight.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.people,
                    color: AppColors.textLight,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Patient Management',
                        style: TextStyle(
                          color: AppColors.textLight,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${filteredPatients.length} patients',
                        style: TextStyle(
                          color: AppColors.textLight.withValues(alpha: 0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search and filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // Search bar
                Container(
                  decoration: BoxDecoration(
                    color: isDark ? Colors.grey[800] : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search patients...',
                      prefixIcon: const Icon(Icons.search, size: 22),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(14),
                      hintStyle: TextStyle(
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black87,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: ['All', 'Active', 'Follow-up', 'Inactive']
                        .map((status) {
                      final isSelected = _filterStatus == status;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          label: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                            ),
                          ),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              _filterStatus = status;
                            });
                          },
                          backgroundColor:
                              isDark ? Colors.grey[800] : Colors.grey[100],
                          selectedColor: AppColors.primaryLight,
                          checkmarkColor: AppColors.primary,
                          side: BorderSide(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.transparent,
                            width: 1.5,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Patients list
          Expanded(
            child: filteredPatients.isEmpty
                ? _buildEmptyState(isDark)
                : ListView.builder(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: filteredPatients.length,
                    itemBuilder: (context, index) {
                      final patient = filteredPatients[index];
                      return _buildPatientCard(patient, isDark);
                    },
                  ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/doctor/home');
          if (index == 1) context.go('/doctor/profile');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildPatientCard(Map<String, dynamic> patient, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 28,
          backgroundImage: NetworkImage(patient['profileImage']),
        ),
        title: Text(
          patient['name'],
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${patient['age']} years • ${patient['gender']}',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              patient['condition'],
              style: TextStyle(
                fontSize: 13,
                color: isDark ? Colors.grey[300] : Colors.grey[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _buildStatusChip(patient['status'], isDark),
                const SizedBox(width: 8),
                Text(
                  'Last visit: ${_formatDate(patient['lastVisit'])}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.grey[500] : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.arrow_forward_ios,
            size: 18,
            color: isDark ? Colors.grey[400] : Colors.grey[600],
          ),
          onPressed: () {
            context.push('/doctor/patient-details');
          },
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color color;
    switch (status) {
      case 'Active':
        color = AppColors.accentMint;
        break;
      case 'Follow-up':
        color = AppColors.warning;
        break;
      case 'Inactive':
        color = AppColors.textSecondary;
        break;
      default:
        color = AppColors.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No patients found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return 'Today';
    }
  }
}
