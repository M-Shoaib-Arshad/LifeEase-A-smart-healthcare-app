import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class DoctorListScreen extends StatefulWidget {
  const DoctorListScreen({super.key});

  @override
  State<DoctorListScreen> createState() => _DoctorListScreenState();
}

class _DoctorListScreenState extends State<DoctorListScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedSpecialization = 'all';
  String _selectedLocation = 'all';
  String _selectedRating = 'all';
  String _selectedAvailability = 'all';
  String _sortBy = 'rating';
  bool _showFilters = false;

  // Sample doctor data - in real app, this would come from API
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 'D001',
      'name': 'Dr. Sarah Wilson',
      'specialization': 'Cardiologist',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'hospital': 'City General Hospital',
      'experience': 15,
      'rating': 4.9,
      'reviewCount': 245,
      'consultationFee': 150,
      'location': 'Downtown',
      'distance': 2.5,
      'languages': ['English', 'Spanish'],
      'education': 'MD from Harvard Medical School',
      'certifications': ['Board Certified Cardiologist', 'FACC'],
      'nextAvailable': DateTime.now().add(const Duration(days: 2)),
      'availableToday': false,
      'telemedicine': true,
      'emergencyAvailable': true,
      'about': 'Experienced cardiologist specializing in preventive cardiology and heart disease management.',
      'services': ['Heart Disease Treatment', 'Preventive Cardiology', 'Cardiac Imaging'],
    },
    {
      'id': 'D002',
      'name': 'Dr. Michael Chen',
      'specialization': 'Neurologist',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'hospital': 'Metro Medical Center',
      'experience': 12,
      'rating': 4.8,
      'reviewCount': 189,
      'consultationFee': 180,
      'location': 'Midtown',
      'distance': 4.2,
      'languages': ['English', 'Mandarin'],
      'education': 'MD from Johns Hopkins University',
      'certifications': ['Board Certified Neurologist', 'Epilepsy Specialist'],
      'nextAvailable': DateTime.now().add(const Duration(days: 1)),
      'availableToday': true,
      'telemedicine': true,
      'emergencyAvailable': false,
      'about': 'Neurologist with expertise in epilepsy, stroke, and neurodegenerative diseases.',
      'services': ['Epilepsy Treatment', 'Stroke Care', 'Migraine Management'],
    },
    {
      'id': 'D003',
      'name': 'Dr. Emily Rodriguez',
      'specialization': 'Dermatologist',
      'image': 'https://randomuser.me/api/portraits/women/28.jpg',
      'hospital': 'Wellness Clinic',
      'experience': 10,
      'rating': 4.7,
      'reviewCount': 156,
      'consultationFee': 120,
      'location': 'Uptown',
      'distance': 6.8,
      'languages': ['English', 'Spanish', 'French'],
      'education': 'MD from Stanford University',
      'certifications': ['Board Certified Dermatologist', 'Mohs Surgery'],
      'nextAvailable': DateTime.now().add(const Duration(days: 3)),
      'availableToday': false,
      'telemedicine': false,
      'emergencyAvailable': false,
      'about': 'Dermatologist specializing in skin cancer detection and cosmetic dermatology.',
      'services': ['Skin Cancer Screening', 'Acne Treatment', 'Cosmetic Procedures'],
    },
    {
      'id': 'D004',
      'name': 'Dr. James Wilson',
      'specialization': 'Orthopedist',
      'image': 'https://randomuser.me/api/portraits/men/45.jpg',
      'hospital': 'Sports Medicine Center',
      'experience': 18,
      'rating': 4.9,
      'reviewCount': 312,
      'consultationFee': 200,
      'location': 'Downtown',
      'distance': 3.1,
      'languages': ['English'],
      'education': 'MD from Mayo Clinic',
      'certifications': ['Board Certified Orthopedic Surgeon', 'Sports Medicine'],
      'nextAvailable': DateTime.now().add(const Duration(hours: 6)),
      'availableToday': true,
      'telemedicine': false,
      'emergencyAvailable': true,
      'about': 'Orthopedic surgeon specializing in sports injuries and joint replacement.',
      'services': ['Joint Replacement', 'Sports Injury Treatment', 'Arthroscopy'],
    },
    {
      'id': 'D005',
      'name': 'Dr. Lisa Thompson',
      'specialization': 'Pediatrician',
      'image': 'https://randomuser.me/api/portraits/women/35.jpg',
      'hospital': 'Children\'s Hospital',
      'experience': 14,
      'rating': 4.8,
      'reviewCount': 278,
      'consultationFee': 100,
      'location': 'Midtown',
      'distance': 5.5,
      'languages': ['English', 'Spanish'],
      'education': 'MD from UCLA Medical School',
      'certifications': ['Board Certified Pediatrician', 'Adolescent Medicine'],
      'nextAvailable': DateTime.now().add(const Duration(days: 1)),
      'availableToday': false,
      'telemedicine': true,
      'emergencyAvailable': true,
      'about': 'Pediatrician with expertise in child development and adolescent health.',
      'services': ['Well-Child Visits', 'Immunizations', 'Adolescent Care'],
    },
    {
      'id': 'D006',
      'name': 'Dr. Robert Kim',
      'specialization': 'General Practitioner',
      'image': 'https://randomuser.me/api/portraits/men/38.jpg',
      'hospital': 'Family Health Center',
      'experience': 8,
      'rating': 4.6,
      'reviewCount': 134,
      'consultationFee': 80,
      'location': 'Uptown',
      'distance': 7.2,
      'languages': ['English', 'Korean'],
      'education': 'MD from University of Washington',
      'certifications': ['Board Certified Family Medicine'],
      'nextAvailable': DateTime.now().add(const Duration(hours: 4)),
      'availableToday': true,
      'telemedicine': true,
      'emergencyAvailable': false,
      'about': 'Family medicine physician providing comprehensive primary care for all ages.',
      'services': ['Primary Care', 'Preventive Medicine', 'Chronic Disease Management'],
    },
  ];

  final List<String> _specializations = [
    'all',
    'Cardiologist',
    'Neurologist',
    'Dermatologist',
    'Orthopedist',
    'Pediatrician',
    'General Practitioner',
  ];

  final List<String> _locations = [
    'all',
    'Downtown',
    'Midtown',
    'Uptown',
  ];

  @override
  void initState() {
    super.initState();
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
    _animationController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredDoctors() {
    List<Map<String, dynamic>> filtered = _doctors;

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((doctor) {
        final name = doctor['name'].toLowerCase();
        final specialization = doctor['specialization'].toLowerCase();
        final hospital = doctor['hospital'].toLowerCase();
        final query = _searchQuery.toLowerCase();

        return name.contains(query) ||
            specialization.contains(query) ||
            hospital.contains(query);
      }).toList();
    }

    // Apply specialization filter
    if (_selectedSpecialization != 'all') {
      filtered = filtered.where((doctor) {
        return doctor['specialization'] == _selectedSpecialization;
      }).toList();
    }

    // Apply location filter
    if (_selectedLocation != 'all') {
      filtered = filtered.where((doctor) {
        return doctor['location'] == _selectedLocation;
      }).toList();
    }

    // Apply rating filter
    if (_selectedRating != 'all') {
      final minRating = double.parse(_selectedRating);
      filtered = filtered.where((doctor) {
        return doctor['rating'] >= minRating;
      }).toList();
    }

    // Apply availability filter
    if (_selectedAvailability == 'today') {
      filtered = filtered.where((doctor) {
        return doctor['availableToday'] == true;
      }).toList();
    } else if (_selectedAvailability == 'telemedicine') {
      filtered = filtered.where((doctor) {
        return doctor['telemedicine'] == true;
      }).toList();
    } else if (_selectedAvailability == 'emergency') {
      filtered = filtered.where((doctor) {
        return doctor['emergencyAvailable'] == true;
      }).toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      switch (_sortBy) {
        case 'rating':
          return b['rating'].compareTo(a['rating']);
        case 'experience':
          return b['experience'].compareTo(a['experience']);
        case 'fee_low':
          return a['consultationFee'].compareTo(b['consultationFee']);
        case 'fee_high':
          return b['consultationFee'].compareTo(a['consultationFee']);
        case 'distance':
          return a['distance'].compareTo(b['distance']);
        case 'name':
          return a['name'].compareTo(b['name']);
        default:
          return b['rating'].compareTo(a['rating']);
      }
    });

    return filtered;
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter & Sort Doctors'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedSpecialization,
                decoration: const InputDecoration(
                  labelText: 'Specialization',
                  border: OutlineInputBorder(),
                ),
                items: _specializations.map((spec) {
                  return DropdownMenuItem(
                    value: spec,
                    child: Text(spec == 'all' ? 'All Specializations' : spec),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedSpecialization = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedLocation,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
                items: _locations.map((location) {
                  return DropdownMenuItem(
                    value: location,
                    child: Text(location == 'all' ? 'All Locations' : location),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _selectedLocation = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedRating,
                decoration: const InputDecoration(
                  labelText: 'Minimum Rating',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Any Rating')),
                  DropdownMenuItem(value: '4.0', child: Text('4.0+ Stars')),
                  DropdownMenuItem(value: '4.5', child: Text('4.5+ Stars')),
                  DropdownMenuItem(value: '4.8', child: Text('4.8+ Stars')),
                ],
                onChanged: (value) => setState(() => _selectedRating = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedAvailability,
                decoration: const InputDecoration(
                  labelText: 'Availability',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('Any Availability')),
                  DropdownMenuItem(value: 'today', child: Text('Available Today')),
                  DropdownMenuItem(value: 'telemedicine', child: Text('Telemedicine')),
                  DropdownMenuItem(value: 'emergency', child: Text('Emergency Available')),
                ],
                onChanged: (value) => setState(() => _selectedAvailability = value!),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _sortBy,
                decoration: const InputDecoration(
                  labelText: 'Sort By',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'rating', child: Text('Highest Rating')),
                  DropdownMenuItem(value: 'experience', child: Text('Most Experience')),
                  DropdownMenuItem(value: 'fee_low', child: Text('Lowest Fee')),
                  DropdownMenuItem(value: 'fee_high', child: Text('Highest Fee')),
                  DropdownMenuItem(value: 'distance', child: Text('Nearest')),
                  DropdownMenuItem(value: 'name', child: Text('Name A-Z')),
                ],
                onChanged: (value) => setState(() => _sortBy = value!),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedSpecialization = 'all';
                _selectedLocation = 'all';
                _selectedRating = 'all';
                _selectedAvailability = 'all';
                _sortBy = 'rating';
              });
            },
            child: const Text('Reset'),
          ),
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

  void _showDoctorDetails(Map<String, dynamic> doctor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.95,
        minChildSize: 0.6,
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
                  _buildDetailedDoctorCard(doctor),
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
    final filteredDoctors = _getFilteredDoctors();

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
              _buildSearchBar(),
              if (_showFilters) _buildQuickFilters(),
              _buildResultsHeader(filteredDoctors.length),
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: _buildDoctorList(filteredDoctors),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const SideDrawer(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Home tab
        onTap: (index) {
          if (index == 0) context.go('/patient/home');
          if (index == 1) context.go('/patient/profile');
          if (index == 2) context.go('/patient/appointment-history');
          if (index == 3) context.go('/settings');
        },
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
            'Find Doctors',
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
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.map,
                color: Colors.blue.shade700,
              ),
            ),
            onPressed: () => context.push('/patient/doctor-map'),
            tooltip: 'Map View',
          ),
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

  Widget _buildSearchBar() {
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
                hintText: 'Search doctors, specializations...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchQuery.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                      ),
                    IconButton(
                      icon: Icon(
                        _showFilters ? Icons.expand_less : Icons.expand_more,
                      ),
                      onPressed: () {
                        setState(() {
                          _showFilters = !_showFilters;
                        });
                      },
                    ),
                  ],
                ),
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

  Widget _buildQuickFilters() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _buildFilterChip('Available Today', _selectedAvailability == 'today', () {
            setState(() {
              _selectedAvailability = _selectedAvailability == 'today' ? 'all' : 'today';
            });
          }),
          _buildFilterChip('Telemedicine', _selectedAvailability == 'telemedicine', () {
            setState(() {
              _selectedAvailability = _selectedAvailability == 'telemedicine' ? 'all' : 'telemedicine';
            });
          }),
          _buildFilterChip('Emergency', _selectedAvailability == 'emergency', () {
            setState(() {
              _selectedAvailability = _selectedAvailability == 'emergency' ? 'all' : 'emergency';
            });
          }),
          _buildFilterChip('4.5+ Rating', _selectedRating == '4.5', () {
            setState(() {
              _selectedRating = _selectedRating == '4.5' ? 'all' : '4.5';
            });
          }),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => onTap(),
        backgroundColor: Colors.white,
        selectedColor: Colors.blue.shade100,
        checkmarkColor: Colors.blue.shade700,
        labelStyle: TextStyle(
          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildResultsHeader(int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            '$count doctors found',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          const Spacer(),
          if (count > 0)
            TextButton.icon(
              onPressed: () {
                // Toggle view mode (list/grid)
              },
              icon: const Icon(Icons.view_list, size: 16),
              label: const Text('List View'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue.shade600,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDoctorList(List<Map<String, dynamic>> doctors) {
    if (doctors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
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
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildDoctorCard(doctor);
      },
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
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
        onTap: () => _showDoctorDetails(doctor),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: NetworkImage(doctor['image']),
                      ),
                      if (doctor['availableToday'])
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
                              Icons.check,
                              color: Colors.white,
                              size: 12,
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
                          doctor['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          doctor['specialization'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.blue.shade600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            doctor['rating'].toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            ' (${doctor['reviewCount']})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '\$${doctor['consultationFee']}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade600,
                        ),
                      ),
                    ],
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
                        Icon(Icons.work, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          '${doctor['experience']} years experience',
                          style: const TextStyle(fontSize: 12),
                        ),
                        const Spacer(),
                        Icon(Icons.location_on, color: Colors.grey.shade600, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${doctor['distance']} km away',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        if (doctor['telemedicine'])
                          _buildFeatureBadge('Video Call', Icons.video_call, Colors.blue),
                        if (doctor['emergencyAvailable'])
                          _buildFeatureBadge('Emergency', Icons.emergency, Colors.red),
                        if (doctor['availableToday'])
                          _buildFeatureBadge('Today', Icons.today, Colors.green),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showDoctorDetails(doctor),
                      icon: const Icon(Icons.info, size: 16),
                      label: const Text('View Profile'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue.shade600,
                        side: BorderSide(color: Colors.blue.shade600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/patient/appointment-booking'),
                      icon: const Icon(Icons.calendar_today, size: 16),
                      label: const Text('Book Now'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureBadge(String label, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedDoctorCard(Map<String, dynamic> doctor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor Header
        Row(
          children: [
            CircleAvatar(
              radius: 40,
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
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    doctor['specialization'],
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    doctor['hospital'],
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Stats Row
        Row(
          children: [
            Expanded(
              child: _buildStatCard('Rating', '${doctor['rating']}⭐', '${doctor['reviewCount']} reviews'),
            ),
            Expanded(
              child: _buildStatCard('Experience', '${doctor['experience']}', 'years'),
            ),
            Expanded(
              child: _buildStatCard('Fee', '\$${doctor['consultationFee']}', 'consultation'),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // About Section
        const Text(
          'About',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          doctor['about'],
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Services
        const Text(
          'Services',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: (doctor['services'] as List).map((service) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                service,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),

        // Education & Certifications
        _buildInfoSection('Education', doctor['education']),
        const SizedBox(height: 12),
        _buildInfoSection('Certifications', (doctor['certifications'] as List).join(', ')),
        const SizedBox(height: 12),
        _buildInfoSection('Languages', (doctor['languages'] as List).join(', ')),
        const SizedBox(height: 20),

        // Action Buttons
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  context.push('/patient/appointment-booking');
                },
                icon: const Icon(Icons.calendar_today),
                label: const Text('Book Appointment'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Call doctor
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Calling doctor...')),
                  );
                },
                icon: const Icon(Icons.phone),
                label: const Text('Call'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.green.shade600,
                  side: BorderSide(color: Colors.green.shade600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  // Message doctor
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Opening chat...')),
                  );
                },
                icon: const Icon(Icons.message),
                label: const Text('Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.blue.shade600,
                  side: BorderSide(color: Colors.blue.shade600),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
