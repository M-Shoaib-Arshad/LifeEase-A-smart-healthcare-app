import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class MedicationReminderSetupScreen extends StatefulWidget {
  const MedicationReminderSetupScreen({super.key});

  @override
  State<MedicationReminderSetupScreen> createState() => _MedicationReminderSetupScreenState();
}

class _MedicationReminderSetupScreenState extends State<MedicationReminderSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationController = TextEditingController();
  final _dosageController = TextEditingController();
  final _instructionsController = TextEditingController();

  String _selectedFrequency = 'Daily';
  String _selectedMedicationType = 'Tablet';
  TimeOfDay _selectedTime = TimeOfDay.now();
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _withFood = false;
  bool _beforeMeal = false;
  bool _enableReminder = true;
  int _reminderMinutes = 15;

  final List<String> _frequencies = ['Daily', 'Twice Daily', 'Three Times Daily', 'Weekly', 'As Needed'];
  final List<String> _medicationTypes = ['Tablet', 'Capsule', 'Liquid', 'Injection', 'Drops', 'Inhaler', 'Cream'];
  final List<int> _reminderOptions = [5, 10, 15, 30, 60];

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Medication Setup'),
        backgroundColor: Colors.blue[600],
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelpDialog(),
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
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
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.medication,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Set Up Medication',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Never miss your medication again',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Medication Information Section
              _buildSectionCard(
                title: 'Medication Information',
                icon: Icons.info_outline,
                children: [
                  _buildTextFormField(
                    controller: _medicationController,
                    label: 'Medication Name',
                    hint: 'e.g., Aspirin, Metformin',
                    icon: Icons.medication,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter medication name';
                      }
                      return null;
                    },
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: _buildTextFormField(
                          controller: _dosageController,
                          label: 'Dosage',
                          hint: 'e.g., 500mg',
                          icon: Icons.straighten,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter dosage';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          value: _selectedMedicationType,
                          label: 'Type',
                          items: _medicationTypes,
                          onChanged: (value) {
                            setState(() {
                              _selectedMedicationType = value!;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  _buildTextFormField(
                    controller: _instructionsController,
                    label: 'Instructions (Optional)',
                    hint: 'Special instructions from your doctor',
                    icon: Icons.note,
                    maxLines: 2,
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Schedule Section
              _buildSectionCard(
                title: 'Schedule',
                icon: Icons.schedule,
                children: [
                  _buildDropdownField(
                    value: _selectedFrequency,
                    label: 'Frequency',
                    items: _frequencies,
                    onChanged: (value) {
                      setState(() {
                        _selectedFrequency = value!;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  _buildTimeSelector(),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: _buildDateSelector(
                          label: 'Start Date',
                          date: _startDate,
                          onTap: () => _selectStartDate(),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDateSelector(
                          label: 'End Date (Optional)',
                          date: _endDate,
                          onTap: () => _selectEndDate(),
                          optional: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Meal Instructions Section
              _buildSectionCard(
                title: 'Meal Instructions',
                icon: Icons.restaurant,
                children: [
                  _buildSwitchTile(
                    title: 'Take with food',
                    subtitle: 'This medication should be taken with meals',
                    value: _withFood,
                    onChanged: (value) {
                      setState(() {
                        _withFood = value;
                        if (value) _beforeMeal = false;
                      });
                    },
                  ),

                  _buildSwitchTile(
                    title: 'Take before meal',
                    subtitle: 'This medication should be taken on empty stomach',
                    value: _beforeMeal,
                    onChanged: (value) {
                      setState(() {
                        _beforeMeal = value;
                        if (value) _withFood = false;
                      });
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Reminder Settings Section
              _buildSectionCard(
                title: 'Reminder Settings',
                icon: Icons.notifications,
                children: [
                  _buildSwitchTile(
                    title: 'Enable Reminders',
                    subtitle: 'Get notified when it\'s time to take your medication',
                    value: _enableReminder,
                    onChanged: (value) {
                      setState(() {
                        _enableReminder = value;
                      });
                    },
                  ),

                  if (_enableReminder) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Remind me $_reminderMinutes minutes before',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _reminderOptions.map((minutes) {
                        return ChoiceChip(
                          label: Text('${minutes}m'),
                          selected: _reminderMinutes == minutes,
                          onSelected: (selected) {
                            if (selected) {
                              setState(() {
                                _reminderMinutes = minutes;
                              });
                            }
                          },
                          selectedColor: Colors.blue[100],
                          labelStyle: TextStyle(
                            color: _reminderMinutes == minutes
                                ? Colors.blue[700]
                                : Colors.grey[600],
                            fontWeight: _reminderMinutes == minutes
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _resetForm(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: Colors.grey[400]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () => _saveReminder(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.save, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Save Reminder',
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

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) context.go('/patient/home');
          if (index == 1) context.go('/patient/profile');
          if (index == 2) context.go('/patient/appointment-history');
          if (index == 3) context.go('/settings');
        },
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
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
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
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
          borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item),
        );
      }).toList(),
    );
  }

  Widget _buildTimeSelector() {
    return InkWell(
      onTap: () => _selectTime(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Row(
          children: [
            Icon(Icons.access_time, color: Colors.blue[600]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Reminder Time',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _selectedTime.format(context),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.keyboard_arrow_down, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    bool optional = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[50],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              date != null
                  ? '${date.day}/${date.month}/${date.year}'
                  : optional ? 'Not set' : 'Select date',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: date != null ? Colors.black : Colors.grey[500],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required void Function(bool) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.blue[600],
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate.add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  void _resetForm() {
    setState(() {
      _medicationController.clear();
      _dosageController.clear();
      _instructionsController.clear();
      _selectedFrequency = 'Daily';
      _selectedMedicationType = 'Tablet';
      _selectedTime = TimeOfDay.now();
      _startDate = DateTime.now();
      _endDate = null;
      _withFood = false;
      _beforeMeal = false;
      _enableReminder = true;
      _reminderMinutes = 15;
    });
  }

  void _saveReminder() {
    if (_formKey.currentState!.validate()) {
      // Here you would typically save the medication reminder to your database
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 12),
              Text('${_medicationController.text} reminder saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
      context.go('/patient/home');
    }
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Medication Setup Help'),
            ],
          ),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('• Enter the exact name as prescribed by your doctor'),
              SizedBox(height: 8),
              Text('• Include the dosage amount and unit (mg, ml, etc.)'),
              SizedBox(height: 8),
              Text('• Set reminders to help you stay on track'),
              SizedBox(height: 8),
              Text('• Choose meal instructions if specified'),
              SizedBox(height: 8),
              Text('• You can always edit or delete reminders later'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Got it'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _medicationController.dispose();
    _dosageController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }
}
