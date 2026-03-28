import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../models/emergency_contact.dart';
import '../../services/emergency_service.dart';
import '../../utils/app_colors.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  final EmergencyService _emergencyService = EmergencyService();
  List<EmergencyContact> _contacts = [];
  bool _isLoading = true;
  bool _isSendingSOS = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
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
        _showError('Failed to load emergency contacts.');
      }
    }
  }

  Future<void> _callEmergencyServices() async {
    try {
      await _emergencyService.callEmergencyServices();
    } catch (e) {
      _showError('Could not place call. Please dial 112 manually.');
    }
  }

  Future<void> _sendSOS() async {
    if (_contacts.isEmpty) {
      _showError(
          'No emergency contacts saved. Please add contacts before sending SOS.');
      return;
    }
    setState(() => _isSendingSOS = true);
    try {
      await _emergencyService.sendSOSWithLocation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('SOS sent to all emergency contacts!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      _showError('Failed to send SOS. Please try again.');
    } finally {
      if (mounted) setState(() => _isSendingSOS = false);
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
          'Emergency SOS',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.red,
        foregroundColor: AppColors.textLight,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Emergency call banner ─────────────────────────────────
            _buildEmergencyCallCard(),

            const SizedBox(height: 20),

            // ── Send SOS with location ────────────────────────────────
            _buildSendSOSCard(),

            const SizedBox(height: 28),

            // ── Emergency contacts section ────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Emergency Contacts',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                TextButton.icon(
                  onPressed: () =>
                      context.push('/patient/emergency-contacts').then((_) => _loadContacts()),
                  icon: const Icon(Icons.edit, size: 18),
                  label: const Text('Manage'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_contacts.isEmpty)
              _buildNoContactsCard()
            else
              ..._contacts.map((c) => _buildContactCard(c)),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyCallCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _callEmergencyServices,
          borderRadius: BorderRadius.circular(20),
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 28, horizontal: 24),
            child: Column(
              children: [
                Icon(Icons.call, color: AppColors.textLight, size: 48),
                SizedBox(height: 12),
                Text(
                  'Call Emergency Services',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Tap to dial 112',
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSendSOSCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.accentCoral.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.location_on,
                      color: AppColors.accentCoral, size: 24),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Send SOS with Location',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Sends your GPS location via SMS to all contacts',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSendingSOS ? null : _sendSOS,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentCoral,
                  foregroundColor: AppColors.textLight,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isSendingSOS
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.textLight,
                        ),
                      )
                    : const Text(
                        'Send SOS Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoContactsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          const Icon(Icons.person_add_alt_1,
              size: 48, color: AppColors.textSecondary),
          const SizedBox(height: 12),
          const Text(
            'No emergency contacts yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Add contacts so SOS messages can reach them.',
            style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () =>
                context.push('/patient/emergency-contacts').then((_) => _loadContacts()),
            icon: const Icon(Icons.add),
            label: const Text('Add Contact'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactCard(EmergencyContact contact) {
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
          child:
              const Icon(Icons.person, color: AppColors.primary),
        ),
        title: Text(
          contact.name,
          style: const TextStyle(
              fontWeight: FontWeight.w600, color: AppColors.textPrimary),
        ),
        subtitle: Text(
          '${contact.phone}  •  ${contact.relationship}',
          style:
              const TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.call, color: Colors.green),
          onPressed: () => _emergencyService.callContact(contact),
          tooltip: 'Call ${contact.name}',
        ),
      ),

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency')),
      body: const Center(child: Text('Emergency Placeholder')),
    );
  }
}
