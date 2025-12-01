import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../services/location_service.dart';
import '../../widgets/bottom_nav_bar.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/map/doctor_map_marker.dart';
import '../../widgets/map/location_permission_dialog.dart';

class DoctorMapSearchScreen extends StatefulWidget {
  const DoctorMapSearchScreen({super.key});

  @override
  State<DoctorMapSearchScreen> createState() => _DoctorMapSearchScreenState();
}

class _DoctorMapSearchScreenState extends State<DoctorMapSearchScreen>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _controller = Completer();
  final LocationService _locationService = LocationService();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isLoading = true;
  bool _isLocationEnabled = false;
  String? _selectedDoctorId;
  Map<String, dynamic>? _selectedDoctor;
  double _searchRadius = 10.0; // km
  String _selectedSpecialty = 'All';

  LatLng _currentPosition = const LatLng(40.7128, -74.0060); // Default: NYC
  Set<Marker> _markers = {};
  Set<Circle> _circles = {};

  final List<String> _specialties = [
    'All',
    'Cardiologist',
    'Neurologist',
    'Dermatologist',
    'Orthopedist',
    'Pediatrician',
    'General Practitioner',
  ];

  // Sample doctor data with locations
  final List<Map<String, dynamic>> _doctors = [
    {
      'id': 'D001',
      'name': 'Dr. Sarah Wilson',
      'specialization': 'Cardiologist',
      'image': 'https://randomuser.me/api/portraits/women/44.jpg',
      'hospital': 'City General Hospital',
      'rating': 4.9,
      'reviewCount': 245,
      'consultationFee': 150,
      'latitude': 40.7580,
      'longitude': -73.9855,
      'distance': 2.5,
      'availableToday': false,
      'telemedicine': true,
    },
    {
      'id': 'D002',
      'name': 'Dr. Michael Chen',
      'specialization': 'Neurologist',
      'image': 'https://randomuser.me/api/portraits/men/32.jpg',
      'hospital': 'Metro Medical Center',
      'rating': 4.8,
      'reviewCount': 189,
      'consultationFee': 180,
      'latitude': 40.7489,
      'longitude': -73.9680,
      'distance': 4.2,
      'availableToday': true,
      'telemedicine': true,
    },
    {
      'id': 'D003',
      'name': 'Dr. Emily Rodriguez',
      'specialization': 'Dermatologist',
      'image': 'https://randomuser.me/api/portraits/women/28.jpg',
      'hospital': 'Wellness Clinic',
      'rating': 4.7,
      'reviewCount': 156,
      'consultationFee': 120,
      'latitude': 40.7614,
      'longitude': -73.9776,
      'distance': 6.8,
      'availableToday': false,
      'telemedicine': false,
    },
    {
      'id': 'D004',
      'name': 'Dr. James Wilson',
      'specialization': 'Orthopedist',
      'image': 'https://randomuser.me/api/portraits/men/45.jpg',
      'hospital': 'Sports Medicine Center',
      'rating': 4.9,
      'reviewCount': 312,
      'consultationFee': 200,
      'latitude': 40.7527,
      'longitude': -73.9772,
      'distance': 3.1,
      'availableToday': true,
      'telemedicine': false,
    },
    {
      'id': 'D005',
      'name': 'Dr. Lisa Thompson',
      'specialization': 'Pediatrician',
      'image': 'https://randomuser.me/api/portraits/women/35.jpg',
      'hospital': 'Children\'s Hospital',
      'rating': 4.8,
      'reviewCount': 278,
      'consultationFee': 100,
      'latitude': 40.7459,
      'longitude': -73.9866,
      'distance': 5.5,
      'availableToday': false,
      'telemedicine': true,
    },
    {
      'id': 'D006',
      'name': 'Dr. Robert Kim',
      'specialization': 'General Practitioner',
      'image': 'https://randomuser.me/api/portraits/men/38.jpg',
      'hospital': 'Family Health Center',
      'rating': 4.6,
      'reviewCount': 134,
      'consultationFee': 80,
      'latitude': 40.7549,
      'longitude': -73.9840,
      'distance': 7.2,
      'availableToday': true,
      'telemedicine': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _initializeLocation();
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

    _animationController.forward();
  }

  Future<void> _initializeLocation() async {
    final hasPermission = await _locationService.isPermissionGranted();

    if (!hasPermission) {
      if (mounted) {
        LocationPermissionDialog.show(
          context,
          onPermissionGranted: () => _getCurrentLocation(),
          onPermissionDenied: () => _loadDefaultLocation(),
        );
      }
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    final position = await _locationService.getCurrentPosition();

    if (position != null) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLocationEnabled = true;
      });
      _updateMarkers();
      _moveCamera(_currentPosition);
    } else {
      _loadDefaultLocation();
    }

    setState(() => _isLoading = false);
  }

  void _loadDefaultLocation() {
    setState(() {
      _isLoading = false;
      _isLocationEnabled = false;
    });
    _updateMarkers();
  }

  void _updateMarkers() {
    final filteredDoctors = _getFilteredDoctors();

    setState(() {
      _markers = DoctorMapMarker.createMarkersFromDoctors(
        doctors: filteredDoctors,
        onMarkerTap: _onMarkerTap,
        selectedDoctorId: _selectedDoctorId,
      );

      // Add user location marker if available
      if (_isLocationEnabled) {
        _markers.add(
          Marker(
            markerId: const MarkerId('user_location'),
            position: _currentPosition,
            icon:
                BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            infoWindow: const InfoWindow(title: 'Your Location'),
          ),
        );
      }

      // Update search radius circle
      _circles = {
        Circle(
          circleId: const CircleId('search_radius'),
          center: _currentPosition,
          radius: _searchRadius * 1000, // Convert km to meters
          strokeWidth: 2,
          strokeColor: Colors.blue.shade300,
          fillColor: Colors.blue.shade100.withOpacity(0.3),
        ),
      };
    });
  }

  List<Map<String, dynamic>> _getFilteredDoctors() {
    return _doctors.where((doctor) {
      // Filter by specialty
      if (_selectedSpecialty != 'All' &&
          doctor['specialization'] != _selectedSpecialty) {
        return false;
      }

      // Filter by distance (simplified - in real app would calculate actual distance)
      if (doctor['distance'] > _searchRadius) {
        return false;
      }

      return true;
    }).toList();
  }

  void _onMarkerTap(Map<String, dynamic> doctor) {
    setState(() {
      _selectedDoctorId = doctor['id'];
      _selectedDoctor = doctor;
    });
    _updateMarkers();
  }

  Future<void> _moveCamera(LatLng position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 13.0,
        ),
      ),
    );
  }

  void _onSearchRadiusChanged(double value) {
    setState(() {
      _searchRadius = value;
    });
    _updateMarkers();
  }

  void _onSpecialtyChanged(String? value) {
    if (value != null) {
      setState(() {
        _selectedSpecialty = value;
        _selectedDoctorId = null;
        _selectedDoctor = null;
      });
      _updateMarkers();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              _buildFilters(),
              Expanded(
                child: Stack(
                  children: [
                    _buildMap(),
                    if (_isLoading) _buildLoadingOverlay(),
                    if (!_isLocationEnabled && !_isLoading)
                      Positioned(
                        top: 16,
                        left: 16,
                        right: 16,
                        child: LocationDisabledBanner(
                          onEnablePressed: () => _initializeLocation(),
                        ),
                      ),
                    Positioned(
                      bottom: 16,
                      left: 16,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: const MapMarkerLegend(),
                      ),
                    ),
                    Positioned(
                      bottom: 16,
                      right: 16,
                      child: _buildMapControls(),
                    ),
                    if (_selectedDoctor != null)
                      Positioned(
                        bottom: 120,
                        left: 16,
                        right: 16,
                        child: _buildDoctorCard(_selectedDoctor!),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      drawer: const SideDrawer(),
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
            'Find Nearby Doctors',
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
                Icons.list,
                color: Colors.green.shade700,
              ),
            ),
            onPressed: () => context.push('/patient/doctor-list'),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: _selectedSpecialty,
                  decoration: InputDecoration(
                    labelText: 'Specialty',
                    prefixIcon: const Icon(Icons.medical_services),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  items: _specialties.map((specialty) {
                    return DropdownMenuItem(
                      value: specialty,
                      child: Text(
                        specialty,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: _onSpecialtyChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.radar, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                'Search Radius: ${_searchRadius.round()} km',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Slider(
            value: _searchRadius,
            min: 1,
            max: 50,
            divisions: 49,
            onChanged: _onSearchRadiusChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    return GoogleMap(
      mapType: MapType.normal,
      initialCameraPosition: CameraPosition(
        target: _currentPosition,
        zoom: 12.0,
      ),
      markers: _markers,
      circles: _circles,
      myLocationEnabled: _isLocationEnabled,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      compassEnabled: true,
      onMapCreated: (GoogleMapController controller) {
        _controller.complete(controller);
      },
      onTap: (LatLng position) {
        setState(() {
          _selectedDoctorId = null;
          _selectedDoctor = null;
        });
        _updateMarkers();
      },
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.white.withOpacity(0.8),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Finding your location...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.small(
          heroTag: 'zoom_in',
          onPressed: () async {
            final controller = await _controller.future;
            controller.animateCamera(CameraUpdate.zoomIn());
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'zoom_out',
          onPressed: () async {
            final controller = await _controller.future;
            controller.animateCamera(CameraUpdate.zoomOut());
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.remove, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'my_location',
          onPressed: () {
            if (_isLocationEnabled) {
              _moveCamera(_currentPosition);
            } else {
              _initializeLocation();
            }
          },
          backgroundColor:
              _isLocationEnabled ? Colors.blue.shade600 : Colors.white,
          child: Icon(
            Icons.my_location,
            color: _isLocationEnabled ? Colors.white : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorCard(Map<String, dynamic> doctor) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
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
                          fontWeight: FontWeight.w500,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          doctor['rating'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.w600),
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
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on,
                            color: Colors.red.shade400, size: 14),
                        const SizedBox(width: 2),
                        Text(
                          '${doctor['distance']} km',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                if (doctor['availableToday'])
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle,
                            color: Colors.green.shade600, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Available Today',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.green.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (doctor['telemedicine']) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.video_call,
                            color: Colors.blue.shade600, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          'Video Call',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/patient/doctor-profile'),
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
                    onPressed: () =>
                        context.push('/patient/appointment-booking'),
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
    );
  }
}
