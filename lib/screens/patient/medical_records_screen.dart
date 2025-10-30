import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class MedicalRecordsScreen extends StatefulWidget {
  const MedicalRecordsScreen({super.key});

  @override
  State<MedicalRecordsScreen> createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  DateTimeRange? _selectedDateRange;
  bool _isSearching = false;

  final List<String> _categories = [
    'All',
    'Lab Results',
    'Prescriptions',
    'Imaging',
    'Consultations',
    'Vaccinations',
    'Surgery',
    'Insurance'
  ];

  final List<MedicalRecord> _mockRecords = [
    MedicalRecord(
      id: '1',
      title: 'Complete Blood Count (CBC)',
      category: 'Lab Results',
      date: DateTime(2025, 1, 10),
      doctor: 'Dr. Sarah Johnson',
      facility: 'City Medical Center',
      priority: RecordPriority.normal,
      status: RecordStatus.completed,
      description: 'Routine blood work showing normal values across all parameters.',
      details: {
        'Hemoglobin': '14.2 g/dL (Normal)',
        'White Blood Cells': '6,800/μL (Normal)',
        'Platelets': '285,000/μL (Normal)',
        'Hematocrit': '42.1% (Normal)',
      },
    ),
    MedicalRecord(
      id: '2',
      title: 'Amoxicillin 500mg',
      category: 'Prescriptions',
      date: DateTime(2025, 1, 5),
      doctor: 'Dr. Michael Chen',
      facility: 'Family Health Clinic',
      priority: RecordPriority.normal,
      status: RecordStatus.active,
      description: 'Antibiotic prescribed for bacterial infection treatment.',
      details: {
        'Dosage': '500mg three times daily',
        'Duration': '7 days',
        'Instructions': 'Take with food to reduce stomach upset',
        'Refills': '0 remaining',
      },
    ),
    MedicalRecord(
      id: '3',
      title: 'Chest X-Ray',
      category: 'Imaging',
      date: DateTime(2024, 12, 28),
      doctor: 'Dr. Emily Rodriguez',
      facility: 'Regional Imaging Center',
      priority: RecordPriority.followUp,
      status: RecordStatus.completed,
      description: 'Chest X-ray ordered to rule out pneumonia. Results show clear lungs.',
      details: {
        'Study Type': 'PA and Lateral Chest X-ray',
        'Findings': 'No acute cardiopulmonary abnormalities',
        'Impression': 'Normal chest X-ray',
        'Technique': 'Digital radiography',
      },
    ),
    MedicalRecord(
      id: '4',
      title: 'Annual Physical Examination',
      category: 'Consultations',
      date: DateTime(2024, 12, 15),
      doctor: 'Dr. Robert Kim',
      facility: 'Primary Care Associates',
      priority: RecordPriority.normal,
      status: RecordStatus.completed,
      description: 'Comprehensive annual physical examination with preventive care screening.',
      details: {
        'Blood Pressure': '118/76 mmHg',
        'Weight': '165 lbs',
        'BMI': '24.2 (Normal)',
        'Recommendations': 'Continue current exercise routine, annual mammogram due',
      },
    ),
    MedicalRecord(
      id: '5',
      title: 'COVID-19 Booster',
      category: 'Vaccinations',
      date: DateTime(2024, 11, 20),
      doctor: 'Nurse Patricia Williams',
      facility: 'Community Health Center',
      priority: RecordPriority.normal,
      status: RecordStatus.completed,
      description: 'COVID-19 booster vaccination administered.',
      details: {
        'Vaccine': 'Pfizer-BioNTech COVID-19 Vaccine',
        'Lot Number': 'FL8094',
        'Site': 'Left deltoid muscle',
        'Next Due': 'Fall 2025',
      },
    ),
    MedicalRecord(
      id: '6',
      title: 'Lipid Panel',
      category: 'Lab Results',
      date: DateTime(2024, 11, 8),
      doctor: 'Dr. Sarah Johnson',
      facility: 'City Medical Center',
      priority: RecordPriority.urgent,
      status: RecordStatus.requiresAction,
      description: 'Lipid panel showing elevated cholesterol levels requiring follow-up.',
      details: {
        'Total Cholesterol': '245 mg/dL (High)',
        'LDL': '165 mg/dL (High)',
        'HDL': '42 mg/dL (Low)',
        'Triglycerides': '190 mg/dL (Borderline High)',
      },
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<MedicalRecord> get _filteredRecords {
    List<MedicalRecord> filtered = _mockRecords;

    // Filter by category
    if (_selectedCategory != 'All') {
      filtered = filtered.where((record) => record.category == _selectedCategory).toList();
    }

    // Filter by search term
    if (_searchController.text.isNotEmpty) {
      final searchTerm = _searchController.text.toLowerCase();
      filtered = filtered.where((record) =>
      record.title.toLowerCase().contains(searchTerm) ||
          record.doctor.toLowerCase().contains(searchTerm) ||
          record.facility.toLowerCase().contains(searchTerm) ||
          record.description.toLowerCase().contains(searchTerm)).toList();
    }

    // Filter by date range
    if (_selectedDateRange != null) {
      filtered = filtered.where((record) =>
      record.date.isAfter(_selectedDateRange!.start.subtract(const Duration(days: 1))) &&
          record.date.isBefore(_selectedDateRange!.end.add(const Duration(days: 1)))).toList();
    }

    // Sort by date (most recent first)
    filtered.sort((a, b) => b.date.compareTo(a.date));

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Medical Records'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.grey[200],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: Column(
        children: [
          // Search Bar
          if (_isSearching)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.white,
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search records, doctors, or facilities...',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                      });
                    },
                  )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                onChanged: (value) {
                  setState(() {});
                },
              ),
            ),

          // Category Filter Chips
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.white,
                    selectedColor: Colors.blue[100],
                    checkmarkColor: Colors.blue[700],
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.blue[700] : Colors.grey[700],
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                    side: BorderSide(
                      color: isSelected ? Colors.blue[300]! : Colors.grey[300]!,
                    ),
                  ),
                );
              },
            ),
          ),

          // Active Filters Display
          if (_selectedDateRange != null || _selectedCategory != 'All')
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Text('Active filters: ', style: TextStyle(fontWeight: FontWeight.w500)),
                  if (_selectedCategory != 'All')
                    Chip(
                      label: Text(_selectedCategory),
                      onDeleted: () {
                        setState(() {
                          _selectedCategory = 'All';
                        });
                      },
                      backgroundColor: Colors.blue[50],
                      deleteIconColor: Colors.blue[700],
                    ),
                  if (_selectedDateRange != null)
                    Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: Chip(
                        label: Text(
                          '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}',
                        ),
                        onDeleted: () {
                          setState(() {
                            _selectedDateRange = null;
                          });
                        },
                        backgroundColor: Colors.blue[50],
                        deleteIconColor: Colors.blue[700],
                      ),
                    ),
                  const Spacer(),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategory = 'All';
                        _selectedDateRange = null;
                        _searchController.clear();
                      });
                    },
                    child: const Text('Clear all'),
                  ),
                ],
              ),
            ),

          // Records List
          Expanded(
            child: _filteredRecords.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: () async {
                // Simulate refresh
                await Future.delayed(const Duration(seconds: 1));
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _filteredRecords.length,
                itemBuilder: (context, index) {
                  final record = _filteredRecords[index];
                  return _buildRecordCard(record);
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showAddRecordDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text('Add Record'),
        backgroundColor: Colors.blue[600],
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/patient/home');
          if (index == 1) context.go('/patient/profile');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildRecordCard(MedicalRecord record) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRecordDetails(record),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(record.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _getCategoryIcon(record.category),
                      color: _getCategoryColor(record.category),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          record.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          record.category,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (record.priority == RecordPriority.urgent)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Text(
                        'URGENT',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.red[700],
                        ),
                      ),
                    ),
                  if (record.priority == RecordPriority.followUp)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange[200]!),
                      ),
                      child: Text(
                        'FOLLOW-UP',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                record.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.person, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Text(
                    record.doctor,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      record.facility,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${record.date.day}/${record.date.month}/${record.date.year}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      _buildStatusChip(record.status),
                      const SizedBox(width: 8),
                      PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                        onSelected: (value) {
                          switch (value) {
                            case 'view':
                              _showRecordDetails(record);
                              break;
                            case 'share':
                              _shareRecord(record);
                              break;
                            case 'download':
                              _downloadRecord(record);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'view',
                            child: Row(
                              children: [
                                Icon(Icons.visibility, size: 18),
                                SizedBox(width: 8),
                                Text('View Details'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'share',
                            child: Row(
                              children: [
                                Icon(Icons.share, size: 18),
                                SizedBox(width: 8),
                                Text('Share'),
                              ],
                            ),
                          ),
                          const PopupMenuItem(
                            value: 'download',
                            child: Row(
                              children: [
                                Icon(Icons.download, size: 18),
                                SizedBox(width: 8),
                                Text('Download'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(RecordStatus status) {
    Color color;
    String text;

    switch (status) {
      case RecordStatus.completed:
        color = Colors.green;
        text = 'Completed';
        break;
      case RecordStatus.active:
        color = Colors.blue;
        text = 'Active';
        break;
      case RecordStatus.requiresAction:
        color = Colors.orange;
        text = 'Action Required';
        break;
      case RecordStatus.pending:
        color = Colors.grey;
        text = 'Pending';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color.fromRGBO(
            (color.red * 0.7).round(),
            (color.green * 0.7).round(),
            (color.blue * 0.7).round(),
            1.0,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No medical records found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedCategory = 'All';
                _selectedDateRange = null;
                _searchController.clear();
              });
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Clear Filters'),
          ),
        ],
      ),
    );
  }

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Lab Results':
        return Colors.purple;
      case 'Prescriptions':
        return Colors.green;
      case 'Imaging':
        return Colors.blue;
      case 'Consultations':
        return Colors.orange;
      case 'Vaccinations':
        return Colors.teal;
      case 'Surgery':
        return Colors.red;
      case 'Insurance':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Lab Results':
        return Icons.science;
      case 'Prescriptions':
        return Icons.medication;
      case 'Imaging':
        return Icons.medical_services;
      case 'Consultations':
        return Icons.chat;
      case 'Vaccinations':
        return Icons.vaccines;
      case 'Surgery':
        return Icons.local_hospital;
      case 'Insurance':
        return Icons.account_balance;
      default:
        return Icons.description;
    }
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Records'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Date Range', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );
                if (dateRange != null) {
                  setState(() {
                    _selectedDateRange = dateRange;
                  });
                }
              },
              icon: const Icon(Icons.date_range),
              label: Text(_selectedDateRange == null
                  ? 'Select Date Range'
                  : '${_selectedDateRange!.start.day}/${_selectedDateRange!.start.month} - ${_selectedDateRange!.end.day}/${_selectedDateRange!.end.month}'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedDateRange = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _showRecordDetails(MedicalRecord record) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: _getCategoryColor(record.category).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _getCategoryIcon(record.category),
                              color: _getCategoryColor(record.category),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  record.title,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  record.category,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _buildStatusChip(record.status),
                        ],
                      ),
                      const SizedBox(height: 24),

                      _buildDetailSection('Description', record.description),
                      const SizedBox(height: 20),

                      _buildDetailSection('Healthcare Provider', record.doctor),
                      const SizedBox(height: 20),

                      _buildDetailSection('Facility', record.facility),
                      const SizedBox(height: 20),

                      _buildDetailSection('Date', '${record.date.day}/${record.date.month}/${record.date.year}'),
                      const SizedBox(height: 20),

                      if (record.details.isNotEmpty) ...[
                        const Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ...record.details.entries.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: 120,
                                child: Text(
                                  '${entry.key}:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        )),
                        const SizedBox(height: 24),
                      ],

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () => _shareRecord(record),
                              icon: const Icon(Icons.share),
                              label: const Text('Share'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _downloadRecord(record),
                              icon: const Icon(Icons.download),
                              label: const Text('Download'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: const TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  void _showAddRecordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Medical Record'),
        content: const Text('This feature would allow you to add new medical records by uploading documents or entering information manually.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Add record feature coming soon!')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _shareRecord(MedicalRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Sharing ${record.title}...')),
    );
  }

  void _downloadRecord(MedicalRecord record) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Downloading ${record.title}...')),
    );
  }
}

// Data Models
class MedicalRecord {
  final String id;
  final String title;
  final String category;
  final DateTime date;
  final String doctor;
  final String facility;
  final RecordPriority priority;
  final RecordStatus status;
  final String description;
  final Map<String, String> details;

  MedicalRecord({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.doctor,
    required this.facility,
    required this.priority,
    required this.status,
    required this.description,
    required this.details,
  });
}

enum RecordPriority { normal, urgent, followUp }
enum RecordStatus { completed, active, requiresAction, pending }
