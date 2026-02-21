import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/entities/deal_entity.dart';

class DealModel extends DealEntity {
  const DealModel({
    required super.id,
    required super.title,
    required super.description,
    super.imageUrl,
    required super.originalPrice,
    required super.discountedPrice,
    required super.discountPercentage,
    required super.category,
    required super.validUntil,
    required super.wishlist,
    required super.createdBy,
    required super.allowedUsers,
    super.visibility,
    super.isPublished,
    required super.createdAt,
  });

  factory DealModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DealModel(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['image_url'],
      originalPrice: (data['original_price'] ?? 0).toDouble(),
      discountedPrice: (data['discounted_price'] ?? 0).toDouble(),
      discountPercentage: data['discount_percentage'] ?? 0,
      category: data['category'] ?? 'General',
      validUntil: (data['valid_until'] as Timestamp).toDate(),
      wishlist: List<String>.from(data['wishlist'] ?? []),
      createdBy: data['created_by'] ?? '',
      allowedUsers: List<String>.from(data['allowed_users'] ?? []),
      visibility: data['visibility'] ?? 'all_users',
      isPublished: data['is_published'] ?? false,
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'original_price': originalPrice,
      'discounted_price': discountedPrice,
      'discount_percentage': discountPercentage,
      'category': category,
      'valid_until': Timestamp.fromDate(validUntil),
      'wishlist': wishlist,
      'created_by': createdBy,
      'allowed_users': allowedUsers,
      'visibility': visibility,
      'is_published': isPublished,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': FieldValue.serverTimestamp(),
    };
  }
}
