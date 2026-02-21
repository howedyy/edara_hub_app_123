import 'package:equatable/equatable.dart';

class DealEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? imageUrl;
  final double originalPrice;
  final double discountedPrice;
  final int discountPercentage;
  final String category;
  final DateTime validUntil;
  final List<String> wishlist;
  final String createdBy;
  final List<String> allowedUsers;
  final String visibility; // 'all_users' or 'selected_users'
  final bool isPublished;
  final DateTime createdAt;

  const DealEntity({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.originalPrice,
    required this.discountedPrice,
    required this.discountPercentage,
    required this.category,
    required this.validUntil,
    required this.wishlist,
    required this.createdBy,
    required this.allowedUsers,
    this.visibility = 'all_users',
    this.isPublished = false,
    required this.createdAt,
  });

  DealEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? originalPrice,
    double? discountedPrice,
    int? discountPercentage,
    String? category,
    DateTime? validUntil,
    List<String>? wishlist,
    String? createdBy,
    List<String>? allowedUsers,
    String? visibility,
    bool? isPublished,
    DateTime? createdAt,
  }) {
    return DealEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      originalPrice: originalPrice ?? this.originalPrice,
      discountedPrice: discountedPrice ?? this.discountedPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      category: category ?? this.category,
      validUntil: validUntil ?? this.validUntil,
      wishlist: wishlist ?? this.wishlist,
      createdBy: createdBy ?? this.createdBy,
      allowedUsers: allowedUsers ?? this.allowedUsers,
      visibility: visibility ?? this.visibility,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isExpired => DateTime.now().isAfter(validUntil);

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        imageUrl,
        originalPrice,
        discountedPrice,
        discountPercentage,
        category,
        validUntil,
        wishlist,
        createdBy,
        allowedUsers,
        visibility,
        isPublished,
        createdAt,
      ];
}
