import 'package:flutter/material.dart';
import '../../models/emergency_contact.dart';
import '../../services/emergency_service.dart';
import '../../utils/app_colors.dart';

class EmergencyContactsScreen extends StatefulWidget {
  const EmergencyContactsScreen({super.key});

  @override
  State<EmergencyContactsScreen> createState() =>
      _EmergencyContactsScreenState();
}

class _EmergencyContactsScreenState extends State<EmergencyContactsScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;

  // Relationship options
  static const List<String> _relationships = [
    'spouse',
    'parent',
    'sibling',
    'friend',
    'other',
  ];

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final contacts = await _emergencyService.getEmergencyContacts();
      if (mounted) {
        setState(() {
          _contacts = contacts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showError('Failed to load contacts.');
      }
    }
  }

  Future<void> _deleteContact(EmergencyContact contact) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Remove ${contact.name} from emergency contacts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _emergencyService.deleteEmergencyContact(contact.id);
      await _loadContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contact removed.')),
        );
      }
    } catch (e) {
      _showError('Failed to delete contact.');
    }
  }

  void _showAddContactDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedRelationship = _relationships.first;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Add Emergency Contact'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone_outlined),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Phone number is required';
                      }
                      if (!RegExp(r'^\+?[0-9\s\-().]{6,20}$').hasMatch(v.trim())) {
                        return 'Enter a valid phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: selectedRelationship,
                    decoration: const InputDecoration(
                      labelText: 'Relationship',
                      prefixIcon: Icon(Icons.people_outline),
                      border: OutlineInputBorder(),
                    ),
                    items: _relationships
                        .map((r) => DropdownMenuItem(
                              value: r,
                              child: Text(
                                r[0].toUpperCase() + r.substring(1),
                              ),
                            ))
                        .toList(),
                    onChanged: (v) =>
                        setDialogState(() => selectedRelationship = v!),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                Navigator.pop(ctx);
                await _saveContact(
                  nameController.text.trim(),
                  phoneController.text.trim(),
                  selectedRelationship,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveContact(
      String name, String phone, String relationship) async {
    try {
      final contact = EmergencyContact(
        id: '',
        name: name,
        phone: phone,
        relationship: relationship,
      );
      await _emergencyService.addEmergencyContact(contact);
      await _loadContacts();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Emergency contact added.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to save contact.');
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: AppColors.error),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgMain,
      appBar: AppBar(
        title: const Text(
          'Emergency Contacts',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: AppColors.bgCard,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddContactDialog,
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        child: const Icon(Icons.add),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.contact_phone_outlined,
                size: 72, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            const Text(
              'No Contacts Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the + button to add your first emergency contact.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showAddContactDialog,
              icon: const Icon(Icons.add),
              label: const Text('Add Contact'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textLight,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _contacts.length,
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            color: AppColors.bgCard,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: AppColors.primary.withOpacity(0.15),
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ),
            title: Text(
              contact.name,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
            subtitle: Text(
              '${contact.phone}  •  ${contact.relationship}',
              style: const TextStyle(
                  fontSize: 13, color: AppColors.textSecondary),
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
              onPressed: () => _deleteContact(contact),
              tooltip: 'Remove contact',
            ),
          ),
        );
      },
    );
  }
}
