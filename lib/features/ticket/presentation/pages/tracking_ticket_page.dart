import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/core/utils/date_formatter.dart';

class TrackingTicketPage extends ConsumerWidget {
  final String ticketId;

  const TrackingTicketPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderVal = ref.watch(authProvider);
    final ticketProviderVal = ref.watch(ticketProvider);
    final currentUser = authProviderVal.currentUser!;

    final ticketIndex = ticketProviderVal.tickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Ticket')),
        body: const Center(child: Text('Ticket not found')),
      );
    }

    final ticket = ticketProviderVal.tickets[ticketIndex];
    final logs = ticketProviderVal.getActivityLogsForTicket(ticketId);

    Color statusColor;
    switch (ticket.status) {
      case 'Open': statusColor = AppTheme.statusOpen; break;
      case 'Assigned': statusColor = AppTheme.statusAssigned; break;
      case 'In Progress': statusColor = AppTheme.statusInProgress; break;
      default: statusColor = AppTheme.statusClosed;
    }

    // Top App Bar matching mockup
    final appBar = AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      shape: Border(
        bottom: BorderSide(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          width: 0.8,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back_rounded, color: AppTheme.textPrimary(context)),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Text(
        'Ticket #${ticket.id.toUpperCase()}',
        style: GoogleFonts.hankenGrotesk(
          color: isDark ? Colors.white : const Color(0xFF0B1C30),
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.share_outlined, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
          child: currentUser.avatarUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(currentUser.avatarUrl!, fit: BoxFit.cover),
                )
              : Text(
                  currentUser.avatarLetter,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                  ),
                ),
        ),
      ],
    );

    // Summary Card matching mockup
    Widget buildSummaryCard() {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.1 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CATEGORY: ${ticket.category.toUpperCase()}',
                        style: GoogleFonts.jetBrainsMono(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.secondaryBlue,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        ticket.title,
                        style: GoogleFonts.hankenGrotesk(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary(context),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor.withValues(alpha: 0.2)),
                  ),
                  child: Text(
                    ticket.status.toUpperCase(),
                    style: GoogleFonts.jetBrainsMono(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              ticket.description,
              style: GoogleFonts.inter(
                fontSize: 14,
                color: AppTheme.textSecondary(context),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.calendar_today_outlined, size: 16, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    const SizedBox(width: 6),
                    Text(
                      'Opened ${DateFormatter.formatDateTime(ticket.createdAt)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textSecondary(context),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.priority_high_rounded, size: 16, color: AppTheme.statusOpen),
                    const SizedBox(width: 6),
                    Text(
                      '${ticket.priority} Priority',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.statusOpen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      );
    }

    // Empty Tracking History
    Widget buildEmptyTrackingState() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 24),
        width: double.infinity,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF).withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3).withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFDCE9FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.track_changes_rounded,
                color: AppTheme.primaryNavy,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Data pelacakan akan muncul setelah tiket diproses',
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary(context),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'STATUS: WAITING FOR ACTIVITY',
              style: GoogleFonts.jetBrainsMono(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
      );
    }

    // Timeline Widget
    Widget buildTimeline(List<dynamic> logs) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          // Show newest log at the top
          final log = logs[logs.length - 1 - index];
          final isLast = index == logs.length - 1;
          final isFirst = index == 0;

          Color dotColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
          IconData logIcon = Icons.circle_rounded;
          if (log.title.contains('Created')) { 
            dotColor = AppTheme.statusOpen; 
            logIcon = Icons.add_circle_outline_rounded; 
          } else if (log.title.contains('Accepted') || log.title.contains('Assigned')) { 
            dotColor = AppTheme.statusAssigned; 
            logIcon = Icons.assignment_ind_outlined; 
          } else if (log.title.contains('Completed')) { 
            dotColor = AppTheme.statusClosed; 
            logIcon = Icons.task_alt_rounded; 
          } else if (log.title.contains('Status')) { 
            dotColor = AppTheme.statusInProgress; 
            logIcon = Icons.sync_rounded; 
          }

          return Stack(
            children: [
              // Connecting line
              if (!isLast)
                Positioned(
                  left: 17,
                  top: 30,
                  bottom: 0,
                  width: 2,
                  child: Container(
                    color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                  ),
                ),
              
              // Timeline row
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Dot
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: isFirst ? dotColor : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF)),
                        shape: BoxShape.circle,
                        border: Border.all(color: dotColor, width: 2),
                        boxShadow: isFirst
                            ? [BoxShadow(color: dotColor.withValues(alpha: 0.3), blurRadius: 8, spreadRadius: 1)]
                            : null,
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        isFirst ? Icons.check_rounded : logIcon,
                        size: 16,
                        color: isFirst ? Colors.white : dotColor,
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Card
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isFirst 
                              ? dotColor.withValues(alpha: isDark ? 0.12 : 0.04) 
                              : (isDark ? const Color(0xFF1E293B) : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isFirst 
                                ? dotColor.withValues(alpha: isDark ? 0.25 : 0.12) 
                                : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.title,
                              style: GoogleFonts.inter(
                                fontWeight: FontWeight.bold, 
                                fontSize: 14, 
                                color: AppTheme.textPrimary(context),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              log.description,
                              style: GoogleFonts.inter(
                                color: AppTheme.textSecondary(context), 
                                fontSize: 13,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(Icons.person_outline_rounded, size: 14, color: AppTheme.textSecondary(context)),
                                const SizedBox(width: 4),
                                Text(
                                  log.actorName, 
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary(context)),
                                ),
                                const SizedBox(width: 16),
                                Icon(Icons.access_time_rounded, size: 14, color: AppTheme.textSecondary(context)),
                                const SizedBox(width: 4),
                                Text(
                                  DateFormatter.formatRelative(log.createdAt), 
                                  style: GoogleFonts.inter(fontSize: 11, color: AppTheme.textSecondary(context)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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
            // 1. Summary Card
            buildSummaryCard(),
            const SizedBox(height: 24),

            // 2. Section Title
            Text(
              'Tracking History',
              style: GoogleFonts.hankenGrotesk(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary(context),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Timeline / Empty State
            if (logs.isEmpty)
              buildEmptyTrackingState()
            else
              buildTimeline(logs),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
