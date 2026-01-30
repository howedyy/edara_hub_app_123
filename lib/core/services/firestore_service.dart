import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/core/services/firebase_service.dart';

/// Service for handling Firestore database operations.
/// 
/// This service provides methods for:
/// - User document creation and queries
/// - Event document queries with filters
/// - Registration document operations
/// 
/// All methods return results wrapped in a Map with success status and data/error messages.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseService.firestore;

  // Collection names
  static const String usersCollection = 'users';
  static const String eventsCollection = 'events';
  static const String registrationsCollection = 'registrations';
  static const String auditLogsCollection = 'audit_logs';

  /// Creates a new user document in Firestore.
  /// 
  /// Parameters:
  /// - userId: The unique ID for the user (typically from Firebase Auth)
  /// - userData: Map containing user data (name, email, employee_id, etc.)
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if creation was successful
  /// - message: String with success or error message
  /// - data: Document ID if successful, null otherwise
  Future<Map<String, dynamic>> createUser({
    required String userId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      // Add timestamps and default values
      final userDoc = {
        ...userData,
        'approved': false, // Default approval status
        'created_at': FieldValue.serverTimestamp(),
        'updated_at': FieldValue.serverTimestamp(),
        'approved_at': null,
      };

      await _firestore.collection(usersCollection).doc(userId).set(userDoc);

      return {
        'success': true,
        'message': 'User created successfully',
        'data': userId,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create user: $e',
        'data': null,
      };
    }
  }

  /// Retrieves a user document by ID.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: User document data if found, null otherwise
  Future<Map<String, dynamic>> getUser(String userId) async {
    try {
      final doc = await _firestore.collection(usersCollection).doc(userId).get();

      if (!doc.exists) {
        return {
          'success': false,
          'message': 'User not found',
          'data': null,
        };
      }

      return {
        'success': true,
        'message': 'User retrieved successfully',
        'data': {'id': doc.id, ...?doc.data()},
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve user: $e',
        'data': null,
      };
    }
  }

  /// Queries users by approval status.
  /// 
  /// Parameters:
  /// - approved: Filter by approval status (true/false)
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: List of user documents if successful, empty list otherwise
  Future<Map<String, dynamic>> getUsersByApprovalStatus({
    required bool approved,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('approved', isEqualTo: approved)
          .get();

      final users = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      return {
        'success': true,
        'message': 'Users retrieved successfully',
        'data': users,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to query users: $e',
        'data': [],
      };
    }
  }

  /// Retrieves a user by employee ID.
  /// 
  /// Parameters:
  /// - employeeId: The employee ID to search for
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: User document data if found, null otherwise
  Future<Map<String, dynamic>> getUserByEmployeeId({
    required String employeeId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(usersCollection)
          .where('employee_id', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'User not found',
          'data': null,
        };
      }

      final doc = querySnapshot.docs.first;
      return {
        'success': true,
        'message': 'User retrieved successfully',
        'data': {'id': doc.id, ...doc.data()},
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve user: $e',
        'data': null,
      };
    }
  }

  /// Updates a user's approval status.
  /// 
  /// Parameters:
  /// - userId: The user ID to update
  /// - approved: New approval status
  /// 
  /// Returns a Map containing success status and message
  Future<Map<String, dynamic>> updateUserApprovalStatus({
    required String userId,
    required bool approved,
  }) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).update({
        'approved': approved,
        'approved_at': approved ? FieldValue.serverTimestamp() : null,
        'updated_at': FieldValue.serverTimestamp(),
      });

      return {
        'success': true,
        'message': 'User approval status updated successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update user approval status: $e',
      };
    }
  }

  /// Deletes a user document.
  /// 
  /// Returns a Map containing success status and message
  Future<Map<String, dynamic>> deleteUser(String userId) async {
    try {
      await _firestore.collection(usersCollection).doc(userId).delete();

      return {
        'success': true,
        'message': 'User deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete user: $e',
      };
    }
  }

  /// Queries events with filters for visibility and publication status.
  /// 
  /// Parameters:
  /// - userId: The current user's ID (for visibility filtering)
  /// - isPublished: Filter by publication status (optional)
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: List of event documents if successful, empty list otherwise
  Future<Map<String, dynamic>> getEventsForUser({
    required String userId,
    bool? isPublished,
  }) async {
    try {
      Query query = _firestore.collection(eventsCollection);

      // Filter by publication status if specified
      if (isPublished != null) {
        query = query.where('is_published', isEqualTo: isPublished);
      }

      final querySnapshot = await query.get();

      // Filter events based on visibility
      final events = querySnapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final visibility = data['visibility'] as String?;
        final allowedUsers = data['allowed_users'] as List?;

        // Show if visibility is "all_users" or user is in allowed_users list
        return visibility == 'all_users' ||
            (visibility == 'selected_users' && allowedUsers?.contains(userId) == true);
      }).map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>}).toList();

      return {
        'success': true,
        'message': 'Events retrieved successfully',
        'data': events,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to query events: $e',
        'data': [],
      };
    }
  }

  /// Retrieves a single event by ID.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: Event document data if found, null otherwise
  Future<Map<String, dynamic>> getEvent(String eventId) async {
    try {
      final doc = await _firestore.collection(eventsCollection).doc(eventId).get();

      if (!doc.exists) {
        return {
          'success': false,
          'message': 'Event not found',
          'data': null,
        };
      }

      return {
        'success': true,
        'message': 'Event retrieved successfully',
        'data': {'id': doc.id, ...?doc.data()},
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to retrieve event: $e',
        'data': null,
      };
    }
  }

  /// Creates a registration for a user to an event.
  /// 
  /// Parameters:
  /// - userId: The user ID registering for the event
  /// - eventId: The event ID to register for
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if creation was successful
  /// - message: String with success or error message
  /// - data: Registration ID if successful, null otherwise
  Future<Map<String, dynamic>> createRegistration({
    required String userId,
    required String eventId,
  }) async {
    try {
      final registrationData = {
        'user_id': userId,
        'event_id': eventId,
        'registered_at': FieldValue.serverTimestamp(),
        'status': 'confirmed',
        'updated_at': FieldValue.serverTimestamp(),
      };

      final docRef = await _firestore
          .collection(registrationsCollection)
          .add(registrationData);

      // Update event's current_attendees count
      await _firestore.collection(eventsCollection).doc(eventId).update({
        'current_attendees': FieldValue.increment(1),
      });

      return {
        'success': true,
        'message': 'Registration created successfully',
        'data': docRef.id,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to create registration: $e',
        'data': null,
      };
    }
  }

  /// Deletes a registration.
  /// 
  /// Parameters:
  /// - userId: The user ID
  /// - eventId: The event ID
  /// 
  /// Returns a Map containing success status and message
  Future<Map<String, dynamic>> deleteRegistration({
    required String userId,
    required String eventId,
  }) async {
    try {
      // Find the registration document
      final querySnapshot = await _firestore
          .collection(registrationsCollection)
          .where('user_id', isEqualTo: userId)
          .where('event_id', isEqualTo: eventId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return {
          'success': false,
          'message': 'Registration not found',
        };
      }

      // Delete the registration
      await querySnapshot.docs.first.reference.delete();

      // Update event's current_attendees count
      await _firestore.collection(eventsCollection).doc(eventId).update({
        'current_attendees': FieldValue.increment(-1),
      });

      return {
        'success': true,
        'message': 'Registration deleted successfully',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete registration: $e',
      };
    }
  }

  /// Gets all registrations for a specific user.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: List of registration documents if successful, empty list otherwise
  Future<Map<String, dynamic>> getUserRegistrations(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection(registrationsCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final registrations = querySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();

      return {
        'success': true,
        'message': 'Registrations retrieved successfully',
        'data': registrations,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to query registrations: $e',
        'data': [],
      };
    }
  }

  /// Checks if a user is registered for an event.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if query was successful
  /// - message: String with success or error message
  /// - data: bool indicating if user is registered
  Future<Map<String, dynamic>> isUserRegistered({
    required String userId,
    required String eventId,
  }) async {
    try {
      final querySnapshot = await _firestore
          .collection(registrationsCollection)
          .where('user_id', isEqualTo: userId)
          .where('event_id', isEqualTo: eventId)
          .get();

      return {
        'success': true,
        'message': 'Registration status checked',
        'data': querySnapshot.docs.isNotEmpty,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to check registration status: $e',
        'data': false,
      };
    }
  }

  /// Listens to real-time changes in a user document.
  /// 
  /// Returns a Stream of document snapshots
  Stream<DocumentSnapshot> listenToUser(String userId) {
    return _firestore.collection(usersCollection).doc(userId).snapshots();
  }

  /// Listens to real-time changes in events collection.
  /// 
  /// Parameters:
  /// - userId: The current user's ID (for visibility filtering)
  /// 
  /// Returns a Stream of query snapshots
  Stream<QuerySnapshot> listenToEvents({String? userId}) {
    return _firestore
        .collection(eventsCollection)
        .where('is_published', isEqualTo: true)
        .snapshots();
  }

  /// Listens to real-time changes in user registrations.
  /// 
  /// Returns a Stream of query snapshots
  Stream<QuerySnapshot> listenToUserRegistrations(String userId) {
    return _firestore
        .collection(registrationsCollection)
        .where('user_id', isEqualTo: userId)
        .snapshots();
  }
}
