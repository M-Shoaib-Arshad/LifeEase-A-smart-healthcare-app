import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/user_provider.dart';
import '../../widgets/side_drawer.dart';
import '../../widgets/bottom_nav_bar.dart';

class HealthTrackerInputScreen extends StatefulWidget {
  const HealthTrackerInputScreen({super.key});

  @override
  State<HealthTrackerInputScreen> createState() => _HealthTrackerInputScreenState();
}

class _HealthTrackerInputScreenState extends State<HealthTrackerInputScreen> {
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  final _weightController = TextEditingController();
  final _glucoseController = TextEditingController();
  final _temperatureController = TextEditingController();
  final _oxygenController = TextEditingController();
  final _notesController = TextEditingController();

  // Selected values
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  String _selectedVitalType = 'Blood Pressure';
  String _selectedMeasurementContext = 'Resting';
  String _selectedDevice = 'Manual Entry';

  // Available options
  final List<String> _vitalTypes = [
    'Blood Pressure',
    'Heart Rate',
    'Weight',
    'Blood Glucose',
    'Temperature',
    'Oxygen Saturation',
    'Custom Measurement'
  ];

  final List<String> _measurementContexts = [
    'Resting',
    'After Exercise',
    'Before Meal',
    'After Meal',
    'Before Medication',
    'After Medication',
    'Morning',
    'Evening',
    'Other'
  ];

  final List<String> _deviceTypes = [
    'Manual Entry',
    'Smart Watch',
    'Blood Pressure Monitor',
    'Glucose Meter',
    'Smart Scale',
    'Thermometer',
    'Pulse Oximeter',
    'Other Device'
  ];

  // Healthy ranges for guidance
  final Map<String, Map<String, dynamic>> _healthyRanges = {
    'Blood Pressure': {
      'systolic': {'min': 90, 'max': 120, 'unit': 'mmHg'},
      'diastolic': {'min': 60, 'max': 80, 'unit': 'mmHg'},
    },
    'Heart Rate': {'min': 60, 'max': 100, 'unit': 'bpm'},
    'Weight': {'min': 0, 'max': 500, 'unit': 'kg'},
    'Blood Glucose': {'min': 70, 'max': 140, 'unit': 'mg/dL'},
    'Temperature': {'min': 36.1, 'max': 37.2, 'unit': '°C'},
    'Oxygen Saturation': {'min': 95, 'max': 100, 'unit': '%'},
  };

  // Show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
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
      });
    }
  }

  // Show time picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  // Get color based on value and healthy range
  Color _getHealthStatusColor(double value, double min, double max) {
    if (value < min) return Colors.blue;
    if (value > max) return Colors.red;
    return Colors.green;
  }

  // Get status text based on value and healthy range
  String _getHealthStatusText(double value, double min, double max) {
    if (value < min) return 'Below Normal';
    if (value > max) return 'Above Normal';
    return 'Normal';
  }

  // Show a snackbar with the given message
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.all(10),
      ),
    );
  }

  // Save the vital data
  void _saveVitals() {
    if (_formKey.currentState!.validate()) {
      // Here you would normally save the data to your provider or database
      // For now, we'll just show a success message and navigate back

      _showSnackBar('Health data saved successfully');

      // Navigate back to the dashboard after a short delay
      Future.delayed(const Duration(seconds: 1), () {
        context.go('/patient/health-tracker-dashboard');
      });
    }
  }

  // Reset the form
  void _resetForm() {
    _systolicController.clear();
    _diastolicController.clear();
    _heartRateController.clear();
    _weightController.clear();
    _glucoseController.clear();
    _temperatureController.clear();
    _oxygenController.clear();
    _notesController.clear();
    setState(() {
      _selectedDate = DateTime.now();
      _selectedTime = TimeOfDay.now();
      _selectedVitalType = 'Blood Pressure';
      _selectedMeasurementContext = 'Resting';
      _selectedDevice = 'Manual Entry';
    });
  }

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    _weightController.dispose();
    _glucoseController.dispose();
    _temperatureController.dispose();
    _oxygenController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Input Health Vitals'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetForm,
            tooltip: 'Reset Form',
          ),
        ],
      ),
      drawer: const SideDrawer(),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Header
              const Text(
                'Record Health Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Track your health metrics to monitor your well-being',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),

              // Measurement Type Selection
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Measurement Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        value: _selectedVitalType,
                        items: _vitalTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedVitalType = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date and Time Selection
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'When Measured',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  suffixIcon: const Icon(Icons.calendar_today),
                                ),
                                child: Text(
                                  DateFormat('MMM dd, yyyy').format(_selectedDate),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: InkWell(
                              onTap: () => _selectTime(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 12,
                                  ),
                                  suffixIcon: const Icon(Icons.access_time),
                                ),
                                child: Text(
                                  _selectedTime.format(context),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Measurement Context',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        value: _selectedMeasurementContext,
                        items: _measurementContexts.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedMeasurementContext = newValue!;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Measurement Values
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Measurement Values',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Dynamic form fields based on selected vital type
                      if (_selectedVitalType == 'Blood Pressure') ...[
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _systolicController,
                                decoration: InputDecoration(
                                  labelText: 'Systolic (mmHg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  helperText: 'Top number',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: _diastolicController,
                                decoration: InputDecoration(
                                  labelText: 'Diastolic (mmHg)',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  helperText: 'Bottom number',
                                ),
                                keyboardType: TextInputType.number,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Required';
                                  }
                                  if (double.tryParse(value) == null) {
                                    return 'Invalid number';
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  setState(() {});
                                },
                              ),
                            ),
                          ],
                        ),
                        if (_systolicController.text.isNotEmpty &&
                            _diastolicController.text.isNotEmpty &&
                            double.tryParse(_systolicController.text) != null &&
                            double.tryParse(_diastolicController.text) != null) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getHealthStatusColor(
                                    double.parse(_systolicController.text),
                                    _healthyRanges['Blood Pressure']!['systolic']['min'],
                                    _healthyRanges['Blood Pressure']!['systolic']['max'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getHealthStatusColor(
                                      double.parse(_systolicController.text),
                                      _healthyRanges['Blood Pressure']!['systolic']['min'],
                                      _healthyRanges['Blood Pressure']!['systolic']['max'],
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Systolic: ${_getHealthStatusText(
                                    double.parse(_systolicController.text),
                                    _healthyRanges['Blood Pressure']!['systolic']['min'],
                                    _healthyRanges['Blood Pressure']!['systolic']['max'],
                                  )}',
                                  style: TextStyle(
                                    color: _getHealthStatusColor(
                                      double.parse(_systolicController.text),
                                      _healthyRanges['Blood Pressure']!['systolic']['min'],
                                      _healthyRanges['Blood Pressure']!['systolic']['max'],
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getHealthStatusColor(
                                    double.parse(_diastolicController.text),
                                    _healthyRanges['Blood Pressure']!['diastolic']['min'],
                                    _healthyRanges['Blood Pressure']!['diastolic']['max'],
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: _getHealthStatusColor(
                                      double.parse(_diastolicController.text),
                                      _healthyRanges['Blood Pressure']!['diastolic']['min'],
                                      _healthyRanges['Blood Pressure']!['diastolic']['max'],
                                    ),
                                  ),
                                ),
                                child: Text(
                                  'Diastolic: ${_getHealthStatusText(
                                    double.parse(_diastolicController.text),
                                    _healthyRanges['Blood Pressure']!['diastolic']['min'],
                                    _healthyRanges['Blood Pressure']!['diastolic']['max'],
                                  )}',
                                  style: TextStyle(
                                    color: _getHealthStatusColor(
                                      double.parse(_diastolicController.text),
                                      _healthyRanges['Blood Pressure']!['diastolic']['min'],
                                      _healthyRanges['Blood Pressure']!['diastolic']['max'],
                                    ),
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],

                      if (_selectedVitalType == 'Heart Rate') ...[
                        TextFormField(
                          controller: _heartRateController,
                          decoration: InputDecoration(
                            labelText: 'Heart Rate (bpm)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Normal range: 60-100 bpm',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        if (_heartRateController.text.isNotEmpty &&
                            double.tryParse(_heartRateController.text) != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getHealthStatusColor(
                                double.parse(_heartRateController.text),
                                _healthyRanges['Heart Rate']!['min'],
                                _healthyRanges['Heart Rate']!['max'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getHealthStatusColor(
                                  double.parse(_heartRateController.text),
                                  _healthyRanges['Heart Rate']!['min'],
                                  _healthyRanges['Heart Rate']!['max'],
                                ),
                              ),
                            ),
                            child: Text(
                              'Heart Rate: ${_getHealthStatusText(
                                double.parse(_heartRateController.text),
                                _healthyRanges['Heart Rate']!['min'],
                                _healthyRanges['Heart Rate']!['max'],
                              )}',
                              style: TextStyle(
                                color: _getHealthStatusColor(
                                  double.parse(_heartRateController.text),
                                  _healthyRanges['Heart Rate']!['min'],
                                  _healthyRanges['Heart Rate']!['max'],
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],

                      if (_selectedVitalType == 'Weight') ...[
                        TextFormField(
                          controller: _weightController,
                          decoration: InputDecoration(
                            labelText: 'Weight (kg)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                        ),
                      ],

                      if (_selectedVitalType == 'Blood Glucose') ...[
                        TextFormField(
                          controller: _glucoseController,
                          decoration: InputDecoration(
                            labelText: 'Blood Glucose (mg/dL)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Normal range: 70-140 mg/dL',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        if (_glucoseController.text.isNotEmpty &&
                            double.tryParse(_glucoseController.text) != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getHealthStatusColor(
                                double.parse(_glucoseController.text),
                                _healthyRanges['Blood Glucose']!['min'],
                                _healthyRanges['Blood Glucose']!['max'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getHealthStatusColor(
                                  double.parse(_glucoseController.text),
                                  _healthyRanges['Blood Glucose']!['min'],
                                  _healthyRanges['Blood Glucose']!['max'],
                                ),
                              ),
                            ),
                            child: Text(
                              'Blood Glucose: ${_getHealthStatusText(
                                double.parse(_glucoseController.text),
                                _healthyRanges['Blood Glucose']!['min'],
                                _healthyRanges['Blood Glucose']!['max'],
                              )}',
                              style: TextStyle(
                                color: _getHealthStatusColor(
                                  double.parse(_glucoseController.text),
                                  _healthyRanges['Blood Glucose']!['min'],
                                  _healthyRanges['Blood Glucose']!['max'],
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],

                      if (_selectedVitalType == 'Temperature') ...[
                        TextFormField(
                          controller: _temperatureController,
                          decoration: InputDecoration(
                            labelText: 'Temperature (°C)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Normal range: 36.1-37.2 °C',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        if (_temperatureController.text.isNotEmpty &&
                            double.tryParse(_temperatureController.text) != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getHealthStatusColor(
                                double.parse(_temperatureController.text),
                                _healthyRanges['Temperature']!['min'],
                                _healthyRanges['Temperature']!['max'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getHealthStatusColor(
                                  double.parse(_temperatureController.text),
                                  _healthyRanges['Temperature']!['min'],
                                  _healthyRanges['Temperature']!['max'],
                                ),
                              ),
                            ),
                            child: Text(
                              'Temperature: ${_getHealthStatusText(
                                double.parse(_temperatureController.text),
                                _healthyRanges['Temperature']!['min'],
                                _healthyRanges['Temperature']!['max'],
                              )}',
                              style: TextStyle(
                                color: _getHealthStatusColor(
                                  double.parse(_temperatureController.text),
                                  _healthyRanges['Temperature']!['min'],
                                  _healthyRanges['Temperature']!['max'],
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],

                      if (_selectedVitalType == 'Oxygen Saturation') ...[
                        TextFormField(
                          controller: _oxygenController,
                          decoration: InputDecoration(
                            labelText: 'Oxygen Saturation (%)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            helperText: 'Normal range: 95-100%',
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Invalid number';
                            }
                            final number = double.parse(value);
                            if (number < 0 || number > 100) {
                              return 'Must be between 0-100%';
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {});
                          },
                        ),
                        if (_oxygenController.text.isNotEmpty &&
                            double.tryParse(_oxygenController.text) != null) ...[
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getHealthStatusColor(
                                double.parse(_oxygenController.text),
                                _healthyRanges['Oxygen Saturation']!['min'],
                                _healthyRanges['Oxygen Saturation']!['max'],
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: _getHealthStatusColor(
                                  double.parse(_oxygenController.text),
                                  _healthyRanges['Oxygen Saturation']!['min'],
                                  _healthyRanges['Oxygen Saturation']!['max'],
                                ),
                              ),
                            ),
                            child: Text(
                              'Oxygen Saturation: ${_getHealthStatusText(
                                double.parse(_oxygenController.text),
                                _healthyRanges['Oxygen Saturation']!['min'],
                                _healthyRanges['Oxygen Saturation']!['max'],
                              )}',
                              style: TextStyle(
                                color: _getHealthStatusColor(
                                  double.parse(_oxygenController.text),
                                  _healthyRanges['Oxygen Saturation']!['min'],
                                  _healthyRanges['Oxygen Saturation']!['max'],
                                ),
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ],

                      if (_selectedVitalType == 'Custom Measurement') ...[
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Measurement Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Value',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Required';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Additional Information
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Additional Information',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Measurement Device',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 12,
                          ),
                        ),
                        value: _selectedDevice,
                        items: _deviceTypes.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedDevice = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          hintText: 'Add any additional notes or observations',
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.go('/patient/health-tracker-dashboard'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveVitals,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Save Vitals'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0, // Home tab (contextual)
        onTap: (index) {
          if (index == 0) context.go('/patient/home');
          if (index == 1) context.go('/patient/profile');
          if (index == 2) context.go('/patient/appointment-history');
          if (index == 3) context.go('/settings');
        },
      ),
    );
  }
}
