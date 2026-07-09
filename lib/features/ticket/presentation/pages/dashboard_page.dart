import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/auth/presentation/pages/login_page.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'ticket_list_page.dart';
import 'create_ticket_page.dart';
import 'ticket_detail_page.dart';
import 'notification_page.dart';
import 'package:project_mobile/features/profile/presentation/pages/settings_page.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/core/utils/date_formatter.dart';
import 'pdf_preview_page.dart';

class DashboardPage extends ConsumerStatefulWidget {
  const DashboardPage({super.key});

  @override
  ConsumerState<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends ConsumerState<DashboardPage> {
  int _currentIndex = 0;

  void changeTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final authProviderVal = ref.watch(authProvider);
    final user = authProviderVal.currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const LoginPage()),
        );
      });
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final List<Widget> tabs = [
      const DashboardTab(),
      const TicketListPage(isTab: true),
      const NotificationPage(),
      const SettingsPage(),
    ];

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: tabs),
      bottomNavigationBar: Container(
        height: 72,
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor(context),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
          border: Border(
            top: BorderSide(
              color: AppTheme.borderColor(context),
              width: 0.8,
            ),
          ),
        ),
        child: SafeArea(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Navigation Items Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildNavItem(0, Icons.home_outlined, Icons.home_rounded, 'Home', isDark),
                    _buildNavItem(1, Icons.confirmation_number_outlined, Icons.confirmation_number_rounded, 'Tickets', isDark),
                    
                    // Space for center FAB
                    const SizedBox(width: 64),
                    
                    _buildNavItem(2, Icons.notifications_none_rounded, Icons.notifications_rounded, 'Alerts', isDark),
                    _buildNavItem(3, Icons.settings_outlined, Icons.settings_rounded, 'Settings', isDark),
                  ],
                ),
              ),
              
              // Center FAB (Add Button)
              Positioned(
                top: -24,
                left: 0,
                right: 0,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            if (context.mounted) {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                              );
                            }
                          });
                        },
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryNavy,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryNavy.withValues(alpha: 0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                            border: Border.all(
                              color: isDark ? const Color(0xFF0F172A) : Colors.white,
                              width: 4,
                            ),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Add',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          letterSpacing: 0.5,
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
    );
  }

  Widget _buildNavItem(int index, IconData icon, IconData activeIcon, String label, bool isDark) {
    final isSelected = _currentIndex == index;

    return InkWell(
      onTap: () {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() => _currentIndex = index);
          }
        });
      },
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: isSelected ? 20 : 16,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryNavy : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              size: 20,
              color: isSelected 
                  ? Colors.white 
                  : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: isSelected 
                    ? Colors.white 
                    : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                fontSize: 10,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════
// DASHBOARD TAB
// ═══════════════════════════════════════════════
class DashboardTab extends ConsumerStatefulWidget {
  const DashboardTab({super.key});

  @override
  ConsumerState<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends ConsumerState<DashboardTab> {

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(ticketProvider).fetchTickets());
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderVal = ref.watch(authProvider);
    final ticketProviderVal = ref.watch(ticketProvider);
    final user = authProviderVal.currentUser!;

    final stats = ticketProviderVal.getTicketStats(user.role, user.email);
    final allRoleTickets = ticketProviderVal.getTicketsForRole(user.role, user.email);
    
    // Tiket Aktif are tickets that are not closed
    final activeTickets = allRoleTickets.where((t) => t.status != 'Closed').toList();

    // Determine greeting based on local time hour
    final currentHour = DateTime.now().hour;
    final String greeting;
    if (currentHour < 11) {
      greeting = 'Selamat Pagi,';
    } else if (currentHour < 15) {
      greeting = 'Selamat Siang,';
    } else if (currentHour < 19) {
      greeting = 'Selamat Sore,';
    } else {
      greeting = 'Selamat Malam,';
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        titleSpacing: 20,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark ? Colors.white.withValues(alpha: 0.1) : AppTheme.primaryNavy.withValues(alpha: 0.1),
                border: Border.all(color: isDark ? Colors.white.withValues(alpha: 0.2) : AppTheme.primaryNavy.withValues(alpha: 0.2)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: user.avatarUrl != null
                    ? Image.network(user.avatarUrl!, fit: BoxFit.cover)
                    : Icon(Icons.account_circle, color: isDark ? Colors.white : AppTheme.primaryNavy, size: 24),
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greeting,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Halo, ${user.fullName}!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (user.role == 'Admin')
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Center(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => PdfPreviewPage(tickets: ticketProviderVal.tickets),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark 
                          ? const Color(0xFF213145).withValues(alpha: 0.35)
                          : AppTheme.primaryNavy.withValues(alpha: 0.05),
                      border: isDark 
                          ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                          : null,
                    ),
                    child: Icon(
                      Icons.picture_as_pdf_rounded,
                      color: isDark ? Colors.white : AppTheme.primaryNavy,
                      size: 22,
                    ),
                  ),
                ),
              ),
            ),
          Container(
            margin: const EdgeInsets.only(right: 20),
            child: Center(
              child: InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const NotificationPage()),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isDark 
                        ? const Color(0xFF213145).withValues(alpha: 0.35)
                        : AppTheme.primaryNavy.withValues(alpha: 0.05),
                    border: isDark 
                        ? Border.all(color: Colors.white.withValues(alpha: 0.05))
                        : null,
                  ),
                  child: Icon(
                    Icons.notifications_outlined,
                    color: isDark ? Colors.white : AppTheme.primaryNavy,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: AppTheme.primaryNavy,
        onRefresh: () async => await ref.read(ticketProvider).fetchTickets(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
              // Bento Stats Grid
              _buildStatsGrid(stats, context, isDark),
              const SizedBox(height: 20),

              // Quick Action Button
              Container(
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const CreateTicketPage()),
                      );
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_circle, color: Colors.white, size: 22),
                          SizedBox(width: 8),
                          Text(
                            'Buat Tiket Baru',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Active Tickets Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Tiket Aktif',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (activeTickets.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        final state = context.findAncestorStateOfType<_DashboardPageState>();
                        state?.changeTab(1);
                      },
                      child: const Text('Lihat Semua'),
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // Active Tickets List or Empty State
              if (activeTickets.isEmpty)
                _buildEmptyState(isDark)
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: activeTickets.length > 3 ? 3 : activeTickets.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _buildTicketSummaryCard(activeTickets[index], context, isDark);
                  },
                ),
              const SizedBox(height: 24),

              // Informational Banner
              _buildInfoBanner(context, isDark),
            ],
          ),
        ),
      ),
    );
  }

  // ─── STATS GRID (BENTO BOX) ───
  Widget _buildStatsGrid(Map<String, int> stats, BuildContext context, bool isDark) {
    final int openCount = stats['Open'] ?? 0;
    final int prosesCount = (stats['Assigned'] ?? 0) + (stats['In Progress'] ?? 0);
    final int selesaiCount = stats['Closed'] ?? 0;

    // 1. Total Laporan Card
    Widget buildTotalCard() {
      final cardContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATISTIK TIKET',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF64748B),
                  letterSpacing: 0.5,
                ),
              ),
              Icon(
                Icons.analytics_outlined,
                color: isDark ? Colors.white : AppTheme.primaryNavy,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${stats['Total'] ?? 0}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppTheme.primaryNavy,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 2.0),
                child: Text(
                  'Total Laporan',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      if (isDark) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF213145).withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryNavy.withValues(alpha: 0.05),
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
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: cardContent,
        );
      }
    }

    // 2. Glassmorphic Bento Cards Builder
    Widget buildStatusCard(String label, int count, Color statusColor, IconData icon) {
      final cardContent = Stack(
        children: [
          // Left accent bar
          Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            width: 4,
            child: Container(
              color: statusColor,
            ),
          ),
          Positioned(
            right: -10,
            bottom: -10,
            child: Icon(
              icon,
              size: 48,
              color: statusColor.withValues(alpha: isDark ? 0.08 : 0.04),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF1E293B),
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
                  color: statusColor.withValues(alpha: 0.25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: statusColor.withValues(alpha: 0.06),
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
            color: statusColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: cardContent,
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        buildTotalCard(),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: buildStatusCard('TERBUKA', openCount, const Color(0xFFEF4444), Icons.error_outline)),
            const SizedBox(width: 12),
            Expanded(child: buildStatusCard('PROSES', prosesCount, const Color(0xFF3B82F6), Icons.sync)),
          ],
        ),
        const SizedBox(height: 12),
        buildStatusCard('SELESAI MINGGU INI', selesaiCount, const Color(0xFF10B981), Icons.check_circle_outline),
      ],
    );
  }

  // ─── EMPTY STATE ───
  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.primaryNavy.withValues(alpha: 0.05),
            ),
            child: const Icon(
              Icons.assignment_late_outlined,
              size: 36,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada tiket',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Anda tidak memiliki laporan aktif saat ini.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const CreateTicketPage()),
              );
            },
            icon: const Icon(Icons.add, size: 16),
            label: const Text('Buat Laporan Baru'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.05),
              foregroundColor: AppTheme.primaryNavy,
              elevation: 0,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha: 0.1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── INFO BANNER SUPPORT ───
  Widget _buildInfoBanner(BuildContext context, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.1)),
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.support_agent_rounded,
              size: 100,
              color: AppTheme.primaryNavy.withValues(alpha: 0.04),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Butuh Bantuan Cepat?',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: Text(
                  'Hubungi tim IT Helpdesk kami melalui live chat untuk respon instan.',
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? const Color(0xFFC5C5D3) : const Color(0xFF444651),
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Menghubungi Customer Service...')),
                  );
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Hubungi CS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                        decoration: TextDecoration.underline,
                        decorationColor: AppTheme.primaryNavy.withValues(alpha: 0.3),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.chat_outlined, size: 16, color: AppTheme.primaryNavy),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── TICKET SUMMARY CARD ───
  Widget _buildTicketSummaryCard(dynamic ticket, BuildContext context, bool isDark) {
    Color statusColor;
    switch (ticket.status) {
      case 'Open': statusColor = AppTheme.statusOpen; break;
      case 'Assigned': statusColor = AppTheme.statusAssigned; break;
      case 'In Progress': statusColor = AppTheme.statusInProgress; break;
      default: statusColor = AppTheme.statusClosed;
    }

    const categoryIcon = Icons.confirmation_num_rounded;

    final cardContent = IntrinsicHeight(
      child: Row(
        children: [
          // Left accent bar
          Container(
            width: 4,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                bottomLeft: Radius.circular(20),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withValues(alpha: 0.1) : AppTheme.primaryNavy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(categoryIcon, color: isDark ? Colors.white : AppTheme.primaryNavy, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.title,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textPrimary(context)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${ticket.id} • ${DateFormatter.formatDateTime(ticket.createdAt)}',
                          style: TextStyle(fontSize: 11, color: AppTheme.textSecondary(context)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      ticket.status,
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );

    return Material(
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
        borderRadius: BorderRadius.circular(20),
        child: isDark
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF213145).withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(20),
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
                  color: AppTheme.cardColor(context),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.borderColor(context)),
                ),
                child: cardContent,
              ),
      ),
    );
  }
}
