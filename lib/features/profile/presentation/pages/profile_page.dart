import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'settings_page.dart';

class ProfilePage extends ConsumerWidget {
  final bool isTab;

  const ProfilePage({super.key, this.isTab = false});

  void _handleLogout(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign Out'),
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
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: AppTheme.statusOpen),
              child: const Text('Sign Out'),
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
    final ticketProviderVal = ref.watch(ticketProvider);
    final user = authProviderVal.currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in')));
    }

    final roleTickets = ticketProviderVal.getTicketsForRole(user.role, user.email);
    final totalTicketsCount = roleTickets.length;
    final closedTicketsCount = roleTickets.where((t) => t.status == 'Closed').length;
    final resolutionRate = totalTicketsCount > 0
        ? ((closedTicketsCount / totalTicketsCount) * 100).round()
        : 0;

    String roleName = '';
    Color roleBg = AppTheme.primaryNavy;
    if (user.role == 'Admin') {
      roleName = 'Administrator';
      roleBg = AppTheme.statusOpen;
    } else if (user.role == 'Helpdesk') {
      roleName = 'Helpdesk Analyst';
      roleBg = AppTheme.statusAssigned;
    } else {
      roleName = 'Employee (Pelapor)';
      roleBg = AppTheme.primaryNavy;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 750;

    // Top App Bar matching mockup
    final appBar = AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: isTab
          ? const Icon(Icons.menu, color: AppTheme.primaryNavy)
          : IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
              onPressed: () => Navigator.of(context).pop(),
            ),
      title: Text(
        'Helpdesk Central',
        style: GoogleFonts.hankenGrotesk(
          color: isDark ? Colors.white : const Color(0xFF0B1C30),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search_rounded, color: AppTheme.primaryNavy),
          onPressed: () {},
        ),
        Container(
          margin: const EdgeInsets.only(right: 16, left: 8),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDCE9FF),
          ),
          alignment: Alignment.center,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: user.avatarUrl != null
                ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                : Text(
                    user.avatarLetter,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
          ),
        ),
      ],
    );

    // Identity Card
    Widget buildIdentityCard() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white.withValues(alpha: 0.7),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  width: 128,
                  height: 128,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: user.avatarUrl != null
                        ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                        : Container(
                            color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                            alignment: Alignment.center,
                            child: Text(
                              user.avatarLetter,
                              style: GoogleFonts.hankenGrotesk(
                                fontSize: 44,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                          ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.photo_camera_rounded, size: 16, color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFDCE9FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.role == 'Admin' ? 'Senior Analyst' : 'Technical Support',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryNavy,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              user.fullName,
              style: GoogleFonts.hankenGrotesk(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.mail_outline_rounded, size: 16, color: AppTheme.textSecondary(context)),
                const SizedBox(width: 6),
                Text(
                  user.email,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.hub_outlined, color: AppTheme.primaryNavy),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DEPARTEMEN',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user.role == 'Admin' ? 'Tier 3 Technical Support' : 'Tier 1 Operations & Support',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined, color: roleBg),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LEVEL AKSES',
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF64748B),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          roleName,
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary(context),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Stats Section
    Widget buildStatsColumn() {
      return Column(
        children: [
          // Total Tickets Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.confirmation_number_outlined,
                      size: 64,
                      color: Colors.white.withValues(alpha: 0.1),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.mail_outline_rounded, size: 14, color: Colors.white70),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              user.email.toUpperCase(),
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 9,
                                fontWeight: FontWeight.bold,
                                color: Colors.white70,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$totalTicketsCount',
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Tiket Aktif',
                        style: GoogleFonts.inter(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Resolution Rate Card
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Icon(Icons.mail_outline_rounded, size: 14, color: AppTheme.textSecondary(context)),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          user.email.toUpperCase(),
                          style: GoogleFonts.jetBrainsMono(
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textSecondary(context),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$resolutionRate%',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Penyelesaian Tiket',
                    style: GoogleFonts.inter(fontSize: 12, color: AppTheme.textSecondary(context)),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: totalTicketsCount > 0 ? (closedTicketsCount / totalTicketsCount) : 0.0,
                      backgroundColor: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.statusClosed),
                      minHeight: 4,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    // Sidebar Menu Options
    Widget buildSidebarMenu() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4.0, bottom: 12.0),
            child: Text(
              'Manage Account',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ),
          _buildMenuButton(
            icon: Icons.edit_outlined,
            iconBgColor: isDark ? const Color(0xFF334155) : const Color(0xFFEFF4FF),
            iconColor: AppTheme.primaryNavy,
            title: 'Edit Profile',
            subtitle: 'Update personal info and avatar',
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary(context)),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildMenuButton(
            icon: Icons.security_outlined,
            iconBgColor: isDark ? const Color(0xFF334155) : const Color(0xFFFFF7ED),
            iconColor: AppTheme.statusAssigned,
            title: 'Security',
            subtitle: 'Passwords, 2FA, and sessions',
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary(context)),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const SettingsPage()),
              );
            },
          ),
          const SizedBox(height: 10),
          _buildMenuButton(
            icon: Icons.confirmation_number_outlined,
            iconBgColor: isDark ? const Color(0xFF334155) : const Color(0xFFEFF6FF),
            iconColor: AppTheme.statusInProgress,
            title: 'My Tickets',
            subtitle: 'View all active and closed tasks',
            trailing: Icon(Icons.chevron_right_rounded, color: AppTheme.textSecondary(context)),
            onTap: () {},
          ),
          const SizedBox(height: 10),
          _buildMenuButton(
            icon: Icons.logout_rounded,
            iconBgColor: const Color(0xFFFEE2E2),
            iconColor: AppTheme.statusOpen,
            title: 'Sign Out',
            subtitle: 'End your current session safely',
            textColor: AppTheme.statusOpen,
            onTap: () => _handleLogout(context, authProviderVal),
          ),
        ],
      );
    }

    // Detailed Jobs Canvas
    Widget buildDetailedCanvas() {
      return Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155).withValues(alpha: 0.3) : const Color(0xFFF8F9FF),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Pekerjaan',
                    style: GoogleFonts.hankenGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary(context),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF334155) : Colors.white,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: isDark ? const Color(0xFF475569) : const Color(0xFFC5C5D3)),
                    ),
                    child: Text(
                      'ID PEGAWAI: HD-8821',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildCanvasRow('Email Korporat', user.email),
                  _buildCanvasRow('Shift Kerja', 'Pagi (08:00 - 17:00)'),
                  _buildCanvasRow('Telepon', '+62 812-3456-7890'),
                  _buildCanvasRow('Tanggal Bergabung', '15 Maret 2021'),
                  _buildCanvasRowWithManager('Manajer', 'Sarah Richardson'),
                  _buildCanvasRow('Lokasi Kerja', 'Remote / Jakarta, ID', isLast: true),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Activity Timeline (Empty)
    Widget buildEmptyActivityTimeline() {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Text(
              'Riwayat Aktivitas Tiket',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 32),
            Opacity(
              opacity: 0.45,
              child: Column(
                children: [
                  const Icon(Icons.history_rounded, size: 48, color: Color(0xFF64748B)),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada riwayat aktivitas tiket.',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppTheme.textSecondary(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: appBar,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Responsive Top Profile Header & Stats Row
            if (isLargeScreen)
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 2, child: buildIdentityCard()),
                    const SizedBox(width: 16),
                    Expanded(flex: 1, child: buildStatsColumn()),
                  ],
                ),
              )
            else
              Column(
                children: [
                  buildIdentityCard(),
                  const SizedBox(height: 16),
                  SizedBox(height: 240, child: buildStatsColumn()),
                ],
              ),
            const SizedBox(height: 28),

            // Responsive Manage Sidebar & Jobs Canvas
            if (isLargeScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 4, child: buildSidebarMenu()),
                  const SizedBox(width: 20),
                  Expanded(
                    flex: 8,
                    child: Column(
                      children: [
                        buildDetailedCanvas(),
                        const SizedBox(height: 20),
                        buildEmptyActivityTimeline(),
                      ],
                    ),
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildSidebarMenu(),
                  const SizedBox(height: 28),
                  buildDetailedCanvas(),
                  const SizedBox(height: 20),
                  buildEmptyActivityTimeline(),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: textColor != null ? textColor.withValues(alpha: 0.2) : const Color(0xFFC5C5D3).withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: textColor != null ? textColor.withValues(alpha: 0.7) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              trailing ?? const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCanvasRow(String label, String value, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFC5C5D3),
                  width: 0.8,
                  style: BorderStyle.solid, // Simulated dashed border via simple solid line
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCanvasRowWithManager(String label, String name, {bool isLast = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(
                  color: Color(0xFFC5C5D3),
                  width: 0.8,
                ),
              ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      decoration: const BoxDecoration(
                        color: AppTheme.primaryNavy,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'SR',
                        style: GoogleFonts.inter(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      name,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
