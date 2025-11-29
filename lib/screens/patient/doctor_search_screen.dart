import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class DoctorSearchScreen extends StatefulWidget {
  const DoctorSearchScreen({super.key});

  @override
  State<DoctorSearchScreen> createState() => _DoctorSearchScreenState();
}

class _DoctorSearchScreenState extends State<DoctorSearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String selectedSpecialty = 'All Specialties';
  String selectedGender = 'Any';
  String selectedLanguage = 'Any';
  double maxDistance = 25.0;
  RangeValues consultationFeeRange = const RangeValues(0, 500);
  bool availableToday = false;
  bool acceptsInsurance = false;
  bool telemedicineAvailable = false;
  bool showFilters = false;

  final List<String> specialties = [
    'All Specialties',
    'Cardiology',
    'Dermatology',
    'Endocrinology',
    'Gastroenterology',
    'General Medicine',
    'Neurology',
    'Oncology',
    'Orthopedics',
    'Pediatrics',
    'Psychiatry',
    'Pulmonology',
    'Radiology',
    'Surgery',
    'Urology',
  ];

  final List<String> languages = [
    'Any',
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
    'Portuguese',
    'Arabic',
    'Hindi',
    'Mandarin',
  ];

  final List<Map<String, dynamic>> recentSearches = [
    {'query': 'Cardiologist near me', 'specialty': 'Cardiology', 'location': 'Current Location'},
    {'query': 'Dr. Sarah Johnson', 'specialty': 'Dermatology', 'location': 'New York'},
    {'query': 'Pediatrician Manhattan', 'specialty': 'Pediatrics', 'location': 'Manhattan'},
  ];

  final List<Map<String, dynamic>> popularSpecialties = [
    {'name': 'General Medicine', 'icon': Icons.medical_services, 'color': Colors.blue},
    {'name': 'Cardiology', 'icon': Icons.favorite, 'color': Colors.red},
    {'name': 'Dermatology', 'icon': Icons.face, 'color': Colors.orange},
    {'name': 'Pediatrics', 'icon': Icons.child_care, 'color': Colors.green},
    {'name': 'Orthopedics', 'icon': Icons.accessibility, 'color': Colors.purple},
    {'name': 'Neurology', 'icon': Icons.psychology, 'color': Colors.indigo},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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
    _locationController.dispose();
    super.dispose();
  }

  void _performSearch() {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Navigate to doctor list with search parameters
    context.go('/patient/doctor-list?search=${_searchController.text}&specialty=$selectedSpecialty&location=${_locationController.text}');
  }

  void _clearFilters() {
    setState(() {
      selectedSpecialty = 'All Specialties';
      selectedGender = 'Any';
      selectedLanguage = 'Any';
      maxDistance = 25.0;
      consultationFeeRange = const RangeValues(0, 500);
      availableToday = false;
      acceptsInsurance = false;
      telemedicineAvailable = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Find Doctors',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.map,
                color: Colors.green.shade700,
                size: 20,
              ),
            ),
            onPressed: () {
              context.go('/patient/doctor-map');
            },
            tooltip: 'Map View',
          ),
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_list_off : Icons.filter_list,
              color: showFilters ? Colors.blue : Colors.grey[600],
            ),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue[600]!, Colors.blue[400]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Find the Right Doctor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Search by name, specialty, or location',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Search Fields
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
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
                      // Main Search Field
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: 'Search doctors, specialties...',
                          prefixIcon: const Icon(Icons.search, color: Colors.blue),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {});
                            },
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                        onChanged: (value) => setState(() {}),
                        onSubmitted: (value) => _performSearch(),
                      ),

                      const SizedBox(height: 16),

                      // Location Field
                      TextField(
                        controller: _locationController,
                        decoration: InputDecoration(
                          labelText: 'Location (City, ZIP code)',
                          prefixIcon: const Icon(Icons.location_on, color: Colors.red),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.my_location, color: Colors.blue),
                            onPressed: () {
                              _locationController.text = 'Current Location';
                              setState(() {});
                            },
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.blue, width: 2),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Search Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _performSearch,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search),
                              SizedBox(width: 8),
                              Text(
                                'Search Doctors',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Advanced Filters
                if (showFilters) ...[
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Advanced Filters',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextButton(
                              onPressed: _clearFilters,
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Specialty Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedSpecialty,
                          decoration: InputDecoration(
                            labelText: 'Specialty',
                            prefixIcon: const Icon(Icons.medical_services),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          items: specialties.map((specialty) {
                            return DropdownMenuItem(
                              value: specialty,
                              child: Text(specialty),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedSpecialty = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Gender and Language Row
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedGender,
                                decoration: InputDecoration(
                                  labelText: 'Gender',
                                  prefixIcon: const Icon(Icons.person),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: ['Any', 'Male', 'Female'].map((gender) {
                                  return DropdownMenuItem(
                                    value: gender,
                                    child: Text(gender),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedGender = value!;
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: selectedLanguage,
                                decoration: InputDecoration(
                                  labelText: 'Language',
                                  prefixIcon: const Icon(Icons.language),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                items: languages.map((language) {
                                  return DropdownMenuItem(
                                    value: language,
                                    child: Text(language),
                                  );
                                }).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    selectedLanguage = value!;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // Distance Slider
                        Text(
                          'Maximum Distance: ${maxDistance.round()} miles',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        Slider(
                          value: maxDistance,
                          min: 1,
                          max: 50,
                          divisions: 49,
                          onChanged: (value) {
                            setState(() {
                              maxDistance = value;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Consultation Fee Range
                        Text(
                          'Consultation Fee: \$${consultationFeeRange.start.round()} - \$${consultationFeeRange.end.round()}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        RangeSlider(
                          values: consultationFeeRange,
                          min: 0,
                          max: 1000,
                          divisions: 20,
                          onChanged: (values) {
                            setState(() {
                              consultationFeeRange = values;
                            });
                          },
                        ),

                        const SizedBox(height: 16),

                        // Filter Switches
                        SwitchListTile(
                          title: const Text('Available Today'),
                          subtitle: const Text('Show only doctors available today'),
                          value: availableToday,
                          onChanged: (value) {
                            setState(() {
                              availableToday = value;
                            });
                          },
                        ),

                        SwitchListTile(
                          title: const Text('Accepts Insurance'),
                          subtitle: const Text('Show doctors who accept insurance'),
                          value: acceptsInsurance,
                          onChanged: (value) {
                            setState(() {
                              acceptsInsurance = value;
                            });
                          },
                        ),

                        SwitchListTile(
                          title: const Text('Telemedicine Available'),
                          subtitle: const Text('Show doctors offering virtual consultations'),
                          value: telemedicineAvailable,
                          onChanged: (value) {
                            setState(() {
                              telemedicineAvailable = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Popular Specialties
                const Text(
                  'Popular Specialties',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: popularSpecialties.length,
                  itemBuilder: (context, index) {
                    final specialty = popularSpecialties[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedSpecialty = specialty['name'];
                          _searchController.text = specialty['name'];
                        });
                        _performSearch();
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: specialty['color'].withOpacity(0.3),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Icon(
                              specialty['icon'],
                              color: specialty['color'],
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                specialty['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Recent Searches
                if (recentSearches.isNotEmpty) ...[
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: recentSearches.length,
                    itemBuilder: (context, index) {
                      final search = recentSearches[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.history, color: Colors.grey),
                          title: Text(search['query']),
                          subtitle: Text('${search['specialty']} • ${search['location']}'),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            _searchController.text = search['query'];
                            selectedSpecialty = search['specialty'];
                            _locationController.text = search['location'];
                            _performSearch();
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: Colors.white,
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: 100), // Bottom padding for navigation
              ],
            ),
          ),
        ),
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
}
