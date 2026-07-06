import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _biometricUnlock = false;
  bool _automaticSync = true;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        children: [
          _buildSectionHeader('Notifications Configuration'),
          SwitchListTile(
            title: const Text('Push Notifications'),
            subtitle: const Text('Receive alerts for ticket status changes on your device'),
            value: _pushNotifications,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _pushNotifications = val;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Email Alerts'),
            subtitle: const Text('Get weekly activity updates and comment summaries'),
            value: _emailAlerts,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _emailAlerts = val;
              });
            },
          ),
          const Divider(),
          
          _buildSectionHeader('Security & Biometrics'),
          SwitchListTile(
            title: const Text('Biometric Login'),
            subtitle: const Text('Use FaceID / Fingerprint verification to sign in'),
            value: _biometricUnlock,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _biometricUnlock = val;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.password_rounded),
            title: const Text('Change Password'),
            subtitle: const Text('Update your system authentication password'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Password change simulation triggered')),
              );
            },
          ),
          const Divider(),

          _buildSectionHeader('Synchronization & Network'),
          SwitchListTile(
            title: const Text('Auto Sync Database'),
            subtitle: const Text('Sync in-memory changes with remote endpoint when online'),
            value: _automaticSync,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() {
                _automaticSync = val;
              });
            },
          ),
          ListTile(
            leading: const Icon(Icons.cloud_download_outlined),
            title: const Text('Manual Sync Now'),
            subtitle: const Text('Force pull update records from server database'),
            trailing: const Icon(Icons.sync_rounded),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Database sync completed successfully!')),
              );
            },
          ),
          const Divider(),

          _buildSectionHeader('Application Information'),
          const ListTile(
            leading: Icon(Icons.info_outline_rounded),
            title: Text('Software Version'),
            trailing: Text('v2.0.0', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          const ListTile(
            leading: Icon(Icons.business_outlined),
            title: Text('Organization License'),
            trailing: Text('Commercial Enterprise'),
          ),
          ListTile(
            leading: const Icon(Icons.delete_forever_outlined, color: Colors.red),
            title: const Text('Factory Reset Database', style: TextStyle(color: Colors.red)),
            subtitle: const Text('Clear all custom logs and tickets from device storage'),
            onTap: () {
              _showResetDialog();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Application Database?'),
          content: const Text(
            'This action will clear all tickets, discussion room comments, and timeline tracking logs in memory. This cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(ticketProvider).clearAllTickets();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Application memory has been reset successfully.')),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Reset All', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
