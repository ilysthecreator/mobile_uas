import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/features/auth/presentation/providers/auth_provider.dart';
import 'ticket_detail_page.dart';

class NotificationPage extends ConsumerWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketProviderVal = ref.watch(ticketProvider);
    final authProviderVal = ref.watch(authProvider);
    final user = authProviderVal.currentUser;

    // Dynamically build notifications based on user role and tickets in memory
    final List<Map<String, dynamic>> notifications = [];

    if (user != null) {
      final roleTickets = ticketProviderVal.getTicketsForRole(user.role, user.email);
      
      // Seed initial guidance notification
      notifications.add({
        'id': 'NOT-001',
        'title': 'Welcome to Helpdesk!',
        'body': 'Your account has been loaded successfully. You are logged in as ${user.fullName} (${user.role}).',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'icon': Icons.account_circle_outlined,
        'color': Colors.blue,
        'ticketId': null,
      });

      // Generate notifications for actual tickets
      for (var t in roleTickets) {
        notifications.add({
          'id': 'NOT-T-${t.id}',
          'title': 'New Ticket Registered',
          'body': 'Ticket "${t.title}" is currently listed as status: ${t.status}.',
          'time': t.createdAt,
          'icon': Icons.assignment_outlined,
          'color': Colors.indigo,
          'ticketId': t.id,
        });

        if (t.status != 'Open') {
          notifications.add({
            'id': 'NOT-S-${t.id}',
            'title': 'Ticket Status Updated',
            'body': 'Ticket #${t.id} has been marked as ${t.status}.',
            'time': t.updatedAt,
            'icon': Icons.loop_rounded,
            'color': Colors.amber,
            'ticketId': t.id,
          });
        }
      }
    }

    // Sort by time descending (latest first)
    notifications.sort((a, b) => (b['time'] as DateTime).compareTo(a['time'] as DateTime));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (notifications.isNotEmpty)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All notifications marked as read')),
                );
              },
              child: const Text('Clear All'),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No notifications yet',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'We will alert you here when ticket status changes.',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final ticketId = notif['ticketId'] as String?;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (notif['color'] as Color).withValues(alpha: isDark ? 0.15 : 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      notif['icon'] as IconData,
                      color: notif['color'] as Color,
                      size: 22,
                    ),
                  ),
                  title: Text(
                    notif['title'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4.0),
                    child: Text(
                      notif['body'] as String,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDark ? Colors.white70 : Colors.grey.shade700,
                      ),
                    ),
                  ),
                  onTap: () {
                    if (ticketId != null) {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => TicketDetailPage(ticketId: ticketId),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Notification read')),
                      );
                    }
                  },
                );
              },
            ),
    );
  }
}
