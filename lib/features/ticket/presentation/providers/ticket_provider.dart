import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:project_mobile/features/ticket/data/models/ticket_model.dart';

final ticketProvider = ChangeNotifierProvider<TicketProvider>((ref) {
  return TicketProvider();
});

class TicketProvider extends ChangeNotifier {
  SupabaseClient get _supabase => Supabase.instance.client;

  List<TicketModel> _tickets = [];
  final List<CommentModel> _comments = [];
  final List<TicketActivityLog> _activityLogs = [];
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  List<TicketModel> get tickets => _tickets;

  TicketProvider();

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================
  // FETCH DATA DARI SUPABASE
  // ============================

  /// Fetch semua tiket dari database Supabase
  Future<void> fetchTickets() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('tickets')
          .select()
          .order('created_at', ascending: false);

      _tickets = (response as List)
          .map((t) => TicketModel.fromMap(t))
          .toList();
    } catch (e) {
      debugPrint('Error fetching tickets: $e');
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Fetch komentar dan activity log untuk tiket tertentu
  Future<void> fetchTicketDetails(String ticketId) async {
    _errorMessage = null;
    notifyListeners();
    try {
      final commentsResponse = await _supabase
          .from('comments')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      final logsResponse = await _supabase
          .from('ticket_activity_logs')
          .select()
          .eq('ticket_id', ticketId)
          .order('created_at', ascending: true);

      // Hapus data lama untuk tiket ini agar tidak duplikat
      _comments.removeWhere((c) => c.ticketId == ticketId);
      _comments.addAll(
        (commentsResponse as List).map((c) => CommentModel.fromMap(c)).toList(),
      );

      _activityLogs.removeWhere((l) => l.ticketId == ticketId);
      _activityLogs.addAll(
        (logsResponse as List).map((l) => TicketActivityLog.fromMap(l)).toList(),
      );

      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching ticket details: $e');
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  // ============================
  // GETTERS (dari local cache)
  // ============================

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
    // Sort log by date ascending (for timeline)
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

  // ============================
  // OPERASI CRUD KE SUPABASE
  // ============================

  /// Membuat tiket baru dan menyimpannya ke Supabase
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

    final newId = 'TCK-${DateTime.now().millisecondsSinceEpoch}';
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

    try {
      // Simpan tiket ke database Supabase
      await _supabase.from('tickets').insert(newTicket.toMap());
      _tickets.insert(0, newTicket); // Tambahkan ke local cache

      // Simpan activity log
      final newLog = TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: newId,
        title: 'Ticket Created',
        description: 'Ticket registered by $creatorName with $priority priority',
        actorName: creatorName,
        createdAt: now,
      );
      await _supabase.from('ticket_activity_logs').insert(newLog.toMap());
      _activityLogs.add(newLog);
    } catch (e) {
      debugPrint('Error creating ticket: $e');
      rethrow;
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Terima tiket (ubah status ke Assigned)
  Future<void> acceptTicket({
    required String ticketId,
    required String actorName,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final now = DateTime.now();

    try {
      // Update status di Supabase
      await _supabase.from('tickets').update({
        'status': 'Assigned',
        'updated_at': now.toIso8601String(),
      }).eq('id', ticketId);

      // Simpan activity log
      final newLog = TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: ticketId,
        title: 'Ticket Accepted',
        description: 'Ticket accepted by Admin ($actorName) and status set to Assigned',
        actorName: actorName,
        createdAt: now,
      );
      await _supabase.from('ticket_activity_logs').insert(newLog.toMap());

      // Update local cache
      _tickets[index] = _tickets[index].copyWith(
        status: 'Assigned',
        updatedAt: now,
      );
      _activityLogs.add(newLog);
      notifyListeners();
    } catch (e) {
      debugPrint('Error accepting ticket: $e');
    }
  }

  /// Selesaikan tiket (ubah status ke Closed)
  Future<void> completeTicket({
    required String ticketId,
    required String actorName,
  }) async {
    final index = _tickets.indexWhere((t) => t.id == ticketId);
    if (index == -1) return;

    final now = DateTime.now();

    try {
      await _supabase.from('tickets').update({
        'status': 'Closed',
        'updated_at': now.toIso8601String(),
      }).eq('id', ticketId);

      final newLog = TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: ticketId,
        title: 'Ticket Completed',
        description: 'Ticket completed by technician ($actorName) and status set to Closed',
        actorName: actorName,
        createdAt: now,
      );
      await _supabase.from('ticket_activity_logs').insert(newLog.toMap());

      _tickets[index] = _tickets[index].copyWith(
        status: 'Closed',
        updatedAt: now,
      );
      _activityLogs.add(newLog);
      notifyListeners();
    } catch (e) {
      debugPrint('Error completing ticket: $e');
    }
  }

  /// Assign tiket ke teknisi helpdesk
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

    try {
      await _supabase.from('tickets').update({
        'assigned_to_email': helpdeskEmail,
        'assigned_to_name': helpdeskName,
        'status': 'In Progress',
        'updated_at': now.toIso8601String(),
      }).eq('id', ticketId);

      // Log Activity
      final log1 = TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}',
        ticketId: ticketId,
        title: 'Ticket Assigned',
        description: 'Assigned to support agent $helpdeskName',
        actorName: actorName,
        createdAt: now,
      );
      final log2 = TicketActivityLog(
        id: 'LOG-${now.millisecondsSinceEpoch}-status',
        ticketId: ticketId,
        title: 'Status Updated',
        description: 'Status changed from ${oldTicket.status} to In Progress due to assignment',
        actorName: actorName,
        createdAt: now,
      );

      await _supabase
          .from('ticket_activity_logs')
          .insert([log1.toMap(), log2.toMap()]);

      // Update local cache
      _tickets[index] = oldTicket.copyWith(
        assignedToEmail: helpdeskEmail,
        assignedToName: helpdeskName,
        status: 'In Progress',
        updatedAt: now,
      );
      _activityLogs.addAll([log1, log2]);
      notifyListeners();
    } catch (e) {
      debugPrint('Error assigning ticket: $e');
    }
  }

  /// Tambahkan komentar pada tiket
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

    try {
      // Simpan komentar ke Supabase
      await _supabase.from('comments').insert(newComment.toMap());

      // Update timestamp tiket
      await _supabase.from('tickets').update({
        'updated_at': now.toIso8601String(),
      }).eq('id', ticketId);

      // Update local cache
      _comments.add(newComment);
      final ticketIndex = _tickets.indexWhere((t) => t.id == ticketId);
      if (ticketIndex != -1) {
        _tickets[ticketIndex] = _tickets[ticketIndex].copyWith(updatedAt: now);
      }
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }

  void clearAllTickets() {
    _tickets.clear();
    _comments.clear();
    _activityLogs.clear();
    notifyListeners();
  }
}
