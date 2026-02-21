import 'package:equatable/equatable.dart';

class EventEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final List<String> comments;
  final List<String> wishlist;
  final String createdBy;
  final List<String> allowedUsers;
  final String visibility; // 'all_users' or 'selected_users'
  final List<String> attachments; // Multimedia links (images/videos)

  const EventEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.comments,
    required this.wishlist,
    required this.createdBy,
    required this.allowedUsers,
    this.visibility = 'all_users',
    this.attachments = const [],
  });

  EventEntity copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? comments,
    List<String>? wishlist,
    String? createdBy,
    List<String>? allowedUsers,
    String? visibility,
    List<String>? attachments,
  }) {
    return EventEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      comments: comments ?? this.comments,
      wishlist: wishlist ?? this.wishlist,
      createdBy: createdBy ?? this.createdBy,
      allowedUsers: allowedUsers ?? this.allowedUsers,
      visibility: visibility ?? this.visibility,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        comments,
        wishlist,
        createdBy,
        allowedUsers,
        visibility,
        attachments
      ];
}
