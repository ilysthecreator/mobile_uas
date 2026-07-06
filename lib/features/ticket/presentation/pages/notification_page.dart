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
      leading: const Icon(Icons.menu, color: AppTheme.primaryNavy),
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

    // Bento card helper (local function renamed to not start with underscore)
    Widget buildBentoCard(String title, String count) {
      return Opacity(
        opacity: 0.65,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
            border: Border(
              left: const BorderSide(color: Color(0xFFC5C5D3), width: 4),
              top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              right: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              bottom: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.02),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              Text(
                count,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF0B1C30),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Bento summary grid
    Widget buildBentoSummary() {
      return GridView.count(
        crossAxisCount: 3,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        childAspectRatio: 1.15,
        children: [
          buildBentoCard('Unresolved', formatCount(unresolvedCount)),
          buildBentoCard('Active Tasks', formatCount(activeCount)),
          buildBentoCard('Admin Alerts', formatCount(alertCount)),
        ],
      );
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
              child: const Icon(
                Icons.notifications_off_outlined,
                color: AppTheme.primaryNavy,
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
                            color: AppTheme.primaryNavy,
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
