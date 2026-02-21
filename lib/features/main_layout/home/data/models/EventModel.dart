import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/entities/event_entity.dart';

class EventModel extends EventEntity {
  const EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.comments,
    required super.wishlist,
    required super.createdBy,
    required super.allowedUsers,
    required super.visibility,
    required super.attachments,
  });

  factory EventModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    final allowed = data['allowedUsers'] ?? data['allowed_users'] ?? [];
    
    return EventModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      comments: List<String>.from(data['comments'] ?? []),
      wishlist: List<String>.from(data['wishlist'] ?? []),
      createdBy: data['createdBy'] ?? data['created_by'] ?? '',
      allowedUsers: List<String>.from(allowed),
      visibility: data['visibility'] ?? 'all_users',
      attachments: List<String>.from(data['attachments'] ?? []),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'comments': comments,
      'wishlist': wishlist,
      'createdBy': createdBy,
      'allowedUsers': allowedUsers,
      'visibility': visibility,
      'attachments': attachments,
    };
  }
}
