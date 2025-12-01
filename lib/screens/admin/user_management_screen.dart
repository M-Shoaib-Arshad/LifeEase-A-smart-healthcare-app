import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String _selectedRole = 'All';
  String _selectedStatus = 'All';

  final List<UserItem> _users = [
    UserItem(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@healthcare.com',
      role: 'Doctor',
      status: 'Active',
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      avatar: 'JD',
    ),
    UserItem(
      id: '2',
      name: 'Jane Smith',
      email: 'jane.smith@healthcare.com',
      role: 'Patient',
      status: 'Active',
      joinDate: DateTime.now().subtract(const Duration(days: 15)),
      avatar: 'JS',
    ),
    UserItem(
      id: '3',
      name: 'Dr. Michael Brown',
      email: 'michael.brown@healthcare.com',
      role: 'Doctor',
      status: 'Inactive',
      joinDate: DateTime.now().subtract(const Duration(days: 60)),
      avatar: 'MB',
    ),
    UserItem(
      id: '4',
      name: 'Sarah Johnson',
      email: 'sarah.johnson@healthcare.com',
      role: 'Admin',
      status: 'Active',
      joinDate: DateTime.now().subtract(const Duration(days: 90)),
      avatar: 'SJ',
    ),
    UserItem(
      id: '5',
      name: 'Emily Davis',
      email: 'emily.davis@healthcare.com',
      role: 'Patient',
      status: 'Pending',
      joinDate: DateTime.now().subtract(const Duration(days: 5)),
      avatar: 'ED',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  List<UserItem> get filteredUsers {
    return _users.where((user) {
      final matchesSearch = user.name
          .toLowerCase()
          .contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesRole = _selectedRole == 'All' || user.role == _selectedRole;
      final matchesStatus =
          _selectedStatus == 'All' || user.status == _selectedStatus;
      return matchesSearch && matchesRole && matchesStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: _showAddUserDialog,
            tooltip: 'Add new user',
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              margin: EdgeInsets.all(isMobile ? 14 : 20),
              padding: EdgeInsets.all(isMobile ? 16 : 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.green[800]!, Colors.green[600]!]
                      : [Colors.green[600]!, Colors.green[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.group,
                      color: Colors.white,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'User Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredUsers.length} users found',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.95),
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: isMobile ? 14 : 20),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: 'Search users by name or email...',
                        prefixIcon: const Icon(Icons.search, size: 22),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(14),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                          fontSize: 13,
                        ),
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              'Doctor',
                              'Patient',
                              'Admin',
                            ]
                                .map((role) {
                              final isSelected = _selectedRole == role;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
                                child: FilterChip(
                                  label: Text(
                                    role,
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
                                      _selectedRole = role;
                                    });
                                  },
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  selectedColor: Colors.green[100],
                                  checkmarkColor: Colors.green[600],
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.green[600]!
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                              );
                            })
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              'All',
                              'Active',
                              'Inactive',
                              'Pending',
                            ]
                                .map((status) {
                              final isSelected = _selectedStatus == status;
                              return Padding(
                                padding: const EdgeInsets.only(right: 6),
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
                                      _selectedStatus = status;
                                    });
                                  },
                                  backgroundColor: isDark
                                      ? Colors.grey[800]
                                      : Colors.grey[100],
                                  selectedColor: Colors.blue[100],
                                  checkmarkColor: Colors.blue[600],
                                  side: BorderSide(
                                    color: isSelected
                                        ? Colors.blue[600]!
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                              );
                            })
                                .toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: filteredUsers.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: isMobile ? 14 : 20,
                  vertical: 8,
                ),
                itemCount: filteredUsers.length,
                itemBuilder: (context, index) {
                  final user = filteredUsers[index];
                  return _buildUserCard(user, isDark, isMobile);
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/admin/dashboard');
          if (index == 1) context.go('/admin/user-management');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildUserCard(UserItem user, bool isDark, bool isMobile) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
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
      child: ListTile(
        contentPadding: EdgeInsets.all(isMobile ? 12 : 14),
        leading: CircleAvatar(
          radius: 24,
          backgroundColor: _getRoleColor(user.role).withOpacity(0.2),
          child: Text(
            user.avatar,
            style: TextStyle(
              color: _getRoleColor(user.role),
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        title: Text(
          user.name,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: isMobile ? 14 : 15,
            color: isDark ? Colors.white : Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getRoleColor(user.role).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _getRoleColor(user.role).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    user.role,
                    style: TextStyle(
                      color: _getRoleColor(user.role),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(user.status).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: _getStatusColor(user.status).withOpacity(0.4),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    user.status,
                    style: TextStyle(
                      color: _getStatusColor(user.status),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleMenuAction(value, user),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 16),
                  SizedBox(width: 8),
                  Text('View', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 16),
                  SizedBox(width: 8),
                  Text('Edit', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'deactivate',
              child: Row(
                children: [
                  Icon(Icons.block, size: 16),
                  SizedBox(width: 8),
                  Text('Deactivate', style: TextStyle(fontSize: 14)),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 16, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Delete',
                      style: TextStyle(color: Colors.red, fontSize: 14)),
                ],
              ),
            ),
          ],
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
            Icons.person_off_outlined,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.grey[400] : Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.person_add),
            label: const Text('Add New User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[600],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'Doctor':
        return Colors.blue;
      case 'Patient':
        return Colors.green;
      case 'Admin':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Active':
        return Colors.green;
      case 'Inactive':
        return Colors.orange;
      case 'Pending':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _handleMenuAction(String action, UserItem user) {
    switch (action) {
      case 'view':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Viewing ${user.name}')),
        );
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editing ${user.name}')),
        );
        break;
      case 'deactivate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Deactivated ${user.name}')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showDeleteConfirmation(UserItem user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _users.removeWhere((u) => u.id == user.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted ${user.name}')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New User'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                labelText: 'Role',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('New user added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class UserItem {
  final String id;
  final String name;
  final String email;
  final String role;
  final String status;
  final DateTime joinDate;
  final String avatar;

  UserItem({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.status,
    required this.joinDate,
    required this.avatar,
  });
}
