import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Firebase service instances for the application.
/// 
/// This class provides centralized access to Firebase services:
/// - FirebaseAuth for authentication
/// - FirebaseFirestore for database operations
/// - FirebaseStorage for media file storage
/// 
/// Usage:
/// ```dart
/// final auth = FirebaseService.auth;
/// final firestore = FirebaseService.firestore;
/// final storage = FirebaseService.storage;
/// ```
class FirebaseService {
  // Private constructor to prevent instantiation
  FirebaseService._();

  /// Firebase Authentication instance
  static FirebaseAuth get auth => FirebaseAuth.instance;

  /// Cloud Firestore instance
  static FirebaseFirestore get firestore => FirebaseFirestore.instance;

  /// Firebase Storage instance
  static FirebaseStorage get storage => FirebaseStorage.instance;
}
