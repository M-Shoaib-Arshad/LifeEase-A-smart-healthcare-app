import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class AppointmentHistoryScreen extends StatefulWidget {
  const AppointmentHistoryScreen({super.key});

  @override
  State<AppointmentHistoryScreen> createState() => _AppointmentHistoryScreenState();
}

class _AppointmentHistoryScreenState extends State<AppointmentHistoryScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'all';
  String _selectedSort = 'date_desc';

  // Sample appointment data - in real app, this would come from API
  final List<Map<String, dynamic>> _appointments = [
    {
      'id': 'APT001',
      'doctor': {
        'name': 'Dr. Sarah Wilson',
        'specialization': 'Cardiologist',
        'image': 'https://randomuser.me/api/portraits/women/44.jpg',
        'hospital': 'City General Hospital',
      },
      'date': DateTime(2024, 12, 15, 10, 0),
      'type': 'Consultation',
      'status': 'completed',
      'reason': 'Chest pain evaluation',
      'duration': 30,
      'fee': 150,
      'rating': 5,
      'notes': 'Regular checkup completed successfully',
      'prescription': true,
      'followUp': DateTime(2025, 1, 15, 10, 0),
    },
    {
      'id': 'APT002',
      'doctor': {
        'name': 'Dr. Michael Chen',
        'specialization': 'Neurologist',
        'image': 'https://randomuser.me/api/portraits/men/32.jpg',
        'hospital': 'Metro Medical Center',
      },
      'date': DateTime(2024, 12, 20, 14, 0),
      'type': 'Follow-up',
      'status': 'completed',
      'reason': 'Migraine treatment review',
      'duration': 20,
      'fee': 100,
      'rating': 4,
      'notes': 'Medication adjusted, symptoms improving',
      'prescription': true,
      'followUp': null,
    },
    {
      'id': 'APT003',
      'doctor': {
        'name': 'Dr. Emily Rodriguez',
        'specialization': 'Dermatologist',
        'image': 'https://randomuser.me/api/portraits/women/28.jpg',
        'hospital': 'Wellness Clinic',
      },
      'date': DateTime(2024, 12, 25, 11, 30),
      'type': 'Consultation',
      'status': 'upcoming',
      'reason': 'Skin condition examination',
      'duration': 45,
      'fee': 120,
      'rating': null,
      'notes': null,
      'prescription': false,
      'followUp': null,
    },
    {
      'id': 'APT004',
      'doctor': {
        'name': 'Dr. James Wilson',
        'specialization': 'Orthopedist',
        'image': 'https://randomuser.me/api/portraits/men/45.jpg',
        'hospital': 'Sports Medicine Center',
      },
      'date': DateTime(2024, 12, 22, 9, 0),
      'type': 'Emergency',
      'status': 'cancelled',
      'reason': 'Knee injury assessment',
      'duration': 60,
      'fee': 200,
      'rating': null,
      'notes': 'Cancelled due to patient emergency',
      'prescription': false,
      'followUp': null,
    },
    {
      'id': 'APT005',
      'doctor': {
        'name': 'Dr. Lisa Thompson',
        'specialization': 'Pediatrician',
        'image': 'https://randomuser.me/api/portraits/women/35.jpg',
        'hospital': 'Children\'s Hospital',
      },
      'date': DateTime(2025, 1, 5, 15, 30),
      'type': 'Check-up',
      'status': 'upcoming',
      'reason': 'Annual physical examination',
      'duration': 30,
      'fee': 80,
      'rating': null,
      'notes': null,
      'prescription': false,
      'followUp': null,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
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
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredAppointments() {
    List<Map<String, dynamic>> filtered = _appointments;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((appointment) {
        final doctorName = appointment['doctor']['name'].toLowerCase();
        final specialization = appointment['doctor']['specialization'].toLowerCase();
        final reason = appointment['reason'].toLowerCase();
        final query = _searchQuery.toLowerCase();

        return doctorName.contains(query) ||
            specialization.contains(query) ||
            reason.contains(query);
      }).toList();
    }

    // Apply status filter
    if (_selectedFilter != 'all') {
      filtered = filtered.where((appointment) {
        return appointment['status'] == _selectedFilter;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_selectedSort) {
        case 'date_asc':
          return a['date'].compareTo(b['date']);
        case 'date_desc':
          return b['date'].compareTo(a['date']);
        case 'doctor_name':
          return a['doctor']['name'].compareTo(b['doctor']['name']);
        case 'fee_high':
          return b['fee'].compareTo(a['fee']);
        case 'fee_low':
          return a['fee'].compareTo(b['fee']);
        default:
          return b['date'].compareTo(a['date']);
      }
    });

    return filtered;
  }

  List<Map<String, dynamic>> _getAppointmentsByStatus(String status) {
    if (status == 'all') return _getFilteredAppointments();
    return _getFilteredAppointments().where((apt) => apt['status'] == status).toList();
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              value: _selectedFilter,
              decoration: const InputDecoration(
                labelText: 'Filter by Status',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('All Appointments')),
                DropdownMenuItem(value: 'upcoming', child: Text('Upcoming')),
                DropdownMenuItem(value: 'completed', child: Text('Completed')),
                DropdownMenuItem(value: 'cancelled', child: Text('Cancelled')),
              ],
              onChanged: (value) => setState(() => _selectedFilter = value!),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSort,
              decoration: const InputDecoration(
                labelText: 'Sort by',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'date_desc', child: Text('Date (Newest First)')),
                DropdownMenuItem(value: 'date_asc', child: Text('Date (Oldest First)')),
                DropdownMenuItem(value: 'doctor_name', child: Text('Doctor Name')),
                DropdownMenuItem(value: 'fee_high', child: Text('Fee (High to Low)')),
                DropdownMenuItem(value: 'fee_low', child: Text('Fee (Low to High)')),
              ],
              onChanged: (value) => setState(() => _selectedSort = value!),
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
              setState(() {});
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _showAppointmentDetails(Map<String, dynamic> appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildDetailedAppointmentCard(appointment),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: Container(
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
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildSearchAndFilter(),
              _buildTabBar(),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildAppointmentList(_getAppointmentsByStatus('all')),
                        _buildAppointmentList(_getAppointmentsByStatus('upcoming')),
                        _buildAppointmentList(_getAppointmentsByStatus('completed')),
                        _buildAppointmentList(_getAppointmentsByStatus('cancelled')),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const SideDrawer(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 2, // Schedule tab
        onTap: (index) {
          if (index == 0) context.go('/patient/home');
          if (index == 1) context.go('/patient/profile');
          if (index == 2) context.go('/patient/appointments');
          if (index == 3) context.go('/settings');
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/patient/appointment-booking'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Book New'),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Builder(
            builder: (context) => IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.menu,
                  color: Colors.blue.shade700,
                ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const Spacer(),
          const Text(
            'Appointment History',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const Spacer(),
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.filter_list,
                color: Colors.green.shade700,
              ),
            ),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search appointments...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        indicatorColor: Colors.blue,
        indicatorWeight: 3,
        isScrollable: true,
        tabs: [
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('All'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _appointments.length.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Upcoming'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _appointments.where((apt) => apt['status'] == 'upcoming').length.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Completed'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _appointments.where((apt) => apt['status'] == 'completed').length.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Cancelled'),
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _appointments.where((apt) => apt['status'] == 'cancelled').length.toString(),
                    style: const TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentList(List<Map<String, dynamic>> appointments) {
    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No appointments found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _buildAppointmentCard(appointment);
      },
    );
  }

  Widget _buildAppointmentCard(Map<String, dynamic> appointment) {
    final doctor = appointment['doctor'];
    final status = appointment['status'];
    final isUpcoming = status == 'upcoming';
    final isCompleted = status == 'completed';
    final isCancelled = status == 'cancelled';

    Color statusColor = Colors.grey;
    Color statusBgColor = Colors.grey.shade100;
    IconData statusIcon = Icons.schedule;

    if (isUpcoming) {
      statusColor = Colors.blue.shade700;
      statusBgColor = Colors.blue.shade50;
      statusIcon = Icons.schedule;
    } else if (isCompleted) {
      statusColor = Colors.green.shade700;
      statusBgColor = Colors.green.shade50;
      statusIcon = Icons.check_circle;
    } else if (isCancelled) {
      statusColor = Colors.red.shade700;
      statusBgColor = Colors.red.shade50;
      statusIcon = Icons.cancel;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showAppointmentDetails(appointment),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundImage: NetworkImage(doctor['image']),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor['name'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor['specialization'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          doctor['hospital'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusBgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          status.toUpperCase(),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          DateFormat('EEEE, MMM d, yyyy').format(appointment['date']),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const Spacer(),
                        Icon(Icons.access_time, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          DateFormat('h:mm a').format(appointment['date']),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.medical_services, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            appointment['reason'],
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                        Text(
                          '\$${appointment['fee']}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isCompleted && appointment['rating'] != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Rating: ', style: TextStyle(fontSize: 12)),
                    ...List.generate(5, (index) {
                      return Icon(
                        index < appointment['rating'] ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ],
                ),
              ],
              if (appointment['followUp'] != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.event_repeat, color: Colors.orange.shade600, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'Follow-up: ${DateFormat('MMM d').format(appointment['followUp'])}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.orange.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedAppointmentCard(Map<String, dynamic> appointment) {
    final doctor = appointment['doctor'];
    final status = appointment['status'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Appointment Details',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),

        // Doctor Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundImage: NetworkImage(doctor['image']),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor['name'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      doctor['specialization'],
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade600,
                      ),
                    ),
                    Text(
                      doctor['hospital'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Appointment Info
        _buildDetailRow('Date', DateFormat('EEEE, MMMM d, yyyy').format(appointment['date'])),
        _buildDetailRow('Time', DateFormat('h:mm a').format(appointment['date'])),
        _buildDetailRow('Type', appointment['type']),
        _buildDetailRow('Duration', '${appointment['duration']} minutes'),
        _buildDetailRow('Reason', appointment['reason']),
        _buildDetailRow('Fee', '\$${appointment['fee']}'),
        _buildDetailRow('Status', status.toUpperCase()),

        if (appointment['notes'] != null) ...[
          const SizedBox(height: 16),
          const Text(
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(appointment['notes']),
          ),
        ],

        if (status == 'completed') ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Download prescription
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Downloading prescription...')),
                    );
                  },
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('Prescription'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Book follow-up
                    context.go('/patient/appointment-booking');
                  },
                  icon: const Icon(Icons.event_repeat, size: 16),
                  label: const Text('Book Follow-up'),
                ),
              ),
            ],
          ),
        ],

        if (status == 'upcoming') ...[
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Reschedule
                    context.go('/patient/appointment-booking');
                  },
                  icon: const Icon(Icons.schedule, size: 16),
                  label: const Text('Reschedule'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Cancel appointment
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.cancel, size: 16),
                  label: const Text('Cancel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
