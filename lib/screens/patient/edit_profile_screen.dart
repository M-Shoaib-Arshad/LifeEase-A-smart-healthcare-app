import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _addressController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  bool _isLoading = false;
  bool _isSaving = false;
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _profileImagePath;
  File? _selectedImage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<String> _genderOptions = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProfileData();
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

  Future<void> _loadProfileData() async {
    setState(() => _isLoading = true);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      
      setState(() {
        _nameController.text = prefs.getString('patient_name') ?? 
            userProvider.profile?.name ?? '';
        _emailController.text = userProvider.profile?.email ?? '';
        _phoneController.text = prefs.getString('patient_phone') ?? 
            userProvider.profile?.phone ?? '';
        _dobController.text = prefs.getString('patient_dob') ?? '';
        _addressController.text = prefs.getString('patient_address') ?? 
            userProvider.profile?.address ?? '';
        _medicalHistoryController.text = prefs.getString('patient_medical_history') ?? '';
        _selectedGender = prefs.getString('patient_gender');
        _profileImagePath = prefs.getString('patient_profile_image');
        
        if (_dobController.text.isNotEmpty) {
          try {
            final parts = _dobController.text.split('/');
            if (parts.length == 3) {
              _selectedDate = DateTime(
                int.parse(parts[2]),
                int.parse(parts[0]),
                int.parse(parts[1]),
              );
            }
          } catch (_) {}
        }
        
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        _showSnackBar('Failed to load profile data', isError: true);
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = "${picked.month.toString().padLeft(2, '0')}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
          _profileImagePath = image.path;
        });
      }
    } catch (e) {
      _showSnackBar('Failed to pick image', isError: true);
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Change Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  color: const Color(0xFF667eea),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  color: const Color(0xFF764ba2),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                if (_profileImagePath != null || _selectedImage != null)
                  _buildImageOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    color: Colors.red,
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _profileImagePath = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save to SharedPreferences
      await prefs.setString('patient_name', _nameController.text.trim());
      await prefs.setString('patient_phone', _phoneController.text.trim());
      await prefs.setString('patient_dob', _dobController.text);
      await prefs.setString('patient_gender', _selectedGender ?? '');
      await prefs.setString('patient_address', _addressController.text.trim());
      await prefs.setString('patient_medical_history', _medicalHistoryController.text.trim());
      
      if (_profileImagePath != null) {
        await prefs.setString('patient_profile_image', _profileImagePath!);
      } else {
        await prefs.remove('patient_profile_image');
      }

      // Try to update via UserProvider if user is authenticated
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      if (userProvider.isAuthenticated) {
        try {
          await userProvider.updateProfile(
            name: _nameController.text.trim(),
            phone: _phoneController.text.trim(),
            dateOfBirth: _selectedDate,
            address: _addressController.text.trim(),
          );
        } catch (_) {
          // Continue even if Firebase update fails - local data is saved
        }
      }

      setState(() => _isSaving = false);
      
      if (mounted) {
        _showSnackBar('Profile updated successfully!');
        // Navigate back to profile view
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            context.go('/patient/profile');
          }
        });
      }
    } catch (e) {
      setState(() => _isSaving = false);
      if (mounted) {
        _showSnackBar('Failed to save profile', isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red : const Color(0xFF667eea),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showDiscardDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange),
            SizedBox(width: 12),
            Text('Discard Changes?'),
          ],
        ),
        content: const Text(
          'You have unsaved changes. Are you sure you want to discard them?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/patient/profile');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _medicalHistoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Edit Profile',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: _showDiscardDialog,
        ),
        actions: [
          if (!_isSaving)
            TextButton(
              onPressed: _saveProfile,
              child: const Text(
                'Save',
                style: TextStyle(
                  color: Color(0xFF667eea),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
        ],
      ),
      drawer: const SideDrawer(),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF667eea),
              ),
            )
          : FadeTransition(
              opacity: _fadeAnimation,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile Photo Section
                      _buildProfilePhotoSection(),
                      
                      const SizedBox(height: 32),

                      // Personal Information Section
                      _buildSectionCard(
                        title: 'Personal Information',
                        icon: Icons.person_outline,
                        children: [
                          _buildInputField(
                            controller: _nameController,
                            label: 'Full Name',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your name';
                              }
                              if (value.trim().length < 2) {
                                return 'Name must be at least 2 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _emailController,
                            label: 'Email Address',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            enabled: false, // Email is typically not editable
                            helperText: 'Email cannot be changed',
                          ),
                          const SizedBox(height: 20),
                          _buildInputField(
                            controller: _phoneController,
                            label: 'Phone Number',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value != null && value.isNotEmpty) {
                                if (value.length < 10) {
                                  return 'Please enter a valid phone number';
                                }
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                          _buildDateField(),
                          const SizedBox(height: 20),
                          _buildGenderDropdown(),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Address Section
                      _buildSectionCard(
                        title: 'Address',
                        icon: Icons.location_on_outlined,
                        children: [
                          _buildTextAreaField(
                            controller: _addressController,
                            label: 'Full Address',
                            hint: 'Enter your complete address...',
                            icon: Icons.home_outlined,
                            maxLines: 3,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Medical Information Section
                      _buildSectionCard(
                        title: 'Medical Information',
                        icon: Icons.medical_services_outlined,
                        children: [
                          _buildTextAreaField(
                            controller: _medicalHistoryController,
                            label: 'Medical History',
                            hint: 'List any allergies, chronic conditions, medications, or previous surgeries...',
                            icon: Icons.history,
                            maxLines: 4,
                          ),
                        ],
                      ),

                      const SizedBox(height: 32),

                      // Save Button
                      _buildSaveButton(),

                      const SizedBox(height: 16),

                      // Cancel Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: _isSaving ? null : _showDiscardDialog,
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Color(0xFF667eea)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF667eea),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Privacy Notice
                      _buildPrivacyNotice(),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) context.go('/patient/home');
          if (index == 1) context.go('/patient/profile');
          if (index == 2) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildProfilePhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF667eea).withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (_profileImagePath != null
                          ? FileImage(File(_profileImagePath!))
                          : null),
                  child: _selectedImage == null && _profileImagePath == null
                      ? Icon(
                          Icons.person,
                          size: 60,
                          color: Colors.grey[400],
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: GestureDetector(
                  onTap: _showImagePickerOptions,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                      ),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Tap to change photo',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF667eea).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF667eea),
                  size: 22,
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
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    bool enabled = true,
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.black87 : Colors.grey[600],
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? const Color(0xFF667eea) : Colors.grey[400],
            ),
            helperText: helperText,
            helperStyle: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
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
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey[50] : Colors.grey[100],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: () => _selectDate(context),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.calendar_today, color: Color(0xFF667eea)),
            suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
            hintText: 'Select your date of birth',
            hintStyle: TextStyle(color: Colors.grey[400]),
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
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF667eea)),
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
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          hint: Text(
            'Select your gender',
            style: TextStyle(color: Colors.grey[400]),
          ),
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildTextAreaField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 4,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.only(bottom: (maxLines - 1) * 24.0),
              child: Icon(icon, color: const Color(0xFF667eea)),
            ),
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
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
              borderSide: const BorderSide(color: Color(0xFF667eea), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF667eea),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 2,
          shadowColor: const Color(0xFF667eea).withOpacity(0.3),
        ),
        child: _isSaving
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save),
                  SizedBox(width: 8),
                  Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildPrivacyNotice() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: Colors.blue[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Your personal information is encrypted and securely stored. We only use it to provide better healthcare services.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
