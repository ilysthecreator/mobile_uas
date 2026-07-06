
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'status': status,
      'creator_email': creatorEmail,
      'creator_name': creatorName,
      'assigned_to_email': assignedToEmail,
      'assigned_to_name': assignedToName,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      status: map['status'] ?? '',
      creatorEmail: map['creator_email'] ?? '',
      creatorName: map['creator_name'] ?? '',
      assignedToEmail: map['assigned_to_email'],
      assignedToName: map['assigned_to_name'],
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updated_at'] ?? DateTime.now().toIso8601String()),
      imageUrl: map['image_url'],
    );
  }

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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'sender_email': senderEmail,
      'sender_name': senderName,
      'sender_role': senderRole,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'image_url': imageUrl,
    };
  }

  factory CommentModel.fromMap(Map<String, dynamic> map) {
    return CommentModel(
      id: map['id'] ?? '',
      ticketId: map['ticket_id'] ?? '',
      senderEmail: map['sender_email'] ?? '',
      senderName: map['sender_name'] ?? '',
      senderRole: map['sender_role'] ?? '',
      message: map['message'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
      imageUrl: map['image_url'],
    );
  }
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

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'ticket_id': ticketId,
      'title': title,
      'description': description,
      'actor_name': actorName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory TicketActivityLog.fromMap(Map<String, dynamic> map) {
    return TicketActivityLog(
      id: map['id'] ?? '',
      ticketId: map['ticket_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      actorName: map['actor_name'] ?? '',
      createdAt: DateTime.parse(map['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }
}
