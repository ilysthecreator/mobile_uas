
class TicketModel {
  final String id;
  final String title;
  final String description;
  final String category; // 'IT Support', 'Network', 'Hardware', 'Software', 'Facilities'
  final String priority; // 'Low', 'Medium', 'High'
  final String status;   // 'Open', 'In Progress', 'Resolved', 'Closed'
  final String creatorEmail;
  final String creatorName;
  final String? assignedToEmail;
  final String? assignedToName;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? imageUrl; // Attachment

  TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.status,
    required this.creatorEmail,
    required this.creatorName,
    this.assignedToEmail,
    this.assignedToName,
    required this.createdAt,
    required this.updatedAt,
    this.imageUrl,
  });

  TicketModel copyWith({
    String? id,
    String? title,
    String? description,
    String? category,
    String? priority,
    String? status,
    String? creatorEmail,
    String? creatorName,
    String? assignedToEmail,
    String? assignedToName,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? imageUrl,
  }) {
    return TicketModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      creatorEmail: creatorEmail ?? this.creatorEmail,
      creatorName: creatorName ?? this.creatorName,
      assignedToEmail: assignedToEmail ?? this.assignedToEmail,
      assignedToName: assignedToName ?? this.assignedToName,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}

class CommentModel {
  final String id;
  final String ticketId;
  final String senderEmail;
  final String senderName;
  final String senderRole; // 'User', 'Helpdesk', 'Admin'
  final String message;
  final DateTime createdAt;
  final String? imageUrl;

  CommentModel({
    required this.id,
    required this.ticketId,
    required this.senderEmail,
    required this.senderName,
    required this.senderRole,
    required this.message,
    required this.createdAt,
    this.imageUrl,
  });
}

class TicketActivityLog {
  final String id;
  final String ticketId;
  final String title;
  final String description;
  final String actorName;
  final DateTime createdAt;

  TicketActivityLog({
    required this.id,
    required this.ticketId,
    required this.title,
    required this.description,
    required this.actorName,
    required this.createdAt,
  });
}
