import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/ticket/presentation/providers/ticket_provider.dart';
import 'package:project_mobile/core/utils/date_formatter.dart';

class TrackingTicketPage extends ConsumerWidget {
  final String ticketId;

  const TrackingTicketPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ticketProviderVal = ref.watch(ticketProvider);

    // Find the ticket
    final ticketIndex = ticketProviderVal.tickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex == -1) {
      return Scaffold(
        appBar: AppBar(title: const Text('Track Ticket')),
        body: const Center(child: Text('Ticket not found')),
      );
    }

    final ticket = ticketProviderVal.tickets[ticketIndex];
    final logs = ticketProviderVal.getActivityLogsForTicket(ticketId);

    // Determine stepper status index
    int currentStep = 0;
    if (ticket.status == 'Assigned') {
      currentStep = 1;
    } else if (ticket.status == 'In Progress') {
      currentStep = 2;
    } else if (ticket.status == 'Closed') {
      currentStep = 3;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Track ${ticket.id}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Stepper progress indicator Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Handling Status',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStepIndicator('Open', currentStep >= 0, ticket.status == 'Open', isDark),
                      _buildStepLine(currentStep >= 1, isDark),
                      _buildStepIndicator('Assigned', currentStep >= 1, ticket.status == 'Assigned', isDark),
                      _buildStepLine(currentStep >= 2, isDark),
                      _buildStepIndicator('In Progress', currentStep >= 2, ticket.status == 'In Progress', isDark),
                      _buildStepLine(currentStep >= 3, isDark),
                      _buildStepIndicator('Closed', currentStep >= 3, ticket.status == 'Closed', isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Event Logs list
            Text(
              'Activity Log Activity',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            if (logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.history_rounded, size: 48, color: Colors.grey),
                    SizedBox(height: 12),
                    Text('No handling history logged yet.', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  final log = logs[logs.length - 1 - index]; // Show latest logs first
                  final isLast = index == logs.length - 1;

                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Timeline dot and line column
                      Column(
                        children: [
                          Container(
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: index == 0 ? Theme.of(context).colorScheme.primary : Colors.grey.shade400,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? const Color(0xFF0F172A) : Colors.white,
                                width: 2,
                              ),
                              boxShadow: index == 0
                                  ? [
                                      BoxShadow(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                                        blurRadius: 6,
                                        spreadRadius: 2,
                                      )
                                    ]
                                  : null,
                            ),
                          ),
                          if (!isLast)
                            Container(
                              width: 2,
                              height: 64,
                              color: Colors.grey.shade300,
                            ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      // Details card
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                log.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                log.description,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : Colors.grey.shade700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.person_outline, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    log.actorName,
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(Icons.access_time_rounded, size: 12, color: Colors.grey.shade500),
                                  const SizedBox(width: 4),
                                  Text(
                                    DateFormatter.formatRelative(log.createdAt),
                                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String name, bool isCompleted, bool isCurrent, bool isDark) {
    Color indicatorColor = Colors.grey.shade300;
    if (isCurrent) {
      indicatorColor = const Color(0xFF6366F1); // Indigo active
    } else if (isCompleted) {
      indicatorColor = const Color(0xFF10B981); // Emerald check
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F172A) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: indicatorColor,
              width: isCurrent ? 3 : 2,
            ),
          ),
          child: Center(
            child: isCompleted && !isCurrent
                ? const Icon(Icons.check, size: 16, color: Color(0xFF10B981))
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF6366F1) : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          name,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
            color: isCurrent
                ? const Color(0xFF6366F1)
                : isCompleted
                    ? const Color(0xFF10B981)
                    : Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(bool isActive, bool isDark) {
    return Expanded(
      child: Container(
        height: 2,
        color: isActive
            ? const Color(0xFF10B981)
            : isDark
                ? const Color(0xFF334155)
                : Colors.grey.shade300,
      ),
    );
  }
}
