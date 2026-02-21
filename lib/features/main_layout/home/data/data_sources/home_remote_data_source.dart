import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/features/main_layout/home/data/models/EventModel.dart';

abstract class HomeRemoteDataSource {
  Stream<List<EventModel>> getEvents(String userId);
  Future<void> addComment(String eventId, String comment);
  Future<void> toggleWishlist(String eventId, String userId, bool isAdding);
}

class HomeRemoteDataSourceImpl implements HomeRemoteDataSource {
  final FirebaseFirestore firestore;

  HomeRemoteDataSourceImpl(this.firestore);

  @override
  Stream<List<EventModel>> getEvents(String userId) {
    // We listen to all events and filter them in the stream mapping
    // This allows us to show events marked as 'all_users' OR events where the user is specifically allowed
    return firestore
        .collection('events')
        .where('is_published', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => EventModel.fromFirestore(doc)).where((event) {
        final isPublic = event.visibility == 'all_users';
        final isSpecificallyAllowed = event.allowedUsers.contains(userId);
        
        // Show if it's public OR the user is in the allowed list
        return isPublic || isSpecificallyAllowed;
      }).toList();
    });
  }

  @override
  Future<void> addComment(String eventId, String comment) async {
    await firestore.collection('events').doc(eventId).update({
      'comments': FieldValue.arrayUnion([comment]),
    });
  }

  @override
  Future<void> toggleWishlist(String eventId, String userId, bool isAdding) async {
    await firestore.collection('events').doc(eventId).update({
      'wishlist': isAdding
          ? FieldValue.arrayUnion([userId])
          : FieldValue.arrayRemove([userId]),
    });
  }
}
