import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'package:project_mobile/features/auth/data/models/user_model.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/core/theme/app_theme.dart';
import 'package:project_mobile/core/utils/date_formatter.dart';
import 'tracking_ticket_page.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _commentController = TextEditingController();
  final _scrollController = ScrollController();
  String? _commentImageUrl;

  @override
  void initState() {
    super.initState();
    // Fetch comments and activity logs from Supabase
    Future.microtask(() => ref.read(ticketProvider).fetchTicketDetails(widget.ticketId));
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 150,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _submitComment(String userEmail, String userName, String userRole) {
    final text = _commentController.text.trim();
    if (text.isEmpty && _commentImageUrl == null) return;

    final provider = ref.read(ticketProvider);
    provider.addComment(
      ticketId: widget.ticketId,
      senderEmail: userEmail,
      senderName: userName,
      senderRole: userRole,
      message: text,
      imageUrl: _commentImageUrl,
    );

    _commentController.clear();
    setState(() => _commentImageUrl = null);
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }

  void _pickCommentImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: source, imageQuality: 70);
      if (!mounted) return;
      if (image != null) {
        setState(() {
          _commentImageUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=300&q=80';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lampiran gambar ditambahkan!')),
        );
      }
    } catch (e) {
      debugPrint('Picker error: $e');
      if (!mounted) return;
      setState(() {
        _commentImageUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=300&q=80';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kamera tidak didukung. Menggunakan demo lampiran.')),
      );
    }
  }

  void _showAssignDialog(String actorName) async {
    final helpdeskAgents = await ref.read(authProvider).fetchHelpdeskUsers();

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) {
        final isDarkLocal = Theme.of(context).brightness == Brightness.dark;
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDarkLocal ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Assign Support Agent',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (helpdeskAgents.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      const Icon(Icons.support_agent_rounded, size: 48, color: AppTheme.primaryNavy),
                      const SizedBox(height: 12),
                      Text(
                        'Tidak ada helpdesk yang tersedia.\nBuat akun bertipe Helpdesk terlebih dahulu.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: isDarkLocal ? const Color(0xFF94A3B8) : const Color(0xFF64748B), fontSize: 13),
                      ),
                    ],
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.45,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: helpdeskAgents.map((agent) {
                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Material(
                          color: isDarkLocal ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF),
                          borderRadius: BorderRadius.circular(14),
                          clipBehavior: Clip.antiAlias,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppTheme.primaryNavy.withValues(alpha: 0.1),
                              child: Text(
                                agent.avatarLetter,
                                style: const TextStyle(color: AppTheme.primaryNavy, fontWeight: FontWeight.w700),
                              ),
                            ),
                            title: Text(agent.fullName, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            subtitle: Text(agent.email, style: TextStyle(fontSize: 12, color: isDarkLocal ? const Color(0xFF94A3B8) : const Color(0xFF64748B))),
                            onTap: () {
                              ref.read(ticketProvider).assignTicket(
                                ticketId: widget.ticketId,
                                helpdeskEmail: agent.email,
                                helpdeskName: agent.fullName,
                                actorName: actorName,
                              );
                              Navigator.of(context).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Tiket ditugaskan kepada ${agent.fullName}')),
                              );
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authProviderVal = ref.watch(authProvider);
    final ticketProviderVal = ref.watch(ticketProvider);
    final currentUser = authProviderVal.currentUser!;

    final ticketIndex = ticketProviderVal.tickets.indexWhere((t) => t.id == widget.ticketId);
    if (ticketIndex == -1) {
      return const Scaffold(body: Center(child: Text('Ticket not found')));
    }

    final ticket = ticketProviderVal.tickets[ticketIndex];
    final comments = ticketProviderVal.getCommentsForTicket(widget.ticketId);
    final activityLogs = ticketProviderVal.getActivityLogsForTicket(widget.ticketId);

    Color statusColor;
    switch (ticket.status) {
      case 'Open': statusColor = AppTheme.statusOpen; break;
      case 'Assigned': statusColor = AppTheme.statusAssigned; break;
      case 'In Progress': statusColor = AppTheme.statusInProgress; break;
      default: statusColor = AppTheme.statusClosed;
    }

    // Responsive setup
    final screenWidth = MediaQuery.of(context).size.width;
    final isLargeScreen = screenWidth > 900;

    // Header App Bar matching mockup
    final appBar = AppBar(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      elevation: 0,
      scrolledUnderElevation: 0,
      leading: IconButton(
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
          icon: Icon(Icons.search_rounded, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
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
          child: Text(
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

    // Left detailed request details + discussion box
    Widget buildMainContent() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Ticket Title and ID Info
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'TICKET #${ticket.id.toUpperCase()}',
                style: GoogleFonts.jetBrainsMono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                ticket.title,
                style: GoogleFonts.hankenGrotesk(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : const Color(0xFF0B1C30),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF),
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
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppTheme.primaryNavy.withValues(alpha: 0.2)),
                    ),
                    child: Text(
                      'PRIORITY: ${ticket.priority.toUpperCase()}',
                      style: GoogleFonts.jetBrainsMono(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryNavy,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Request Details Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
              children: [
                Row(
                  children: [
                    Icon(Icons.description_outlined, color: statusColor, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Request Details',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  ticket.description,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    color: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF334155),
                    height: 1.5,
                  ),
                ),
                if (ticket.imageUrl != null) ...[
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                InteractiveViewer(child: Image.network(ticket.imageUrl!)),
                                IconButton(
                                  icon: const Icon(Icons.close_rounded, color: Colors.white, shadows: [Shadow(blurRadius: 4)]),
                                  onPressed: () => Navigator.of(context).pop(),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      child: Image.network(
                        ticket.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.only(top: 16),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CATEGORY',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ticket.category,
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0B1C30),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CREATED DATE',
                              style: GoogleFonts.jetBrainsMono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF64748B),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatter.formatDateTime(ticket.createdAt),
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: isDark ? Colors.white : const Color(0xFF0B1C30),
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
          ),
          const SizedBox(height: 28),

          // 3. Discussion Area
          Text(
            'Activity & Discussion',
            style: GoogleFonts.hankenGrotesk(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Discussion empty or list bubble
          buildCommentsList(comments, currentUser, isDark),
          const SizedBox(height: 16),

          // Input Box
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFDCE9FF).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppTheme.primaryNavy.withValues(alpha: 0.1),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (_commentImageUrl != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    height: 80,
                    width: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
                      image: DecorationImage(image: NetworkImage(_commentImageUrl!), fit: BoxFit.cover),
                    ),
                    alignment: Alignment.topRight,
                    child: InkWell(
                      onTap: () => setState(() => _commentImageUrl = null),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                        child: const Icon(Icons.close, size: 10, color: Colors.white),
                      ),
                    ),
                  ),
                Text(
                  'TULIS TANGGAPAN BARU',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryNavy,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _commentController,
                  maxLines: 4,
                  minLines: 2,
                  style: GoogleFonts.inter(fontSize: 14),
                  decoration: InputDecoration(
                    hintText: 'Write a comment or update...',
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                      fontSize: 13,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.only(top: 8),
                  decoration: BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.attach_file_rounded, size: 20),
                              onPressed: () => _pickCommentImage(ImageSource.gallery),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              icon: const Icon(Icons.image_outlined, size: 20),
                              onPressed: () => _pickCommentImage(ImageSource.camera),
                              visualDensity: VisualDensity.compact,
                            ),
                            IconButton(
                              icon: const Icon(Icons.sentiment_satisfied_alt_outlined, size: 20),
                              onPressed: () {},
                              visualDensity: VisualDensity.compact,
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _submitComment(currentUser.email, currentUser.fullName, currentUser.role),
                        icon: const Icon(Icons.send_rounded, size: 14, color: Colors.white),
                        label: Text(
                          'Send Reply',
                          style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryNavy,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    // Right Sidebar containing Timeline and Analysts Info
    Widget buildSidebar() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Action Panel
          buildActionCard(ticket, currentUser, isDark),
          const SizedBox(height: 16),

          // Status Timeline Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Status Timeline',
                      style: GoogleFonts.hankenGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => TrackingTicketPage(ticketId: widget.ticketId)),
                        );
                      },
                      icon: const Icon(Icons.gps_fixed_rounded, size: 12),
                      label: const Text('Track', style: TextStyle(fontSize: 11)),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                buildTimelineWidget(activityLogs, isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Assigned Agent Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
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
              children: [
                Text(
                  'ASSIGNED ANALYST',
                  style: GoogleFonts.jetBrainsMono(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFEFF4FF),
                        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFC5C5D3)),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppTheme.primaryNavy,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ticket.assignedToName ?? 'Belum Ditugaskan',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF0B1C30),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            ticket.assignedToName != null ? 'Helpdesk Analyst' : 'Unassigned Tech Support',
                            style: GoogleFonts.inter(
                              fontSize: 11,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (ticket.assignedToName != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Menghubungi ${ticket.assignedToName}...')),
                      );
                    },
                    icon: const Icon(Icons.mail_outline_rounded, size: 16),
                    label: const Text('Contact Analyst'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: AppTheme.primaryNavy),
                      minimumSize: const Size.fromHeight(40),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8F9FF),
      appBar: appBar,
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          children: [
            if (isLargeScreen)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: buildMainContent()),
                  const SizedBox(width: 20),
                  Expanded(flex: 1, child: buildSidebar()),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  buildMainContent(),
                  const SizedBox(height: 20),
                  buildSidebar(),
                ],
              ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget buildActionCard(dynamic ticket, UserModel currentUser, bool isDark) {
    Widget? actionWidget;

    if (currentUser.role == 'Admin') {
      if (ticket.status == 'Open') {
        actionWidget = ElevatedButton.icon(
          onPressed: () {
            ref.read(ticketProvider).acceptTicket(ticketId: widget.ticketId, actorName: currentUser.fullName);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket diterima!')));
          },
          icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: Colors.white),
          label: const Text('Terima Tiket (Accept)', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF0D9488),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
        );
      } else if (ticket.status == 'Assigned') {
        actionWidget = ElevatedButton.icon(
          onPressed: () => _showAssignDialog(currentUser.fullName),
          icon: const Icon(Icons.assignment_ind_outlined, size: 16, color: Colors.white),
          label: const Text('Pilihkan Helpdesk (Assign)', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.statusAssigned,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
        );
      }
    } else if (currentUser.role == 'Helpdesk') {
      if (ticket.status == 'In Progress' && (ticket.assignedToEmail == currentUser.email || ticket.assignedToEmail == null)) {
        actionWidget = ElevatedButton.icon(
          onPressed: () {
            ref.read(ticketProvider).completeTicket(ticketId: widget.ticketId, actorName: currentUser.fullName);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Tiket diselesaikan!')));
          },
          icon: const Icon(Icons.check_circle, size: 16, color: Colors.white),
          label: const Text('Selesaikan Tiket', style: TextStyle(fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.statusClosed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            minimumSize: const Size.fromHeight(44),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 2,
          ),
        );
      }
    }

    if (actionWidget == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark ? AppTheme.statusInProgress.withValues(alpha: 0.1) : AppTheme.statusInProgress.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.statusInProgress.withValues(alpha: 0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTheme.statusInProgress, size: 16),
              const SizedBox(width: 8),
              Text(
                'Required Action',
                style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.statusInProgress),
              ),
            ],
          ),
          const SizedBox(height: 12),
          actionWidget,
        ],
      ),
    );
  }

  Widget buildTimelineWidget(List<dynamic> logs, bool isDark) {
    if (logs.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Text(
          'Belum ada aktivitas terekam.',
          style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: logs.length,
      itemBuilder: (context, index) {
        final log = logs[index];
        final isLast = index == logs.length - 1;

        Color dotColor = isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8);
        if (log.title.contains('Created')) {
          dotColor = AppTheme.statusOpen;
        } else if (log.title.contains('Accepted')) {
          dotColor = AppTheme.statusAssigned;
        } else if (log.title.contains('Assigned')) {
          dotColor = AppTheme.statusAssigned;
        } else if (log.title.contains('Completed')) {
          dotColor = AppTheme.statusClosed;
        } else if (log.title.contains('Status')) {
          dotColor = AppTheme.statusInProgress;
        }

        return Stack(
          children: [
            // Vertical Line (only if not last)
            if (!isLast)
              Positioned(
                left: 11,
                top: 24,
                bottom: 0,
                width: 2,
                child: Container(
                  color: isDark ? const Color(0xFF334155).withValues(alpha: 0.5) : const Color(0xFFE2E8F0),
                ),
              ),
            // Dot
            Positioned(
              left: 0,
              top: 0,
              width: 24,
              height: 24,
              child: Container(
                decoration: BoxDecoration(
                  color: dotColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: dotColor.withValues(alpha: 0.35), blurRadius: 6, spreadRadius: 1)
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.only(left: 36, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    log.title,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0B1C30),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    DateFormatter.formatRelative(log.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    log.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'By ${log.actorName}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
                      fontStyle: FontStyle.italic,
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

  Widget buildCommentsList(List<dynamic> comments, UserModel currentUser, bool isDark) {
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B).withValues(alpha: 0.5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Column(
          children: [
            Icon(
              Icons.forum_outlined,
              size: 44,
              color: isDark ? const Color(0xFF475569) : const Color(0xFF94A3B8),
            ),
            const SizedBox(height: 12),
            Text(
              'Belum ada diskusi pada tiket ini. Mulai percakapan di bawah.',
              style: GoogleFonts.inter(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        final isMe = comment.senderEmail == currentUser.email;

        Color roleColor = AppTheme.primaryNavy;
        if (comment.senderRole == 'Admin') {
          roleColor = AppTheme.statusOpen;
        } else if (comment.senderRole == 'Helpdesk') {
          roleColor = AppTheme.statusAssigned;
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.8),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? AppTheme.primaryNavy.withValues(alpha: isDark ? 0.15 : 0.06)
                  : (isDark ? const Color(0xFF1E293B) : const Color(0xFFEFF4FF)),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(12),
                topRight: const Radius.circular(12),
                bottomLeft: isMe ? const Radius.circular(12) : Radius.zero,
                bottomRight: isMe ? Radius.zero : const Radius.circular(12),
              ),
              border: Border.all(
                color: isMe
                    ? AppTheme.primaryNavy.withValues(alpha: isDark ? 0.25 : 0.12)
                    : (isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        comment.senderName,
                        style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          comment.senderRole.toUpperCase(),
                          style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.bold, color: roleColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                if (comment.message.isNotEmpty)
                  Text(
                    comment.message,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark ? Colors.white : const Color(0xFF0B1C30),
                    ),
                  ),
                if (comment.imageUrl != null) ...[
                  if (comment.message.isNotEmpty) const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(comment.imageUrl!, fit: BoxFit.cover, height: 150, width: double.infinity),
                  ),
                ],
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormatter.formatRelative(comment.createdAt),
                    style: GoogleFonts.inter(
                      fontSize: 9,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
