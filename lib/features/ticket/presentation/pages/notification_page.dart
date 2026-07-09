import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/core/utils/date_formatter.dart';
import 'ticket_detail_page.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketProviderVal = ref.watch(ticketProvider);
    final authProviderVal = ref.watch(authProvider);
    final user = authProviderVal.currentUser;

    final List<Map<String, dynamic>> notifications = [];
    final List<dynamic> roleTickets = user != null
        ? ticketProviderVal.getTicketsForRole(user.role, user.email)
        : [];

    if (user != null) {
      notifications.add({
        'id': 'NOT-001',
        'title': 'Welcome to Helpdesk!',
        'body': 'You are logged in as ${user.fullName} (${user.role}).',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'icon': Icons.account_circle_outlined,
        'color': const Color(0xFF00236F),
        'ticketId': null,
      });

      for (var t in roleTickets) {
        notifications.add({
          'id': 'NOT-T-${t.id}',
          'title': 'New Ticket Registered',
          'body': 'Ticket "${t.title}" is currently ${t.status}.',
          'time': t.createdAt,
          'icon': Icons.assignment_outlined,
          'color': AppTheme.statusInProgress,
          'ticketId': t.id,
        });

        if (t.status != 'Open') {
          notifications.add({
            'id': 'NOT-S-${t.id}',
            'title': 'Ticket Status Updated',
            'body': 'Ticket #${t.id} has been marked as ${t.status}.',
            'time': t.updatedAt,
            'icon': Icons.loop_rounded,
            'color': AppTheme.statusAssigned,
            'ticketId': t.id,
          });
        }
      }
    }

    notifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    // Stats calculations for Bento grid
    final unresolvedCount = roleTickets.where((t) => t.status != 'Closed').length;
    final activeCount = roleTickets.where((t) => t.status == 'Assigned' || t.status == 'In Progress').length;
    final alertCount = roleTickets.where((t) => t.status == 'Open').length;

    String formatCount(int count) {
      return count < 10 ? '0$count' : '$count';
    }

    // Top Navigation Bar matching mockup
    final appBar = AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: Icon(Icons.menu, color: isDark ? Colors.white : AppTheme.primaryNavy),
      title: Text(
        'Helpdesk Central',
        style: GoogleFonts.hankenGrotesk(
          color: isDark ? Colors.white : const Color(0xFF0B1C30),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search_rounded, color: isDark ? Colors.white : AppTheme.primaryNavy),
          onPressed: () {},
        ),
        if (user != null)
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
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : AppTheme.primaryNavy,
                      ),
                    ),
            ),
          ),
      ],
    );

    // Bento card helper
    Widget buildBentoCard(String title, String count, Color accentColor) {
      final cardContent = IntrinsicHeight(
        child: Row(
          children: [
            // Left accent bar
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            // Content Column
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      title.toUpperCase(),
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 9,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF64748B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      count,
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0B1C30),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

      if (isDark) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF213145).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: cardContent,
            ),
          ),
        );
      } else {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cardContent,
          ),
        );
      }
    }

    // Bento summary grid
    Widget buildBentoSummary() {
      final double width = MediaQuery.of(context).size.width;
      
      Widget gridContent() {
        if (width > 600) {
          return Row(
            children: [
              Expanded(child: buildBentoCard('Unresolved', formatCount(unresolvedCount), const Color(0xFFF59E0B))),
              const SizedBox(width: 12),
              Expanded(child: buildBentoCard('Active Tasks', formatCount(activeCount), const Color(0xFF3B82F6))),
              const SizedBox(width: 12),
              Expanded(child: buildBentoCard('Admin Alerts', formatCount(alertCount), const Color(0xFFEF4444))),
            ],
          );
        } else {
          return GridView.count(
            crossAxisCount: 3,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: [
              buildBentoCard('Unresolved', formatCount(unresolvedCount), const Color(0xFFF59E0B)),
              buildBentoCard('Active Tasks', formatCount(activeCount), const Color(0xFF3B82F6)),
              buildBentoCard('Admin Alerts', formatCount(alertCount), const Color(0xFFEF4444)),
            ],
          );
        }
      }

      return gridContent();
    }

    Widget buildEmptyState() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_outlined,
                color: isDark ? Colors.white : AppTheme.primaryNavy,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Tidak ada notifikasi baru',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Kami akan memberi tahu Anda jika terjadi sesuatu yang baru.',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textSecondary(context),
              ),
            ),
          ],
        ),
      );
    }

    Widget buildNotificationList(List<Map<String, dynamic>> notificationsList) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: notificationsList.length,
        itemBuilder: (context, index) {
          final notif = notificationsList[index];
          final ticketId = notif['ticketId'] as String?;
          final color = notif['color'] as Color;
          final time = notif['time'] as DateTime;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: Material(
              color: AppTheme.cardColor(context),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: AppTheme.borderColor(context)),
              ),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () {
                  if (ticketId != null) {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => TicketDetailPage(ticketId: ticketId)),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Notification read')),
                    );
                  }
                },
                child: IntrinsicHeight(
                  child: Row(
                    children: [
                      // Left accent
                      Container(
                        width: 4,
                        color: color,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: isDark ? 0.15 : 0.08),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(notif['icon'] as IconData, color: color, size: 20),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      notif['title'] as String,
                                      style: GoogleFonts.inter(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 13, 
                                        color: AppTheme.textPrimary(context),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      notif['body'] as String,
                                      style: GoogleFonts.inter(
                                        fontSize: 12, 
                                        color: AppTheme.textSecondary(context),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                DateFormatter.formatRelative(time),
                                style: GoogleFonts.inter(
                                  fontSize: 10, 
                                  color: AppTheme.textSecondary(context),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
            // Title section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ACTIVITY LEDGER',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.secondaryBlue,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Notifications',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary(context),
                      ),
                    ),
                    if (notifications.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('All notifications marked as read')),
                          );
                        },
                        child: Text(
                          'Clear All',
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white : AppTheme.primaryNavy,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bento Grid Summary Cards
            buildBentoSummary(),
            const SizedBox(height: 24),

            // Notifications List / Empty State
            if (notifications.isEmpty)
              buildEmptyState()
            else
              buildNotificationList(notifications),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
