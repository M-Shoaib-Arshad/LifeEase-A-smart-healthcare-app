import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class ContentManagementScreen extends StatefulWidget {
  const ContentManagementScreen({super.key});

  @override
  State<ContentManagementScreen> createState() =>
      _ContentManagementScreenState();
}

class _ContentManagementScreenState extends State<ContentManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  String _searchQuery = '';
  String _selectedFilter = 'All';

  final List<ContentItem> _contentItems = [
    ContentItem(
      id: '1',
      title: 'FAQ: How to book an appointment',
      type: 'FAQ',
      status: 'Published',
      lastModified: DateTime.now().subtract(const Duration(days: 2)),
      author: 'Dr. Smith',
      category: 'Appointments',
    ),
    ContentItem(
      id: '2',
      title: 'Announcement: System Maintenance',
      type: 'Announcement',
      status: 'Draft',
      lastModified: DateTime.now().subtract(const Duration(hours: 3)),
      author: 'Admin',
      category: 'System',
    ),
    ContentItem(
      id: '3',
      title: 'Health Tips: Managing Diabetes',
      type: 'Article',
      status: 'Published',
      lastModified: DateTime.now().subtract(const Duration(days: 5)),
      author: 'Dr. Johnson',
      category: 'Health Tips',
    ),
    ContentItem(
      id: '4',
      title: 'COVID-19 Safety Guidelines',
      type: 'Guidelines',
      status: 'Published',
      lastModified: DateTime.now().subtract(const Duration(days: 1)),
      author: 'Health Department',
      category: 'Safety',
    ),
    ContentItem(
      id: '5',
      title: 'Telemedicine Services Info',
      type: 'Service Info',
      status: 'Review',
      lastModified: DateTime.now().subtract(const Duration(hours: 12)),
      author: 'Dr. Williams',
      category: 'Services',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
    _tabController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  List<ContentItem> get filteredContent {
    return _contentItems.where((item) {
      final matchesSearch =
          item.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              item.category.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesFilter =
          _selectedFilter == 'All' || item.type == _selectedFilter;
      return matchesSearch && matchesFilter;
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
          'Content Management',
          style: TextStyle(fontWeight: FontWeight.w600, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[800] : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Content refreshed')),
              );
            },
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
                      ? [Colors.purple[800]!, Colors.purple[600]!]
                      : [Colors.purple[600]!, Colors.purple[400]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.25),
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
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.content_paste,
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
                          'Content Management',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: isMobile ? 18 : 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${filteredContent.length} items available',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.95),
                            fontSize: isMobile ? 12 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FloatingActionButton.small(
                    onPressed: _showAddContentDialog,
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.purple[600],
                    elevation: 4,
                    child: const Icon(Icons.add, size: 22),
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
                          color: Colors.black.withValues(alpha: 0.08),
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
                        hintText: 'Search content...',
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
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        'All',
                        'FAQ',
                        'Announcement',
                        'Article',
                        'Guidelines',
                        'Service Info'
                      ].map((filter) {
                        final isSelected = _selectedFilter == filter;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(
                              filter,
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
                                _selectedFilter = filter;
                              });
                            },
                            backgroundColor:
                                isDark ? Colors.grey[800] : Colors.grey[100],
                            selectedColor: Colors.purple[100],
                            checkmarkColor: Colors.purple[600],
                            side: BorderSide(
                              color: isSelected
                                  ? Colors.purple[600]!
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
            Expanded(
              child: filteredContent.isEmpty
                  ? _buildEmptyState(isDark)
                  : ListView.builder(
                      padding: EdgeInsets.symmetric(
                        horizontal: isMobile ? 14 : 20,
                        vertical: 8,
                      ),
                      itemCount: filteredContent.length,
                      itemBuilder: (context, index) {
                        final item = filteredContent[index];
                        return _buildContentCard(item, isDark, isMobile);
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

  Widget _buildContentCard(ContentItem item, bool isDark, bool isMobile) {
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
        border: Border.all(
          color: (isDark ? Colors.grey[700] : Colors.grey[100])!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.all(isMobile ? 12 : 16),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _getTypeColor(item.type).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getTypeIcon(item.type),
                color: _getTypeColor(item.type),
                size: 22,
              ),
            ),
            title: Text(
              item.title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: isMobile ? 14 : 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildStatusChip(item.status, isDark),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          item.type,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'By ${item.author} • ${_formatDate(item.lastModified)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
            trailing: PopupMenuButton<String>(
              onSelected: (value) => _handleMenuAction(value, item),
              itemBuilder: (context) => [
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
                  value: 'duplicate',
                  child: Row(
                    children: [
                      Icon(Icons.copy, size: 16),
                      SizedBox(width: 8),
                      Text('Duplicate', style: TextStyle(fontSize: 14)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'archive',
                  child: Row(
                    children: [
                      Icon(Icons.archive, size: 16),
                      SizedBox(width: 8),
                      Text('Archive', style: TextStyle(fontSize: 14)),
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
        ],
      ),
    );
  }

  Widget _buildStatusChip(String status, bool isDark) {
    Color color;
    switch (status) {
      case 'Published':
        color = Colors.green;
        break;
      case 'Draft':
        color = Colors.orange;
        break;
      case 'Review':
        color = Colors.blue;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.4), width: 1),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
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
            Icons.content_paste_off,
            size: 64,
            color: isDark ? Colors.grey[600] : Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No content found',
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
            onPressed: _showAddContentDialog,
            icon: const Icon(Icons.add),
            label: const Text('Add New Content'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple[600],
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

  Color _getTypeColor(String type) {
    switch (type) {
      case 'FAQ':
        return Colors.blue;
      case 'Announcement':
        return Colors.orange;
      case 'Article':
        return Colors.green;
      case 'Guidelines':
        return Colors.red;
      case 'Service Info':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(String type) {
    switch (type) {
      case 'FAQ':
        return Icons.help_outline;
      case 'Announcement':
        return Icons.campaign;
      case 'Article':
        return Icons.article;
      case 'Guidelines':
        return Icons.rule;
      case 'Service Info':
        return Icons.info_outline;
      default:
        return Icons.description;
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

  void _handleMenuAction(String action, ContentItem item) {
    switch (action) {
      case 'edit':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Editing "${item.title}"')),
        );
        break;
      case 'duplicate':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Duplicated "${item.title}"')),
        );
        break;
      case 'archive':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archived "${item.title}"')),
        );
        break;
      case 'delete':
        _showDeleteConfirmation(item);
        break;
    }
  }

  void _showDeleteConfirmation(ContentItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Content'),
        content: Text('Are you sure you want to delete "${item.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _contentItems.removeWhere((content) => content.id == item.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deleted "${item.title}"')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showAddContentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New Content'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Content Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Content Type',
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
                const SnackBar(content: Text('New content added successfully')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class ContentItem {
  final String id;
  final String title;
  final String type;
  final String status;
  final DateTime lastModified;
  final String author;
  final String category;

  ContentItem({
    required this.id,
    required this.title,
    required this.type,
    required this.status,
    required this.lastModified,
    required this.author,
    required this.category,
  });
}
