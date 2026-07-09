import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/core/theme/app_theme.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _pushNotifications = true;
  bool _emailAlerts = true;
  bool _biometricUnlock = false;

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reset Application?'),
          content: const Text(
            'This will clear all tickets, comments, and timeline data. This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.statusOpen, AppTheme.statusOpen.withValues(alpha: 0.85)],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton(
                onPressed: () {
                  ref.read(ticketProvider).clearAllTickets();
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Application reset successfully.')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(100, 42),
                ),
                child: const Text('Reset All'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showSecurityBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF444651) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Security Settings',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setSheetState) {
                  return SwitchListTile.adaptive(
                    secondary: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.fingerprint_rounded, color: Color(0xFF8B5CF6)),
                    ),
                    title: const Text('Biometric Login', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                    subtitle: const Text('Use FaceID / Fingerprint', style: TextStyle(fontSize: 12)),
                    value: _biometricUnlock,
                    onChanged: (val) {
                      setState(() => _biometricUnlock = val);
                      setSheetState(() => _biometricUnlock = val);
                    },
                    contentPadding: EdgeInsets.zero,
                  );
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.statusAssigned.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.password_rounded, color: AppTheme.statusAssigned),
                ),
                title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Update authentication password', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password change simulation triggered')),
                  );
                },
              ),
              const Divider(height: 24),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.statusOpen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_forever_outlined, color: AppTheme.statusOpen),
                ),
                title: const Text('Factory Reset Database', style: TextStyle(color: AppTheme.statusOpen, fontWeight: FontWeight.w600, fontSize: 14)),
                subtitle: const Text('Clear all cached tickets and activities', style: TextStyle(fontSize: 12)),
                trailing: const Icon(Icons.chevron_right_rounded, color: AppTheme.statusOpen),
                contentPadding: EdgeInsets.zero,
                onTap: () {
                  Navigator.of(context).pop();
                  _showResetDialog();
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showNotificationBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: AppTheme.surfaceColor(context),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Notification Settings',
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary(context),
                ),
              ),
              const SizedBox(height: 16),
              StatefulBuilder(
                builder: (context, setSheetState) {
                  return Column(
                    children: [
                      SwitchListTile.adaptive(
                        title: const Text('Push Notifications', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Alerts for ticket status changes', style: TextStyle(fontSize: 12)),
                        value: _pushNotifications,
                        onChanged: (val) {
                          setState(() => _pushNotifications = val);
                          setSheetState(() => _pushNotifications = val);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                      const Divider(),
                      SwitchListTile.adaptive(
                        title: const Text('Email Alerts', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                        subtitle: const Text('Weekly activity updates', style: TextStyle(fontSize: 12)),
                        value: _emailAlerts,
                        onChanged: (val) {
                          setState(() => _emailAlerts = val);
                          setSheetState(() => _emailAlerts = val);
                        },
                        contentPadding: EdgeInsets.zero,
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authProvider);
    final user = authState.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final logoutBgColor = isDark 
        ? const Color(0xFFEF4444).withValues(alpha: 0.1) 
        : const Color(0xFFFFDAD6);
    final logoutTextColor = isDark 
        ? const Color(0xFFFCA5A5) 
        : const Color(0xFF93000A);
    final logoutBorderColor = isDark 
        ? const Color(0xFFEF4444).withValues(alpha: 0.2) 
        : const Color(0xFFBA1A1A).withValues(alpha: 0.1);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Helpdesk Central',
          style: GoogleFonts.hankenGrotesk(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: AppTheme.surfaceColor(context),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: Icon(Icons.menu, color: isDark ? Colors.white : AppTheme.primaryNavy),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Center(
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2), width: 1.5),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: user.avatarUrl != null
                      ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                      : CircleAvatar(
                          backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                          child: Text(
                            user.avatarLetter,
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                          ),
                        ),
                ),
              ),
            ),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        children: [
          // 1. Profile Header Section
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3).withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(40),
                    child: user.avatarUrl != null
                        ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                        : CircleAvatar(
                            backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                            child: Text(
                              user.avatarLetter,
                              style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.primaryNavy),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName.isNotEmpty ? user.fullName : user.username,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user.role == 'Admin' 
                            ? 'Senior Helpdesk Administrator' 
                            : user.role == 'Helpdesk' 
                                ? 'Helpdesk Analyst' 
                                : 'Registered Helpdesk User',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: AppTheme.textSecondary(context),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryNavy,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          'ID: HD-${user.id.substring(0, 4).toUpperCase()}',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. General Preferences Section
          _buildSectionHeader('General Preferences'),
          const SizedBox(height: 8),
          
          // Dark Mode Switch
          _buildSwitchTile(
            icon: Icons.dark_mode_outlined,
            iconColor: AppTheme.primaryNavy,
            title: 'Dark Mode',
            subtitle: 'Switch between light and dark themes',
            value: isDark,
            onChanged: (val) => ref.read(authProvider).toggleTheme(val),
          ),

          // Language Selection
          _buildActionTile(
            icon: Icons.translate_rounded,
            iconColor: AppTheme.primaryNavy,
            title: 'Language',
            subtitle: 'English (US)',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Language settings simulation triggered')),
              );
            },
          ),

          // Notifications Pref
          _buildActionTile(
            icon: Icons.notifications_active_outlined,
            iconColor: AppTheme.primaryNavy,
            title: 'Notifications',
            subtitle: 'Manage push and email alerts',
            onTap: _showNotificationBottomSheet,
          ),
          const SizedBox(height: 24),

          // 3. Security & Account Section
          _buildSectionHeader('Security & Account'),
          const SizedBox(height: 8),

          // Internal Portal
          _buildActionTile(
            icon: Icons.library_books_outlined,
            iconColor: AppTheme.primaryNavy,
            title: 'Internal Portal',
            subtitle: 'Access agent documentation',
            trailing: Icon(Icons.open_in_new_rounded, color: AppTheme.textSecondary(context), size: 20),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Opening agent documentation portal...')),
              );
            },
          ),

          // Security
          _buildActionTile(
            icon: Icons.lock_reset_rounded,
            iconColor: AppTheme.primaryNavy,
            title: 'Security',
            subtitle: 'Password and MFA settings',
            onTap: _showSecurityBottomSheet,
          ),

          // 4. Logout Action
          Container(
            margin: const EdgeInsets.only(top: 24, bottom: 8),
            child: Material(
              color: logoutBgColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: logoutBorderColor, width: 1.0),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () async {
                  await ref.read(authProvider).logout();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout_rounded, color: logoutTextColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: GoogleFonts.inter(
                          color: logoutTextColor,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            'App Version 2.4.0 (Build 8821)',
            textAlign: TextAlign.center,
            style: GoogleFonts.jetBrainsMono(
              fontSize: 11,
              color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(left: 4, top: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.jetBrainsMono(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFF94A3B8) : AppTheme.primaryNavy,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = isDark ? Colors.white : iconColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.borderColor(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary(context))),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
          trailing: Switch.adaptive(
            value: value,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveIconColor = isDark ? Colors.white : iconColor;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: AppTheme.cardColor(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTheme.borderColor(context)),
        ),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: effectiveIconColor, size: 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: AppTheme.textPrimary(context))),
          subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: AppTheme.textSecondary(context))),
          trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary(context)),
          onTap: onTap,
        ),
      ),
    );
  }
}
