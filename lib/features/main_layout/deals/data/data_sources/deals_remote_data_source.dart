import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/data/models/deal_model.dart';

abstract class DealsRemoteDataSource {
  Stream<List<DealModel>> getDeals(String userId);
  Future<void> toggleWishlist(String dealId, String userId, bool isAdding);
}

class DealsRemoteDataSourceImpl implements DealsRemoteDataSource {
  final FirebaseFirestore firestore;

  DealsRemoteDataSourceImpl({required this.firestore});

  @override
  Stream<List<DealModel>> getDeals(String userId) {
    print('DealsDataSource: Fetching deals for userId: $userId');
    return firestore
        .collection('deals')
        .where('is_published', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      print('DealsDataSource: Received ${snapshot.docs.length} published deals from Firestore');
      
      final allDeals = snapshot.docs.map((doc) {
        print('DealsDataSource: Processing deal ${doc.id}');
        try {
          return DealModel.fromFirestore(doc);
        } catch (e) {
          print('DealsDataSource: Error parsing deal ${doc.id}: $e');
          print('DealsDataSource: Deal data: ${doc.data()}');
          rethrow;
        }
      }).toList();
      
      final visibleDeals = allDeals.where((deal) {
        // Filter by visibility
        if (deal.visibility == 'all_users') {
          print('DealsDataSource: Deal ${deal.id} is visible to all users');
          return true;
        } else if (deal.visibility == 'selected_users') {
          final isAllowed = deal.allowedUsers.contains(userId);
          print('DealsDataSource: Deal ${deal.id} is for selected users. User allowed: $isAllowed');
          return isAllowed;
        }
        print('DealsDataSource: Deal ${deal.id} has unknown visibility: ${deal.visibility}');
        return false;
      }).toList();
      
      final nonExpiredDeals = visibleDeals.where((deal) {
        final expired = deal.isExpired;
        print('DealsDataSource: Deal ${deal.id} expired: $expired (validUntil: ${deal.validUntil})');
        return !expired;
      }).toList();
      
      // Sort by created_at in memory instead of using orderBy
      nonExpiredDeals.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      print('DealsDataSource: Returning ${nonExpiredDeals.length} deals after filtering');
      return nonExpiredDeals;
    });
  }

  @override
  Future<void> toggleWishlist(String dealId, String userId, bool isAdding) async {
    final dealRef = firestore.collection('deals').doc(dealId);
    
    if (isAdding) {
      await dealRef.update({
        'wishlist': FieldValue.arrayUnion([userId]),
      });
    } else {
      await dealRef.update({
        'wishlist': FieldValue.arrayRemove([userId]),
      });
    }
  }
}
