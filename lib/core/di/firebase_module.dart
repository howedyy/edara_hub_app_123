import 'package:edara_hub_app_123/core/services/firebase_auth_service.dart';
import 'package:edara_hub_app_123/core/services/firestore_service.dart';
import 'package:edara_hub_app_123/core/services/firebase_storage_service.dart';
import 'package:injectable/injectable.dart';

/// Module for registering Firebase services with dependency injection.
@module
abstract class FirebaseModule {
  @lazySingleton
  FirebaseAuthService get firebaseAuthService => FirebaseAuthService();

  @lazySingleton
  FirestoreService get firestoreService => FirestoreService();

  @lazySingleton
  FirebaseStorageService get firebaseStorageService => FirebaseStorageService();
}
