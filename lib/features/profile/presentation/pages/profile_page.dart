import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/auth/presentation/pages/login_page.dart';
import 'settings_page.dart';

class ProfilePage extends ConsumerWidget {
  final bool isTab;

  const ProfilePage({super.key, this.isTab = false});

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to sign out of your account?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                authProvider.logout();
                // Clear stack and push login
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Log Out'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderVal = ref.watch(authProvider);
    final user = authProviderVal.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    String roleName = '';
    Color roleBg = Colors.grey;
    if (user.role == 'Admin') {
      roleName = 'System Administrator';
      roleBg = Colors.redAccent.shade700;
    } else if (user.role == 'Helpdesk') {
      roleName = 'Support Technician';
      roleBg = Colors.amber.shade700;
    } else {
      roleName = 'Employee (Pelapor)';
      roleBg = Theme.of(context).colorScheme.primary;
    }

    final profileContent = SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header Profile Details Card
          Container(
            padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 54,
                      backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      backgroundImage: user.avatarUrl != null ? NetworkImage(user.avatarUrl!) : null,
                      child: user.avatarUrl == null
                          ? Text(
                              user.fullName.substring(0, 1).toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 36, color: Colors.white),
                            )
                          : null,
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: isDark ? const Color(0xFF1E293B) : Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.edit_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Details
                Text(
                  user.fullName,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Role Chip badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: roleBg.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(color: roleBg.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    roleName,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: roleBg,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Settings Section Title
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Application Settings',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),

          // Settings Options Card List
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                // Dark Mode Switch Row
                ListTile(
                  leading: Icon(
                    authProviderVal.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                    color: Colors.purple,
                  ),
                  title: const Text('Theme Settings'),
                  subtitle: Text(
                    authProviderVal.isDarkMode ? 'Dark Mode Active' : 'Light Mode Active',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: Switch.adaptive(
                    value: authProviderVal.isDarkMode,
                    onChanged: (val) {
                      authProviderVal.toggleTheme(val);
                    },
                    activeThumbColor: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const Divider(height: 1, indent: 56, thickness: 0.5),

                ListTile(
                  leading: const Icon(Icons.settings_outlined, color: Colors.blue),
                  title: const Text('Advanced Settings'),
                  subtitle: const Text('Manage notifications, sync, and database storage', style: TextStyle(fontSize: 12)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Support Section Title
          const Padding(
            padding: EdgeInsets.only(left: 8.0, bottom: 8.0),
            child: Text(
              'Help & Support',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),

          // Support Card List
          Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.help_outline_rounded, color: Colors.teal),
                  title: const Text('Help Center'),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                  onTap: () {},
                ),
                const Divider(height: 1, indent: 56, thickness: 0.5),
                ListTile(
                  leading: const Icon(Icons.info_outline_rounded, color: Colors.blueGrey),
                  title: const Text('App Information & License'),
                  subtitle: const Text('Version 1.0.0 (Build 1)', style: TextStyle(fontSize: 11)),
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 36),

          ElevatedButton.icon(
            onPressed: () => _handleLogout(context, authProviderVal),
            icon: const Icon(Icons.logout_rounded, size: 20),
            label: const Text('Sign Out Account'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shadowColor: Colors.red.withValues(alpha: 0.15),
              elevation: 2,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );

    if (isTab) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('My Settings'),
          automaticallyImplyLeading: false,
        ),
        body: profileContent,
      );
    } else {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
        ),
        body: profileContent,
      );
    }
  }
}
