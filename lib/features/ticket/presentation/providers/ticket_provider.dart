import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:project_mobile/features/ticket/data/models/ticket_model.dart';

final ticketProvider = ChangeNotifierProvider<TicketProvider>((ref) {
  return TicketProvider();
});

class TicketProvider extends ChangeNotifier {
  final List<TicketModel> _tickets = [];
  final List<CommentModel> _comments = [];
  final List<TicketActivityLog> _activityLogs = [];
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<TicketModel> get tickets => _tickets;

  TicketProvider();

  // Getters
  List<TicketModel> getTicketsForRole(String role, String email) {
    if (role == 'User') {
      return _tickets.where((t) => t.creatorEmail == email).toList();
    }
    // Helpdesk and Admin see all tickets
    return _tickets;
  }

  List<CommentModel> getCommentsForTicket(String ticketId) {
    return _comments.where((c) => c.ticketId == ticketId).toList();
  }

  List<TicketActivityLog> getActivityLogsForTicket(String ticketId) {
    final logs = _activityLogs.where((l) => l.ticketId == ticketId).toList();
    // Sort log by date descending (latest first) or ascending (for timeline, ascending is usually better)
    logs.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return logs;
  }

  Map<String, int> getTicketStats(String role, String email) {
    final roleTickets = getTicketsForRole(role, email);
    
    int openCount = 0;
    int assignedCount = 0;
    int progressCount = 0;
    int closedCount = 0;

    for (var ticket in roleTickets) {
      switch (ticket.status) {
        case 'Open':
          openCount++;
          break;
        case 'Assigned':
          assignedCount++;
          break;
        case 'In Progress':
          progressCount++;
          break;
        case 'Closed':
          closedCount++;
          break;
      }
    }

    return {
      'Total': roleTickets.length,
      'Open': openCount,
      'Assigned': assignedCount,
      'In Progress': progressCount,
      'Closed': closedCount,
    };
  }

  // Transactions
  Future<void> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String creatorEmail,
    required String creatorName,
    String? imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 1000));

    final newId = 'TCK-00${_tickets.length + 1}';
    final now = DateTime.now();

    final newTicket = TicketModel(
      id: newId,
      title: title,
      description: description,
      category: category,
      priority: priority,
      status: 'Open',
      creatorEmail: creatorEmail,
      creatorName: creatorName,
      createdAt: now,
      updatedAt: now,
      imageUrl: imageUrl,
    );

    _tickets.insert(0, newTicket); // Insert latest first

    // Log Activity
    _activityLogs.add(
      TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: newId,
        title: 'Ticket Created',
        description: 'Ticket registered by $creatorName with $priority priority',
        actorName: creatorName,
        createdAt: now,
      ),
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> acceptTicket({
    required String ticketId,
    required String actorName,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final oldTicket = _tickets[index];
    final now = DateTime.now();

    _tickets[index] = oldTicket.copyWith(
      status: 'Assigned',
      updatedAt: now,
    );

    _activityLogs.add(
      TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: ticketId,
        title: 'Ticket Accepted',
        description: 'Ticket accepted by Admin ($actorName) and status set to Assigned',
        actorName: actorName,
        createdAt: now,
      ),
    );

    notifyListeners();
  }

  Future<void> completeTicket({
    required String ticketId,
    required String actorName,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final oldTicket = _tickets[index];
    final now = DateTime.now();

    _tickets[index] = oldTicket.copyWith(
      status: 'Closed',
      updatedAt: now,
    );

    _activityLogs.add(
      TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: ticketId,
        title: 'Ticket Completed',
        description: 'Ticket completed by technician ($actorName) and status set to Closed',
        actorName: actorName,
        createdAt: now,
      ),
    );

    notifyListeners();
  }

  Future<void> assignTicket({
    required String ticketId,
    required String helpdeskEmail,
    required String helpdeskName,
    required String actorName,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final oldTicket = _tickets[index];
    final now = DateTime.now();

    _tickets[index] = oldTicket.copyWith(
      assignedToEmail: helpdeskEmail,
      assignedToName: helpdeskName,
      status: 'In Progress',
      updatedAt: now,
    );

    // Log Activity
    _activityLogs.add(
      TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: ticketId,
        title: 'Ticket Assigned',
        description: 'Assigned to support agent $helpdeskName',
        actorName: actorName,
        createdAt: now,
      ),
    );

    _activityLogs.add(
      TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}-status',
        ticketId: ticketId,
        title: 'Status Updated',
        description: 'Status changed from ${oldTicket.status} to In Progress due to assignment',
        actorName: actorName,
        createdAt: now,
      ),
    );

    notifyListeners();
  }

  Future<void> addComment({
    required String ticketId,
    required String senderEmail,
    required String senderName,
    required String senderRole,
    required String message,
    String? imageUrl,
  }) async {
    final now = DateTime.now();
    
    final newComment = CommentModel(
      id: 'COM-${now.millisecondsSinceEpoch}',
      ticketId: ticketId,
      senderEmail: senderEmail,
      senderName: senderName,
      senderRole: senderRole,
      message: message,
      createdAt: now,
      imageUrl: imageUrl,
    );

    _comments.add(newComment);

    // Update updatedAt of ticket
    final ticketIndex = _tickets.indexWhere((t) => t.id == ticketId);
    if (ticketIndex != -1) {
      _tickets[ticketIndex] = _tickets[ticketIndex].copyWith(updatedAt: now);
    }

    notifyListeners();
  }

  void clearAllTickets() {
    _tickets.clear();
    _comments.clear();
    _activityLogs.clear();
    notifyListeners();
  }
}
