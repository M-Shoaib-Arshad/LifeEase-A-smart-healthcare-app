import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class DoctorProfileViewScreen extends StatefulWidget {
  const DoctorProfileViewScreen({super.key});

  @override
  State<DoctorProfileViewScreen> createState() =>
      _DoctorProfileViewScreenState();
}

class _DoctorProfileViewScreenState extends State<DoctorProfileViewScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Sample doctor data - in a real app, this would come from a provider or API
  final Map<String, dynamic> _doctorData = {
    'name': 'Dr. Jane Smith',
    'specialization': 'Cardiologist',
    'experience': 10,
    'location': 'New York, NY',
    'email': 'jane.smith@hospital.com',
    'phone': '+1 (555) 123-4567',
    'licenseNumber': 'MD123456789',
    'consultationFee': 150,
    'rating': 4.8,
    'totalReviews': 324,
    'totalPatients': 1250,
    'languages': ['English', 'Spanish', 'French'],
    'workingDays': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'],
    'workingHours': '9:00 AM - 5:00 PM',
    'bio':
        'Dr. Jane Smith is a board-certified cardiologist with over 10 years of experience in treating cardiovascular diseases. She specializes in preventive cardiology, heart failure management, and interventional procedures.',
    'education': [
      {
        'degree': 'MD - Doctor of Medicine',
        'institution': 'Harvard Medical School',
        'year': '2014',
      },
      {
        'degree': 'Residency in Internal Medicine',
        'institution': 'Johns Hopkins Hospital',
        'year': '2017',
      },
      {
        'degree': 'Fellowship in Cardiology',
        'institution': 'Mayo Clinic',
        'year': '2020',
      },
    ],
    'achievements': [
      'Board Certified in Cardiology',
      'Fellow of American College of Cardiology',
      'Published 25+ research papers',
      'Speaker at International Cardiology Conference 2023',
    ],
    'profileImage': 'https://randomuser.me/api/portraits/women/44.jpg',
    'isVerified': true,
    'joinDate': DateTime(2020, 3, 15),
    'ratingBreakdown': {
      5: 245,
      4: 52,
      3: 18,
      2: 6,
      1: 3,
    },
    'reviews': [
      {
        'id': '1',
        'patientName': 'Sarah Johnson',
        'patientImage': 'https://randomuser.me/api/portraits/women/32.jpg',
        'rating': 5,
        'date': DateTime(2024, 12, 15),
        'review':
            'Dr. Smith is absolutely wonderful! She took the time to explain my condition thoroughly and made me feel comfortable throughout the entire process. Her expertise in cardiology is evident, and I highly recommend her to anyone needing cardiac care.',
        'isVerified': true,
        'helpfulCount': 12,
        'treatmentType': 'Heart Checkup',
      },
      {
        'id': '2',
        'patientName': 'Michael Chen',
        'patientImage': 'https://randomuser.me/api/portraits/men/45.jpg',
        'rating': 5,
        'date': DateTime(2024, 12, 10),
        'review':
            'Excellent doctor with great bedside manner. She diagnosed my heart condition quickly and provided a comprehensive treatment plan. The follow-up care has been exceptional.',
        'isVerified': true,
        'helpfulCount': 8,
        'treatmentType': 'Cardiac Consultation',
      },
      {
        'id': '3',
        'patientName': 'Emily Rodriguez',
        'patientImage': 'https://randomuser.me/api/portraits/women/67.jpg',
        'rating': 4,
        'date': DateTime(2024, 12, 5),
        'review':
            'Dr. Smith is very knowledgeable and professional. The appointment was thorough, though the wait time was a bit longer than expected. Overall, very satisfied with the care received.',
        'isVerified': true,
        'helpfulCount': 5,
        'treatmentType': 'Follow-up Visit',
      },
      {
        'id': '4',
        'patientName': 'David Wilson',
        'patientImage': 'https://randomuser.me/api/portraits/men/23.jpg',
        'rating': 5,
        'date': DateTime(2024, 11, 28),
        'review':
            'Outstanding cardiologist! Dr. Smith performed my cardiac catheterization with precision and care. Her post-procedure follow-up was excellent. I feel confident in her expertise.',
        'isVerified': true,
        'helpfulCount': 15,
        'treatmentType': 'Cardiac Procedure',
      },
      {
        'id': '5',
        'patientName': 'Lisa Thompson',
        'patientImage': 'https://randomuser.me/api/portraits/women/89.jpg',
        'rating': 5,
        'date': DateTime(2024, 11, 20),
        'review':
            'Dr. Smith saved my life! She quickly identified my heart condition and provided immediate treatment. Her compassionate care and medical expertise are unmatched. Forever grateful!',
        'isVerified': true,
        'helpfulCount': 23,
        'treatmentType': 'Emergency Care',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
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
    super.dispose();
  }

  void _showQRCode() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile QR Code'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code,
                size: 100,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Patients can scan this QR code to view your profile',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              // Share QR code functionality
              Navigator.pop(context);
            },
            child: const Text('Share'),
          ),
        ],
      ),
    );
  }

  void _showAllReviews() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAllReviewsSheet(),
    );
  }

  Widget _buildAllReviewsSheet() {
    final reviews = _doctorData['reviews'] as List;

    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Text(
                  'All Reviews',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber.shade600,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_doctorData['rating']} (${_doctorData['totalReviews']})',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Reviews list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: reviews.length,
              itemBuilder: (context, index) {
                return _buildDetailedReviewCard(reviews[index]);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundImage: NetworkImage(review['patientImage']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['patientName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        if (review['isVerified'])
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      review['treatmentType'],
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
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review['rating']
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber.shade600,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormat('MMM d, yyyy').format(review['date']),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            review['review'],
            style: const TextStyle(
              fontSize: 14,
              height: 1.4,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 16,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Helpful (${review['helpfulCount']})',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Mark as helpful functionality
                },
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Helpful',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
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
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _buildProfileHeader(),
                          _buildStatsSection(),
                          _buildInfoSections(),
                          const SizedBox(height: 100), // Bottom padding for FAB
                        ],
                      ),
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
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/doctor/home');
          if (index == 1) context.go('/doctor/profile');
          if (index == 2) context.go('/settings');
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/doctor/profile-setup'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit),
        label: const Text('Edit Profile'),
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
            'My Profile',
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
                Icons.qr_code,
                color: Colors.blue.shade700,
              ),
            ),
            onPressed: _showQRCode,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          NetworkImage(_doctorData['profileImage']),
                    ),
                  ),
                  if (_doctorData['isVerified'])
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
                          Icons.verified,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _doctorData['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _doctorData['specialization'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          color: Colors.white.withOpacity(0.8),
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _doctorData['location'],
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade300,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${_doctorData['rating']} (${_doctorData['totalReviews']} reviews)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                    'Experience', '${_doctorData['experience']} years'),
                _buildStatItem('Patients', '${_doctorData['totalPatients']}+'),
                _buildStatItem('Fee', '\$${_doctorData['consultationFee']}'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatsCard(
              'Total Patients',
              _doctorData['totalPatients'].toString(),
              Icons.people,
              Colors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatsCard(
              'Reviews',
              _doctorData['totalReviews'].toString(),
              Icons.star,
              Colors.amber,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildStatsCard(
              'Years Active',
              DateTime.now().difference(_doctorData['joinDate']).inDays ~/ 365,
              Icons.calendar_today,
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      String title, dynamic value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
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
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
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
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSections() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 16),
          _buildReviewsSection(), // New reviews section
          const SizedBox(height: 16),
          _buildContactInfoSection(),
          const SizedBox(height: 16),
          _buildProfessionalInfoSection(),
          const SizedBox(height: 16),
          _buildAvailabilitySection(),
          const SizedBox(height: 16),
          _buildEducationSection(),
          const SizedBox(height: 16),
          _buildAchievementsSection(),
          const SizedBox(height: 16),
          _buildBioSection(),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    final reviews = _doctorData['reviews'] as List;
    final ratingBreakdown = _doctorData['ratingBreakdown'] as Map<int, int>;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.star,
                  color: Colors.amber.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Patient Reviews & Testimonials',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Rating Overview
          Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          _doctorData['rating'].toString(),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Text(
                            'out of 5',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          Icons.star,
                          color: index < _doctorData['rating'].floor()
                              ? Colors.amber.shade600
                              : Colors.grey.shade300,
                          size: 20,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Based on ${_doctorData['totalReviews']} reviews',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    for (int i = 5; i >= 1; i--)
                      _buildRatingBar(i, ratingBreakdown[i] ?? 0,
                          _doctorData['totalReviews']),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Recent Reviews
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Recent Reviews',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: _showAllReviews,
                child: const Text('View All'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Review Cards
          Column(
            children: reviews
                .take(3)
                .map((review) => _buildReviewCard(review))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingBar(int stars, int count, int total) {
    final percentage = total > 0 ? count / total : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$stars',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.star,
            color: Colors.amber.shade600,
            size: 12,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(3),
              ),
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: percentage,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.amber.shade600,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: NetworkImage(review['patientImage']),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          review['patientName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (review['isVerified'])
                          Container(
                            margin: const EdgeInsets.only(left: 6),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 1),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Verified',
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w500,
                                color: Colors.green.shade700,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Text(
                      review['treatmentType'],
                      style: TextStyle(
                        fontSize: 11,
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
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review['rating']
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.amber.shade600,
                        size: 14,
                      );
                    }),
                  ),
                  Text(
                    DateFormat('MMM d').format(review['date']),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review['review'],
            style: const TextStyle(
              fontSize: 13,
              height: 1.3,
              color: Colors.black87,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.thumb_up_outlined,
                size: 14,
                color: Colors.grey.shade600,
              ),
              const SizedBox(width: 4),
              Text(
                'Helpful (${review['helpfulCount']})',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoSection() {
    return _buildInfoCard(
      'Contact Information',
      Icons.contact_phone,
      [
        _buildInfoRow(Icons.email, 'Email', _doctorData['email']),
        _buildInfoRow(Icons.phone, 'Phone', _doctorData['phone']),
        _buildInfoRow(Icons.badge, 'License', _doctorData['licenseNumber']),
        _buildInfoRow(
            Icons.language, 'Languages', _doctorData['languages'].join(', ')),
      ],
    );
  }

  Widget _buildProfessionalInfoSection() {
    return _buildInfoCard(
      'Professional Information',
      Icons.work,
      [
        _buildInfoRow(Icons.medical_services, 'Specialization',
            _doctorData['specialization']),
        _buildInfoRow(
            Icons.timeline, 'Experience', '${_doctorData['experience']} years'),
        _buildInfoRow(Icons.attach_money, 'Consultation Fee',
            '\$${_doctorData['consultationFee']}'),
        _buildInfoRow(Icons.verified_user, 'Status',
            _doctorData['isVerified'] ? 'Verified' : 'Pending'),
      ],
    );
  }

  Widget _buildAvailabilitySection() {
    return _buildInfoCard(
      'Availability',
      Icons.schedule,
      [
        _buildInfoRow(Icons.calendar_today, 'Working Days',
            _doctorData['workingDays'].join(', ')),
        _buildInfoRow(
            Icons.access_time, 'Working Hours', _doctorData['workingHours']),
        _buildInfoRow(Icons.date_range, 'Member Since',
            DateFormat('MMMM yyyy').format(_doctorData['joinDate'])),
      ],
    );
  }

  Widget _buildEducationSection() {
    final education = _doctorData['education'] as List;
    return _buildInfoCard(
      'Education & Training',
      Icons.school,
      education.map((edu) => _buildEducationItem(edu)).toList(),
    );
  }

  Widget _buildEducationItem(Map<String, dynamic> education) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.school,
              color: Colors.blue.shade700,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  education['degree'],
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  education['institution'],
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  education['year'],
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    final achievements = _doctorData['achievements'] as List;
    return _buildInfoCard(
      'Achievements & Certifications',
      Icons.emoji_events,
      achievements
          .map((achievement) => _buildAchievementItem(achievement))
          .toList(),
    );
  }

  Widget _buildAchievementItem(String achievement) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.green.shade600,
            size: 16,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              achievement,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    return _buildInfoCard(
      'About Me',
      Icons.person,
      [
        Text(
          _doctorData['bio'],
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(String title, IconData icon, List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.blue.shade700,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey.shade600,
            size: 16,
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
