import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class TelemedicineConsultationScreen extends StatefulWidget {
  const TelemedicineConsultationScreen({super.key});

  @override
  State<TelemedicineConsultationScreen> createState() => _TelemedicineConsultationScreenState();
}

class _TelemedicineConsultationScreenState extends State<TelemedicineConsultationScreen> with SingleTickerProviderStateMixin {
  bool _isMuted = false;
  bool _isCameraOff = false;
  bool _isSpeakerOn = true;
  bool _isRecording = false;
  bool _isScreenSharing = false;
  bool _isChatOpen = false;
  bool _isInfoPanelOpen = false;
  bool _isCallConnected = false;
  bool _isCallConnecting = true;
  String _callStatus = 'Connecting...';
  String _callDuration = '00:00';
  String _connectionQuality = 'Excellent';
  Timer? _callTimer;
  int _callSeconds = 0;
  final TextEditingController _noteController = TextEditingController();
  final TextEditingController _chatController = TextEditingController();
  late TabController _tabController;

  // Sample patient data
  final Map<String, dynamic> _patientData = {
    'name': 'John Doe',
    'age': 35,
    'gender': 'Male',
    'id': 'P001',
    'reason': 'Follow-up for hypertension and diabetes management',
    'lastVisit': '15 Dec 2024',
    'profileImage': 'https://randomuser.me/api/portraits/men/32.jpg',
    'vitalSigns': {
      'bloodPressure': '135/85',
      'heartRate': 72,
      'temperature': 98.6,
      'oxygenSaturation': 98,
    },
    'allergies': ['Penicillin', 'Shellfish'],
    'medications': [
      {'name': 'Lisinopril', 'dosage': '10mg', 'frequency': 'Once daily'},
      {'name': 'Metformin', 'dosage': '500mg', 'frequency': 'Twice daily'},
    ],
    'recentLabResults': [
      {'name': 'HbA1c', 'value': '7.2%', 'date': '10 Dec 2024', 'status': 'Elevated'},
      {'name': 'Blood Pressure', 'value': '135/85 mmHg', 'date': '15 Dec 2024', 'status': 'Elevated'},
    ],
  };

  // Sample chat messages
  final List<Map<String, dynamic>> _chatMessages = [];

  // Sample consultation notes
  final List<Map<String, dynamic>> _consultationNotes = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Simulate connecting and then connected after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _isCallConnecting = false;
          _isCallConnected = true;
          _callStatus = 'Connected';
          _startCallTimer();
        });
      }
    });
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _noteController.dispose();
    _chatController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _startCallTimer() {
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _callSeconds++;
          final minutes = (_callSeconds ~/ 60).toString().padLeft(2, '0');
          final seconds = (_callSeconds % 60).toString().padLeft(2, '0');
          _callDuration = '$minutes:$seconds';

          // Simulate connection quality changes
          if (_callSeconds % 30 == 0) {
            final qualities = ['Excellent', 'Good', 'Fair', 'Poor'];
            _connectionQuality = qualities[_callSeconds % 4];
          }
        });
      }
    });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOff = !_isCameraOff;
    });
  }

  void _toggleSpeaker() {
    setState(() {
      _isSpeakerOn = !_isSpeakerOn;
    });
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
      if (_isRecording) {
        _showSnackBar('Recording started');
      } else {
        _showSnackBar('Recording stopped');
      }
    });
  }

  void _toggleScreenSharing() {
    setState(() {
      _isScreenSharing = !_isScreenSharing;
      if (_isScreenSharing) {
        _showSnackBar('Screen sharing started');
      } else {
        _showSnackBar('Screen sharing stopped');
      }
    });
  }

  void _toggleChat() {
    setState(() {
      _isChatOpen = !_isChatOpen;
      _isInfoPanelOpen = false;
    });
  }

  void _toggleInfoPanel() {
    setState(() {
      _isInfoPanelOpen = !_isInfoPanelOpen;
      _isChatOpen = false;
    });
  }

  void _sendChatMessage() {
    if (_chatController.text.trim().isNotEmpty) {
      setState(() {
        _chatMessages.add({
          'sender': 'doctor',
          'message': _chatController.text.trim(),
          'timestamp': DateTime.now(),
        });
        _chatController.clear();
      });
    }
  }

  void _addConsultationNote() {
    if (_noteController.text.trim().isNotEmpty) {
      setState(() {
        _consultationNotes.add({
          'note': _noteController.text.trim(),
          'timestamp': DateTime.now(),
        });
        _noteController.clear();
      });
      _showSnackBar('Note added');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEndCallDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Consultation'),
        content: const Text('Are you sure you want to end this consultation?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showConsultationSummary();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Call', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showConsultationSummary() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Consultation Summary'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Patient: ${_patientData['name']}'),
              Text('Duration: $_callDuration'),
              Text('Date: ${DateTime.now().toString().split(' ')[0]}'),
              const SizedBox(height: 16),
              const Text('Consultation Notes:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_consultationNotes.isEmpty)
                const Text('No notes added during this consultation.')
              else
                ..._consultationNotes.map((note) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text('• ${note['note']}'),
                )),
              const SizedBox(height: 16),
              const Text('Follow-up:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  const Text('Schedule follow-up appointment'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  const Text('Send prescription'),
                ],
              ),
              Row(
                children: [
                  Checkbox(
                    value: false,
                    onChanged: (value) {},
                  ),
                  const Text('Order lab tests'),
                ],
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/doctor/home');
            },
            child: const Text('Complete & Return to Home'),
          ),
        ],
      ),
    );
  }

  void _showPrescriptionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Prescription'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Medication Name',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Dosage',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Frequency',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Duration',
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
              _showSnackBar('Prescription added');
            },
            child: const Text('Add Prescription'),
          ),
        ],
      ),
    );
  }

  void _showLabOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order Lab Tests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CheckboxListTile(
              title: const Text('Complete Blood Count (CBC)'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Comprehensive Metabolic Panel'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Lipid Panel'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('HbA1c'),
              value: false,
              onChanged: (value) {},
            ),
            CheckboxListTile(
              title: const Text('Thyroid Function Tests'),
              value: false,
              onChanged: (value) {},
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
              _showSnackBar('Lab tests ordered');
            },
            child: const Text('Order Tests'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildCallHeader(),
              Expanded(
                child: Stack(
                  children: [
                    // Main video area
                    Container(
                      width: double.infinity,
                      height: double.infinity,
                      color: Colors.black,
                      child: _isCallConnecting
                          ? _buildConnectingView()
                          : _buildVideoCallView(),
                    ),

                    // Doctor's video (self view)
                    if (_isCallConnected)
                      Positioned(
                        top: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () {
                            // Toggle between small and large view
                          },
                          child: Container(
                            width: 120,
                            height: 180,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade800,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.white, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: _isCameraOff
                                ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_off,
                                    color: Colors.white.withOpacity(0.7),
                                    size: 32,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Camera Off',
                                    style: TextStyle(
                                      color: Colors.white.withOpacity(0.7),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                'https://randomuser.me/api/portraits/women/44.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),

                    // Info panel (slide from right)
                    if (_isInfoPanelOpen)
                      Positioned(
                        top: 0,
                        right: 0,
                        bottom: 0,
                        child: _buildInfoPanel(screenSize),
                      ),

                    // Chat panel (slide from left)
                    if (_isChatOpen)
                      Positioned(
                        top: 0,
                        left: 0,
                        bottom: 0,
                        child: _buildChatPanel(screenSize),
                      ),

                    // Recording indicator
                    if (_isRecording)
                      Positioned(
                        top: 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Text(
                                'REC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // Screen sharing indicator
                    if (_isScreenSharing)
                      Positioned(
                        top: _isRecording ? 52 : 16,
                        left: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.screen_share,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(width: 6),
                              Text(
                                'Sharing Screen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              _buildCallControls(),
            ],
          ),
        ),
      ),
      drawer: const SideDrawer(),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/doctor/home');
          if (index == 1) context.go('/doctor/profile');
          if (index == 2) context.go('/doctor/appointment-management');
          if (index == 3) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildCallHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
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
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.menu,
                  color: Colors.white,
                ),
              ),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Telemedicine Consultation',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isCallConnected ? Colors.green : Colors.orange,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    _callStatus,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.timer,
                    size: 12,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _callDuration,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _connectionQuality == 'Excellent' ? Colors.green.withOpacity(0.2) :
              _connectionQuality == 'Good' ? Colors.green.withOpacity(0.2) :
              _connectionQuality == 'Fair' ? Colors.orange.withOpacity(0.2) :
              Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  _connectionQuality == 'Excellent' ? Icons.network_wifi :
                  _connectionQuality == 'Good' ? Icons.network_wifi :
                  _connectionQuality == 'Fair' ? Icons.network_wifi :
                  Icons.signal_wifi_statusbar_connected_no_internet_4,
                  size: 14,
                  color: _connectionQuality == 'Excellent' ? Colors.green :
                  _connectionQuality == 'Good' ? Colors.green :
                  _connectionQuality == 'Fair' ? Colors.orange :
                  Colors.red,
                ),
                const SizedBox(width: 4),
                Text(
                  _connectionQuality,
                  style: TextStyle(
                    fontSize: 12,
                    color: _connectionQuality == 'Excellent' ? Colors.green :
                    _connectionQuality == 'Good' ? Colors.green :
                    _connectionQuality == 'Fair' ? Colors.orange :
                    Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectingView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 60,
          backgroundImage: NetworkImage(_patientData['profileImage']),
        ),
        const SizedBox(height: 24),
        Text(
          _patientData['name'],
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Patient ID: ${_patientData['id']}',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 32),
        const CircularProgressIndicator(color: Colors.white),
        const SizedBox(height: 24),
        const Text(
          'Connecting to patient...',
          style: TextStyle(
            fontSize: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Please wait while we establish a secure connection',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVideoCallView() {
    return Stack(
      children: [
        // Patient video
        Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
          child: Image.network(
            _patientData['profileImage'],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.videocam_off,
                      color: Colors.white.withOpacity(0.7),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Patient video unavailable',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Patient info overlay
        Positioned(
          left: 16,
          bottom: 16,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundImage: NetworkImage(_patientData['profileImage']),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _patientData['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      '${_patientData['age']} years • ${_patientData['gender']}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoPanel(Size screenSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: screenSize.width * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(-5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade100),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundImage: NetworkImage(_patientData['profileImage']),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _patientData['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_patientData['age']} years • ${_patientData['gender']} • ID: ${_patientData['id']}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleInfoPanel,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.blue.shade100),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Consultation Reason:',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _patientData['reason'],
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Last Visit: ${_patientData['lastVisit']}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            labelColor: Colors.blue.shade700,
            unselectedLabelColor: Colors.grey.shade600,
            indicatorColor: Colors.blue.shade700,
            tabs: const [
              Tab(text: 'Vitals'),
              Tab(text: 'Medications'),
              Tab(text: 'Notes'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildVitalsTab(),
                _buildMedicationsTab(),
                _buildNotesTab(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showPrescriptionDialog,
                    icon: const Icon(Icons.medication, size: 16),
                    label: const Text('Prescribe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _showLabOrderDialog,
                    icon: const Icon(Icons.science, size: 16),
                    label: const Text('Lab Tests'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVitalsTab() {
    final vitals = _patientData['vitalSigns'];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Vital Signs',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildVitalCard(
            'Blood Pressure',
            vitals['bloodPressure'],
            Icons.favorite,
            Colors.red,
            'mmHg',
          ),
          _buildVitalCard(
            'Heart Rate',
            vitals['heartRate'].toString(),
            Icons.monitor_heart,
            Colors.pink,
            'bpm',
          ),
          _buildVitalCard(
            'Temperature',
            vitals['temperature'].toString(),
            Icons.thermostat,
            Colors.orange,
            '°F',
          ),
          _buildVitalCard(
            'Oxygen Saturation',
            vitals['oxygenSaturation'].toString(),
            Icons.air,
            Colors.blue,
            '%',
          ),
          const SizedBox(height: 16),
          const Text(
            'Recent Lab Results',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._patientData['recentLabResults'].map<Widget>((lab) {
            final isNormal = lab['status'] == 'Normal';
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isNormal ? Colors.green.shade50 : Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: isNormal ? Colors.green.shade200 : Colors.red.shade200,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lab['name'],
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          lab['value'],
                          style: TextStyle(
                            color: isNormal ? Colors.green.shade700 : Colors.red.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isNormal ? Colors.green.shade100 : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          lab['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isNormal ? Colors.green.shade700 : Colors.red.shade700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        lab['date'],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }).toList(),
          if (_patientData['allergies'].isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning, color: Colors.red.shade700, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Allergies',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _patientData['allergies'].map<Widget>((allergy) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          allergy,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVitalCard(String title, String value, IconData icon, Color color, String unit) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$value $unit',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color.shade700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicationsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _patientData['medications'].length,
      itemBuilder: (context, index) {
        final medication = _patientData['medications'][index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.medication, color: Colors.blue.shade700, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication['name'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${medication['dosage']} • ${medication['frequency']}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () {
                  // Edit medication
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildNotesTab() {
    return Column(
      children: [
        Expanded(
          child: _consultationNotes.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.note_alt,
                  size: 48,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(height: 16),
                Text(
                  'No consultation notes yet',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add notes using the field below',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: _consultationNotes.length,
            itemBuilder: (context, index) {
              final note = _consultationNotes[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      note['note'],
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${note['timestamp'].hour.toString().padLeft(2, '0')}:${note['timestamp'].minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    hintText: 'Add consultation note...',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  maxLines: 2,
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _addConsultationNote,
                icon: const Icon(Icons.send),
                color: Colors.blue,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildChatPanel(Size screenSize) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: screenSize.width * 0.75,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(5, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              border: Border(
                bottom: BorderSide(color: Colors.green.shade100),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.chat, color: Colors.green.shade700),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Chat with Patient',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _toggleChat,
                ),
              ],
            ),
          ),
          Expanded(
            child: _chatMessages.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 48,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No messages yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start the conversation with your patient',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chatMessages.length,
              itemBuilder: (context, index) {
                final message = _chatMessages[index];
                final isFromDoctor = message['sender'] == 'doctor';

                return Align(
                  alignment: isFromDoctor ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isFromDoctor ? Colors.green.shade100 : Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    constraints: BoxConstraints(
                      maxWidth: screenSize.width * 0.5,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message['message'],
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${message['timestamp'].hour.toString().padLeft(2, '0')}:${message['timestamp'].minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade600,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _chatController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: _sendChatMessage,
                  icon: const Icon(Icons.send),
                  color: Colors.green,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.blue.shade900,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildControlButton(
            icon: _isMuted ? Icons.mic_off : Icons.mic,
            label: _isMuted ? 'Unmute' : 'Mute',
            onPressed: _toggleMute,
            isActive: _isMuted,
          ),
          _buildControlButton(
            icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
            label: _isCameraOff ? 'Camera On' : 'Camera Off',
            onPressed: _toggleCamera,
            isActive: _isCameraOff,
          ),
          _buildControlButton(
            icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_off,
            label: _isSpeakerOn ? 'Speaker' : 'Speaker Off',
            onPressed: _toggleSpeaker,
            isActive: !_isSpeakerOn,
          ),
          _buildControlButton(
            icon: Icons.chat,
            label: 'Chat',
            onPressed: _toggleChat,
            isActive: _isChatOpen,
          ),
          _buildControlButton(
            icon: Icons.info,
            label: 'Info',
            onPressed: _toggleInfoPanel,
            isActive: _isInfoPanelOpen,
          ),
          _buildControlButton(
            icon: _isRecording ? Icons.stop : Icons.fiber_manual_record,
            label: _isRecording ? 'Stop' : 'Record',
            onPressed: _toggleRecording,
            isActive: _isRecording,
            activeColor: Colors.red,
          ),
          _buildControlButton(
            icon: _isScreenSharing ? Icons.stop_screen_share : Icons.screen_share,
            label: _isScreenSharing ? 'Stop' : 'Share',
            onPressed: _toggleScreenSharing,
            isActive: _isScreenSharing,
            activeColor: Colors.green,
          ),
          _buildControlButton(
            icon: Icons.call_end,
            label: 'End',
            onPressed: _showEndCallDialog,
            backgroundColor: Colors.red,
            textColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    bool isActive = false,
    Color? activeColor,
    Color? backgroundColor,
    Color? textColor,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isActive
                ? activeColor ?? Colors.white
                : backgroundColor ?? Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(icon),
            onPressed: onPressed,
            color: isActive
                ? Colors.white
                : textColor ?? Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.white.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

extension on Color {
  get shade700 => null;
}