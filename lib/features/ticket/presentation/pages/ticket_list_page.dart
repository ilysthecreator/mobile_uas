import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'ticket_detail_page.dart';
import 'create_ticket_page.dart';

class TicketListPage extends ConsumerStatefulWidget {
  final bool isTab;

  const TicketListPage({super.key, this.isTab = false});

  @override
  ConsumerState<TicketListPage> createState() => _TicketListPageState();
}

class _TicketListPageState extends ConsumerState<TicketListPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedStatus = 'All';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
    // Fetch fresh tickets
    Future.microtask(() => ref.read(ticketProvider).fetchTickets());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderVal = ref.watch(authProvider);
    final ticketProviderVal = ref.watch(ticketProvider);
    final user = authProviderVal.currentUser!;

    final baseTickets = ticketProviderVal.getTicketsForRole(user.role, user.email);

    // Filter by search query
    var filteredTickets = baseTickets.where((t) {
      return t.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.id.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    // Stats calculations
    final stats = ticketProviderVal.getTicketStats(user.role, user.email);
    final int openCount = stats['Open'] ?? 0;
    final int assignedCount = stats['Assigned'] ?? 0;
    final int progressCount = stats['In Progress'] ?? 0;
    final int closedCount = stats['Closed'] ?? 0;
    final int countAll = filteredTickets.length;

    // Filter by active selected status pill
    final statusTickets = filteredTickets.where((t) {
      return _selectedStatus == 'All' || t.status == _selectedStatus;
    }).toList();

    // Helper widget for stats summary cards
    Widget buildSummaryCard(String label, int count, Color color) {
      final cardContent = Stack(
        children: [
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              color: color,
            ),
          ),
          // Subtle status icon in background
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              label == 'Terbuka'
                  ? Icons.error_outline
                  : label == 'Diproses'
                      ? Icons.sync
                      : label == 'Ditugaskan'
                          ? Icons.assignment_ind_outlined
                          : Icons.check_circle_outline,
              size: 40,
              color: color.withValues(alpha: isDark ? 0.08 : 0.04),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
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
                    color: color.withValues(alpha: 0.08),
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

    Widget buildSummaryGrid() {
      final double width = MediaQuery.of(context).size.width;
      if (width > 600) {
        return Row(
          children: [
            Expanded(child: buildSummaryCard('Terbuka', openCount, const Color(0xFFEF4444))),
            const SizedBox(width: 12),
            Expanded(child: buildSummaryCard('Diproses', progressCount, const Color(0xFF3B82F6))),
            const SizedBox(width: 12),
            Expanded(child: buildSummaryCard('Ditugaskan', assignedCount, const Color(0xFFF59E0B))),
            const SizedBox(width: 12),
            Expanded(child: buildSummaryCard('Selesai', closedCount, const Color(0xFF10B981))),
          ],
        );
      } else {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          childAspectRatio: 2.1,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: [
            buildSummaryCard('Terbuka', openCount, const Color(0xFFEF4444)),
            buildSummaryCard('Diproses', progressCount, const Color(0xFF3B82F6)),
            buildSummaryCard('Ditugaskan', assignedCount, const Color(0xFFF59E0B)),
            buildSummaryCard('Selesai', closedCount, const Color(0xFF10B981)),
          ],
        );
      }
    }

    Widget buildStatusPill(String statusValue, String displayLabel, Color color, int count) {
      final isSelected = _selectedStatus == statusValue;
      return InkWell(
        onTap: () => setState(() => _selectedStatus = statusValue),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected ? color : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$displayLabel ($count)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? color : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildEmptyState() {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? const Color(0xFF0F172A) : const Color(0xFFE5EEFF),
              ),
              child: const Icon(
                Icons.confirmation_number_outlined,
                size: 40,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Belum ada tiket yang dibuat',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Mulai dengan membuat tiket baru untuk mendapatkan bantuan dari tim dukungan kami.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                );
              },
              icon: const Icon(Icons.add_circle, size: 18, color: Colors.white),
              label: const Text('Buat Tiket Baru'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                elevation: 4,
              ),
            ),
          ],
        ),
      );
    }

    final scaffoldContent = RefreshIndicator(
      color: AppTheme.primaryNavy,
      onRefresh: () async => await ref.read(ticketProvider).fetchTickets(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (ticketProviderVal.errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.statusOpen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.statusOpen.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline, color: AppTheme.statusOpen),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Database Error: ${ticketProviderVal.errorMessage}',
                        style: const TextStyle(
                          color: AppTheme.statusOpen,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 16, color: AppTheme.statusOpen),
                      onPressed: () => ref.read(ticketProvider).clearError(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            // 1. Dashboard Bento Grid Summary
            buildSummaryGrid(),
            const SizedBox(height: 20),

            // 2. Filter & Search Bar
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF213145).withValues(alpha: 0.2) : const Color(0xFFEFF4FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.transparent,
                ),
              ),
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search by ID, title or keyword...',
                      prefixIcon: const Icon(Icons.search_rounded, size: 20),
                      suffixIcon: _searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded, size: 18),
                              onPressed: () => _searchController.clear(),
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      filled: true,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppTheme.primaryNavy, width: 1.5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Reset filter status
                            setState(() => _selectedStatus = 'All');
                          },
                          icon: const Icon(Icons.filter_list_rounded, size: 18),
                          label: const Text('Filters'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                            side: BorderSide(
                              color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3),
                            ),
                            backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                            );
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('New Ticket'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryNavy,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Inline Status Filter Pills
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  buildStatusPill('All', 'Semua', Colors.blueGrey, countAll),
                  const SizedBox(width: 8),
                  buildStatusPill('Open', 'Terbuka', const Color(0xFFEF4444), openCount),
                  const SizedBox(width: 8),
                  buildStatusPill('Assigned', 'Ditugaskan', const Color(0xFFF59E0B), assignedCount),
                  const SizedBox(width: 8),
                  buildStatusPill('In Progress', 'Diproses', const Color(0xFF3B82F6), progressCount),
                  const SizedBox(width: 8),
                  buildStatusPill('Closed', 'Selesai', const Color(0xFF10B981), closedCount),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 4. Ticket List Items
            if (statusTickets.isEmpty)
              buildEmptyState()
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: statusTickets.length,
                itemBuilder: (context, index) {
                  return _buildTicketListItem(statusTickets[index], context, isDark);
                },
              ),
          ],
        ),
      ),
    );

    if (widget.isTab) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('My Tickets'),
          automaticallyImplyLeading: false,
        ),
        body: scaffoldContent,
      );
    } else {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
          elevation: 0,
          scrolledUnderElevation: 0,
          title: const Text('Tickets Archive'),
        ),
        body: scaffoldContent,
      );
    }
  }

  Widget _buildTicketListItem(dynamic ticket, BuildContext context, bool isDark) {
    Color statusColor;
    switch (ticket.status) {
      case 'Open': statusColor = AppTheme.statusOpen; break;
      case 'Assigned': statusColor = AppTheme.statusAssigned; break;
      case 'In Progress': statusColor = AppTheme.statusInProgress; break;
      default: statusColor = AppTheme.statusClosed;
    }

    final cardContent = IntrinsicHeight(
      child: Row(
        children: [
          // Left accent
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row: ID + Status
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ticket.id,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          ticket.status,
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Title
                  Text(
                    ticket.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : const Color(0xFF0B1C30),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),

                  // Description
                  Text(
                    ticket.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  Divider(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    height: 1,
                  ),
                  const SizedBox(height: 10),

                  // Footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 13,
                            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            ticket.assignedToName ?? 'Belum Ditugaskan',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatDate(ticket.createdAt),
                        style: TextStyle(
                          fontSize: 10,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (context.mounted) {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => TicketDetailPage(ticketId: ticket.id)),
                );
              }
            });
          },
          borderRadius: BorderRadius.circular(16),
          child: isDark
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF213145).withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: statusColor.withValues(alpha: 0.25),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: statusColor.withValues(alpha: 0.06),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: cardContent,
                    ),
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: cardContent,
                ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 60) return '${diff.inMinutes}m lalu';
    if (diff.inHours < 24) return '${diff.inHours}j lalu';
    return '${date.day}/${date.month}';
  }
}
