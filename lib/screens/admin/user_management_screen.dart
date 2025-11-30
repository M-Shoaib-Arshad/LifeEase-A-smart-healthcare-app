import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  _UserManagementScreenState createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen>
    with TickerProviderStateMixin {
  String _lastAction = '';
  String _userFilter = 'all';
  String _searchQuery = '';
  bool _isLoading = false;
  String _sortBy = 'name';
  bool _isAscending = true;

  late AnimationController _fadeController;
  late AnimationController _listController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _listAnimation;

  // Sample user data - replace with your actual data source
  final List<UserData> _users = [
    UserData(
      id: '1',
      name: 'John Doe',
      email: 'john.doe@email.com',
      role: 'patient',
      status: 'active',
      lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
      joinDate: DateTime.now().subtract(const Duration(days: 30)),
      phone: '+1 234 567 8900',
      avatar: null,
    ),
    UserData(
      id: '2',
      name: 'Dr. Jane Smith',
      email: 'jane.smith@hospital.com',
      role: 'doctor',
      status: 'active',
      lastLogin: DateTime.now().subtract(const Duration(minutes: 15)),
      joinDate: DateTime.now().subtract(const Duration(days: 120)),
      phone: '+1 234 567 8901',
      avatar: null,
    ),
    UserData(
      id: '3',
      name: 'Michael Johnson',
      email: 'michael.j@email.com',
      role: 'patient',
      status: 'inactive',
      lastLogin: DateTime.now().subtract(const Duration(days: 5)),
      joinDate: DateTime.now().subtract(const Duration(days: 60)),
      phone: '+1 234 567 8902',
      avatar: null,
    ),
    UserData(
      id: '4',
      name: 'Dr. Sarah Wilson',
      email: 'sarah.wilson@clinic.com',
      role: 'doctor',
      status: 'active',
      lastLogin: DateTime.now().subtract(const Duration(hours: 1)),
      joinDate: DateTime.now().subtract(const Duration(days: 90)),
      phone: '+1 234 567 8903',
      avatar: null,
    ),
    UserData(
      id: '5',
      name: 'Admin User',
      email: 'admin@healthcare.com',
      role: 'admin',
      status: 'active',
      lastLogin: DateTime.now().subtract(const Duration(minutes: 30)),
      joinDate: DateTime.now().subtract(const Duration(days: 365)),
      phone: '+1 234 567 8904',
      avatar: null,
    ),
    UserData(
      id: '6',
      name: 'Emily Davis',
      email: 'emily.davis@email.com',
      role: 'patient',
      status: 'pending',
      lastLogin: null,
      joinDate: DateTime.now().subtract(const Duration(days: 1)),
      phone: '+1 234 567 8905',
      avatar: null,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _listAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _listController, curve: Curves.easeOutCubic),
    );

    _loadPreferences();
    _fadeController.forward();
    _listController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _listController.dispose();
    super.dispose();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _lastAction = prefs.getString('last_action') ?? '';
      _userFilter = prefs.getString('user_filter') ?? 'all';
      if (_lastAction.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Last action: $_lastAction'),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
          );
        });
      }
    });
  }

  Future<void> _saveAction(String action) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_action', action);
    setState(() {
      _lastAction = action;
    });
  }

  Future<void> _saveFilter(String filter) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_filter', filter);
    setState(() {
      _userFilter = filter;
    });
  }

  List<UserData> get filteredAndSortedUsers {
    List<UserData> filtered = _users.where((user) {
      final matchesFilter = _userFilter == 'all' || user.role == _userFilter;
      final matchesSearch = user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    filtered.sort((a, b) {
      int comparison;
      switch (_sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'role':
          comparison = a.role.compareTo(b.role);
          break;
        case 'status':
          comparison = a.status.compareTo(b.status);
          break;
        case 'lastLogin':
          comparison = (a.lastLogin ?? DateTime(1970)).compareTo(b.lastLogin ?? DateTime(1970));
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return _isAscending ? comparison : -comparison;
    });

    return filtered;
  }

  Map<String, int> get userStats {
    return {
      'total': _users.length,
      'patients': _users.where((u) => u.role == 'patient').length,
      'doctors': _users.where((u) => u.role == 'doctor').length,
      'admins': _users.where((u) => u.role == 'admin').length,
      'active': _users.where((u) => u.status == 'active').length,
      'inactive': _users.where((u) => u.status == 'inactive').length,
      'pending': _users.where((u) => u.status == 'pending').length,
    };
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final stats = userStats;
    final filteredUsers = filteredAndSortedUsers;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'User Management',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isAscending ? Icons.arrow_upward : Icons.arrow_downward),
            onPressed: () {
              setState(() {
                _isAscending = !_isAscending;
              });
            },
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'name', child: Text('Sort by Name')),
              const PopupMenuItem(value: 'role', child: Text('Sort by Role')),
              const PopupMenuItem(value: 'status', child: Text('Sort by Status')),
              const PopupMenuItem(value: 'lastLogin', child: Text('Sort by Last Login')),
            ],
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Column(
          children: [
            // Header Section with Stats
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [Colors.teal[800]!, Colors.teal[600]!]
                      : [Colors.teal[600]!, Colors.teal[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 10,
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
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.group,
                          color: Colors.white,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'User Management',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${filteredUsers.length} of ${stats['total']} users shown',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FloatingActionButton.small(
                        onPressed: _showAddUserDialog,
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.teal[600],
                        child: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Stats Row
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatItem('Patients', stats['patients']!, Colors.blue),
                      ),
                      Expanded(
                        child: _buildStatItem('Doctors', stats['doctors']!, Colors.green),
                      ),
                      Expanded(
                        child: _buildStatItem('Admins', stats['admins']!, Colors.orange),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search and Filter Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
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
                        hintText: 'Search users by name or email...',
                        prefixIcon: const Icon(Icons.search),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        hintStyle: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Filter Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.grey[800] : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Filter Users',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(16),
                        prefixIcon: Icon(Icons.filter_list),
                      ),
                      value: _userFilter,
                      items: const [
                        DropdownMenuItem(value: 'all', child: Text('All Users')),
                        DropdownMenuItem(value: 'patient', child: Text('Patients')),
                        DropdownMenuItem(value: 'doctor', child: Text('Doctors')),
                        DropdownMenuItem(value: 'admin', child: Text('Admins')),
                      ],
                      onChanged: (value) async {
                        if (value != null) {
                          setState(() => _isLoading = true);
                          await _saveFilter(value);
                          setState(() => _isLoading = false);
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // User List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : filteredUsers.isEmpty
                  ? _buildEmptyState(isDark)
                  : FadeTransition(
                opacity: _listAnimation,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return _buildUserCard(user, isDark);
                  },
                ),
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
          if (index == 2) context.go('/admin/content-management');
          if (index == 3) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildStatItem(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(UserData user, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: _getRoleColor(user.role).withOpacity(0.1),
              child: Text(
                user.name.split(' ').map((name) => name[0]).take(2).join().toUpperCase(),
                style: TextStyle(
                  color: _getRoleColor(user.role),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    user.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                ),
                _buildStatusChip(user.status, isDark),
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getRoleColor(user.role).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        user.role.toUpperCase(),
                        style: TextStyle(
                          color: _getRoleColor(user.role),
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      user.lastLogin != null
                          ? 'Last seen ${_formatDate(user.lastLogin!)}'
                          : 'Never logged in',
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.grey[500] : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleUserAction(value, user),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.visibility, size: 16),
                      SizedBox(width: 8),
                      Text('View Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 16),
                      SizedBox(width: 8),
                      Text('Edit'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'message',
                  child: Row(
                    children: [
                      Icon(Icons.message, size: 16),
                      SizedBox(width: 8),
                      Text('Send Message'),
                    ],
                  ),
                ),
                if (user.status == 'active')
                  const PopupMenuItem(
                    value: 'suspend',
                    child: Row(
                      children: [
                        Icon(Icons.block, size: 16, color: Colors.orange),
                        SizedBox(width: 8),
                        Text('Suspend', style: TextStyle(color: Colors.orange)),
                      ],
                    ),
                  ),
                if (user.status == 'inactive')
                  const PopupMenuItem(
                    value: 'activate',
                    child: Row(
                      children: [
                        Icon(Icons.check_circle, size: 16, color: Colors.green),
                        SizedBox(width: 8),
                        Text('Activate', style: TextStyle(color: Colors.green)),
                      ],
                    ),
                  ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, size: 16, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Delete', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color color;
    IconData icon;
    switch (status) {
      case 'active':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'inactive':
        color = Colors.red;
        icon = Icons.cancel;
        break;
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      default:
        color = Colors.grey;
        icon = Icons.help;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
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
              color: isDark ? Colors.grey[500] : Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showAddUserDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add New User'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal[600],
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'patient':
        return Colors.blue;
      case 'doctor':
        return Colors.green;
      case 'admin':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  void _handleUserAction(String action, UserData user) async {
    setState(() => _isLoading = true);
    await _saveAction(action);
    setState(() => _isLoading = false);

    switch (action) {
      case 'view':
        _showUserProfile(user);
        break;
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Editing ${user.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'message':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sending message to ${user.name}'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'suspend':
      case 'activate':
        setState(() {
          user.status = action == 'suspend' ? 'inactive' : 'active';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${user.name} has been ${action}d'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(user);
        break;
    }
  }

  void _showUserProfile(UserData user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${user.name} Profile'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${user.email}'),
            Text('Phone: ${user.phone}'),
            Text('Role: ${user.role.toUpperCase()}'),
            Text('Status: ${user.status.toUpperCase()}'),
            Text('Joined: ${user.joinDate.toString().split(' ')[0]}'),
            if (user.lastLogin != null)
              Text('Last Login: ${user.lastLogin.toString()}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(UserData user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
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
                SnackBar(
                  content: Text('${user.name} has been deleted'),
                  behavior: SnackBarBehavior.floating,
                ),
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
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email Address',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Phone Number',
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
            onPressed: () async {
              Navigator.pop(context);
              setState(() => _isLoading = true);
              await _saveAction('add');
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('New user added successfully'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Add User'),
          ),
        ],
      ),
    );
  }
}

class UserData {
  final String id;
  final String name;
  final String email;
  String status;
  final String role;
  final DateTime? lastLogin;
  final DateTime joinDate;
  final String phone;
  final String? avatar;

  UserData({
    required this.id,
    required this.name,
    required this.email,
    required this.status,
    required this.role,
    this.lastLogin,
    required this.joinDate,
    required this.phone,
    this.avatar,
  });
}