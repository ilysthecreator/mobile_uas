import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent + 100,
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
    setState(() {
      _commentImageUrl = null;
    });

    // Let the widget redraw then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
  }



  void _showAssignDialog(String actorName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final authProviderVal = ref.read(authProvider);
        final helpdeskAgents = authProviderVal.mockUsers.where((u) => u.role == 'Helpdesk').toList();

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Assign Support Agent',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (helpdeskAgents.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(
                    'No helpdesk agents registered yet.\nRegister an email containing "helpdesk" or "support" to register one.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                )
              else
                ...helpdeskAgents.map((agent) {
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(agent.fullName.substring(0, 1)),
                    ),
                    title: Text(agent.fullName),
                    subtitle: Text(agent.email),
                    onTap: () {
                       ref.read(ticketProvider).assignTicket(
                        ticketId: widget.ticketId,
                        helpdeskEmail: agent.email,
                        helpdeskName: agent.fullName,
                        actorName: actorName,
                      );
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Ticket assigned to ${agent.fullName}')),
                      );
                    },
                  );
                }),
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

    // Find the current ticket
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
      case 'Assigned': statusColor = Colors.amber.shade700; break;
      case 'In Progress': statusColor = AppTheme.statusInProgress; break;
      default: statusColor = AppTheme.statusClosed;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(ticket.id),
      ),
      body: Column(
        children: [
          // Main scrollable area containing Details -> Timeline -> Chat
          Expanded(
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ticket Title Card
                  _buildTicketHeaderCard(ticket, statusColor, isDark),
                  const SizedBox(height: 16),

                  // Required Action Panel (Lecturer Revision Flow)
                  _buildActionCard(ticket, currentUser, isDark),
                  const SizedBox(height: 12),

                  // Ticket Details (Description & Attachment)
                  _buildDescriptionCard(ticket, isDark),
                  const SizedBox(height: 24),

                  // Status Tracking Timeline (FR-011)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ticket Activity Timeline',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => TrackingTicketPage(ticketId: widget.ticketId),
                            ),
                          );
                        },
                        icon: const Icon(Icons.location_searching_rounded, size: 16),
                        label: const Text('View Full Tracking'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTimelineWidget(activityLogs, isDark),
                  const SizedBox(height: 28),

                  // Discussion Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Discussion Room',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${comments.length} comments',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Chat list
                  _buildChatBubbleList(comments, currentUser, isDark),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // Message Input Box at the Bottom
          _buildMessageInputArea(currentUser, isDark),
        ],
      ),
    );
  }

  Widget _buildActionCard(dynamic ticket, UserModel currentUser, bool isDark) {
    Widget? actionWidget;

    if (currentUser.role == 'Admin') {
      if (ticket.status == 'Open') {
        actionWidget = ElevatedButton.icon(
          onPressed: () {
            ref.read(ticketProvider).acceptTicket(
              ticketId: widget.ticketId,
              actorName: currentUser.fullName,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket accepted successfully! Status changed to Assigned.')),
            );
          },
          icon: const Icon(Icons.check_circle_outline_rounded),
          label: const Text('Terima Tiket (Accept Request)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      } else if (ticket.status == 'Assigned') {
        actionWidget = ElevatedButton.icon(
          onPressed: () => _showAssignDialog(currentUser.fullName),
          icon: const Icon(Icons.assignment_ind_outlined),
          label: const Text('Pilihkan Helpdesk (Assign Agent)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber.shade700,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    } else if (currentUser.role == 'Helpdesk') {
      if (ticket.status == 'In Progress' && (ticket.assignedToEmail == currentUser.email || ticket.assignedToEmail == null)) {
        actionWidget = ElevatedButton.icon(
          onPressed: () {
            ref.read(ticketProvider).completeTicket(
              ticketId: widget.ticketId,
              actorName: currentUser.fullName,
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Ticket completed successfully! Status changed to Closed.')),
            );
          },
          icon: const Icon(Icons.task_alt_rounded),
          label: const Text('Selesai Pekerjaan (Finish Ticket)'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }

    if (actionWidget == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.blue.shade50.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : Colors.blue.shade100,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline_rounded, color: isDark ? Colors.blue.shade300 : Colors.blue.shade700, size: 20),
              const SizedBox(width: 8),
              Text(
                'Required Action / Langkah Tindakan',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.blue.shade300 : Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          actionWidget,
        ],
      ),
    );
  }

  Widget _buildTicketHeaderCard(dynamic ticket, Color statusColor, bool isDark) {
    Color priorityColor;
    switch (ticket.priority) {
      case 'Low': priorityColor = AppTheme.priorityLow; break;
      case 'Medium': priorityColor = AppTheme.priorityMedium; break;
      default: priorityColor = AppTheme.priorityHigh;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  ticket.category,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  ticket.status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            ticket.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 0.5),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Reporter', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(ticket.creatorName, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Priority', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        ticket.priority,
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: priorityColor),
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Assignee', style: TextStyle(fontSize: 10, color: Colors.grey)),
                  const SizedBox(height: 2),
                  Text(
                    ticket.assignedToName ?? 'Unassigned',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ticket.assignedToName == null ? Colors.redAccent : null,
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

  Widget _buildDescriptionCard(dynamic ticket, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Problem Description',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey),
          ),
          const SizedBox(height: 10),
          Text(
            ticket.description,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
          if (ticket.imageUrl != null) ...[
            const SizedBox(height: 20),
            const Text(
              'Attached File/Screenshot',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  // Previews image full screen
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
                child: Hero(
                  tag: 'attachment-${ticket.id}',
                  child: Image.network(
                    ticket.imageUrl!,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Vertical timeline build
  Widget _buildTimelineWidget(List<dynamic> logs, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
      ),
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: logs.length,
        itemBuilder: (context, index) {
          final log = logs[index];
          final isLast = index == logs.length - 1;

          // Different colored node for logs
          Color dotColor = Colors.grey.shade400;
          if (log.title.contains('Created')) {
            dotColor = AppTheme.statusOpen;
          } else if (log.title.contains('Accepted')) {
            dotColor = Colors.amber.shade700;
          } else if (log.title.contains('Assigned')) {
            dotColor = Colors.amber;
          } else if (log.title.contains('Completed')) {
            dotColor = AppTheme.statusClosed;
          } else if (log.title.contains('Status')) {
            dotColor = AppTheme.statusInProgress;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Visual Line column
              Column(
                children: [
                  Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                      boxShadow: [
                        BoxShadow(color: dotColor.withValues(alpha: 0.4), blurRadius: 4, spreadRadius: 1)
                      ],
                    ),
                  ),
                  if (!isLast)
                    Container(
                      width: 2,
                      height: 50,
                      color: Colors.grey.shade300,
                    ),
                ],
              ),
              const SizedBox(width: 16),
              // Content Column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          log.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isLast ? Theme.of(context).colorScheme.primary : null,
                          ),
                        ),
                        Text(
                          DateFormatter.formatRelative(log.createdAt),
                          style: const TextStyle(fontSize: 10, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      log.description,
                      style: TextStyle(fontSize: 12, color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'By ${log.actorName}',
                      style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChatBubbleList(List<dynamic> comments, UserModel currentUser, bool isDark) {
    if (comments.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(vertical: 32),
        alignment: Alignment.center,
        child: Text(
          'No replies yet. Type message below to start.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400, fontStyle: FontStyle.italic),
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

        // Custom sender tag colors
        Color roleColor = Colors.grey;
        if (comment.senderRole == 'Admin') {
          roleColor = Colors.redAccent;
        } else if (comment.senderRole == 'Helpdesk') {
          roleColor = Colors.amber.shade700;
        } else {
          roleColor = Theme.of(context).colorScheme.primary;
        }

        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isMe
                  ? Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.2 : 0.08)
                  : isDark
                      ? const Color(0xFF1E293B)
                      : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: isMe ? const Radius.circular(16) : const Radius.circular(0),
                bottomRight: isMe ? const Radius.circular(0) : const Radius.circular(16),
              ),
              border: Border.all(
                color: isMe
                    ? Theme.of(context).colorScheme.primary.withValues(alpha: isDark ? 0.4 : 0.2)
                    : isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header (Sender Name, Role, Timestamp)
                if (!isMe) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        comment.senderName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: roleColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          comment.senderRole,
                          style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: roleColor),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                // Comment Message Body
                if (comment.message.isNotEmpty)
                  Text(
                    comment.message,
                    style: const TextStyle(fontSize: 14),
                  ),

                // Attached comment image
                if (comment.imageUrl != null) ...[
                  if (comment.message.isNotEmpty) const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(comment.imageUrl!, fit: BoxFit.cover, height: 130, width: double.infinity),
                  ),
                ],
                const SizedBox(height: 4),
                // Timestamp
                Align(
                  alignment: Alignment.bottomRight,
                  child: Text(
                    DateFormatter.formatRelative(comment.createdAt),
                    style: TextStyle(
                      fontSize: 9,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
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

  Widget _buildMessageInputArea(UserModel currentUser, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(
          top: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image preview in comment composer
          if (_commentImageUrl != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              height: 60,
              width: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(image: NetworkImage(_commentImageUrl!), fit: BoxFit.cover),
              ),
              alignment: Alignment.topRight,
              child: CircleAvatar(
                radius: 10,
                backgroundColor: Colors.black,
                child: IconButton(
                  padding: EdgeInsets.zero,
                  icon: const Icon(Icons.close, size: 12, color: Colors.white),
                  onPressed: () {
                    setState(() {
                      _commentImageUrl = null;
                    });
                  },
                ),
              ),
            ),
          
          Row(
            children: [
              // Attachment Trigger Icon
              IconButton(
                icon: Icon(
                  Icons.add_photo_alternate_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                onPressed: () {
                  // Simulate image attachment picker
                  setState(() {
                    _commentImageUrl = 'https://images.unsplash.com/photo-1488590528505-98d2b5aba04b?auto=format&fit=crop&w=300&q=80';
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Demo screenshot attached to response!')),
                  );
                },
              ),
              
              // Input Field
              Expanded(
                child: TextFormField(
                  controller: _commentController,
                  decoration: InputDecoration(
                    hintText: 'Type your message...',
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                    ),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 4,
                ),
              ),
              const SizedBox(width: 8),
              
              // Send Button
              CircleAvatar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: IconButton(
                  icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                  onPressed: () => _submitComment(currentUser.email, currentUser.fullName, currentUser.role),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
