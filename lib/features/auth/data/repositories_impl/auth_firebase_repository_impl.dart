import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:edara_hub_app_123/core/errors/faliure.dart';
import 'package:edara_hub_app_123/core/services/firebase_auth_service.dart';
import 'package:edara_hub_app_123/core/services/firestore_service.dart';
import 'package:edara_hub_app_123/features/auth/data/models/LoginRequest.dart';
import 'package:edara_hub_app_123/features/auth/data/models/RegisterRequest.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/data_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/entities/user_entity.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

/// Firebase-based implementation of AuthRepository.
/// 
/// This implementation:
/// - Uses Firebase Authentication for user authentication
/// - Stores user data in Firestore with approval workflow
/// - Checks user approval status before allowing login
/// - Generates custom tokens for approved users
@Singleton(as: AuthRepository)
class AuthFirebaseRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;

  AuthFirebaseRepositoryImpl({
    required FirebaseAuthService authService,
    required FirestoreService firestoreService,
  })  : _authService = authService,
        _firestoreService = firestoreService;

  @override
  Future<Either<Failure, DataEntity>> register(RegisterRequest request) async {
    try {
      // Step 1: Create Firebase Auth user
      final authResult = await _authService.signUp(
        email: request.email,
        password: request.password,
      );

      if (!authResult['success']) {
        return Left(Failure(message: authResult['message']));
      }

      final firebase_auth.User? firebaseUser = authResult['data'];
      if (firebaseUser == null) {
        return Left(Failure(message: 'Failed to create user account'));
      }

      // Step 2: Create user document in Firestore with approved: false
      final userData = {
        'name': request.name,
        'employee_id': request.employeeId,
        'email': request.email,
        'phone': request.phone,
        'ip_device': request.ipDevice,
        'status': 'active',
      };

      final firestoreResult = await _firestoreService.createUser(
        userId: firebaseUser.uid,
        userData: userData,
      );

      if (!firestoreResult['success']) {
        // Rollback: Delete the Firebase Auth user if Firestore creation fails
        await firebaseUser.delete();
        return Left(Failure(message: firestoreResult['message']));
      }

      // Step 3: Sign out the user immediately (they need approval first)
      await _authService.logout();

      // Step 4: Return success with pending approval message
      // Create a temporary UserEntity for the response
      final userEntity = UserEntity(
        name: request.name,
        phone: request.phone,
        email: request.email,
        employeeId: request.employeeId,
        ipDevice: request.ipDevice,
        status: 'pending',
      );

      return Right(DataEntity(
        token: '', // No token until approved
        userEntity: userEntity,
      ));
    } catch (e) {
      return Left(Failure(message: 'Registration failed: $e'));
    }
  }

  @override
  Future<Either<Failure, DataEntity>> login(LoginRequest request) async {
    try {
      // Step 1: Query Firestore to find user by employee_id (without authentication)
      // We need to get the email associated with this employee_id
      final usersResult = await _firestoreService.getUserByEmployeeId(
        employeeId: request.employeeId,
      );

      if (!usersResult['success']) {
        return Left(Failure(message: 'User not found'));
      }

      final userData = usersResult['data'] as Map<String, dynamic>?;
      if (userData == null) {
        return Left(Failure(message: 'User not found'));
      }

      final String email = userData['email'];
      final String userId = userData['id'];

      // Step 2: Authenticate with Firebase using email and password
      final authResult = await _authService.login(
        email: email,
        password: request.password,
      );

      if (!authResult['success']) {
        return Left(Failure(message: authResult['message']));
      }

      final firebase_auth.User? firebaseUser = authResult['data'];
      if (firebaseUser == null) {
        return Left(Failure(message: 'Authentication failed'));
      }

      // Step 3: Verify the authenticated user matches the queried user
      if (firebaseUser.uid != userId) {
        await _authService.logout();
        return Left(Failure(message: 'Authentication mismatch'));
      }

      // Step 4: Check approval status
      final bool isApproved = userData['approved'] ?? false;

      if (!isApproved) {
        // User is not approved yet - sign them out
        await _authService.logout();
        return Left(Failure(
          message: 'Your account is pending approval. Please wait for admin confirmation.',
        ));
      }

      // Step 5: Get Firebase ID token for approved user
      final String? idToken = await firebaseUser.getIdToken();

      if (idToken == null) {
        await _authService.logout();
        return Left(Failure(message: 'Failed to generate authentication token'));
      }

      // Step 6: Create UserEntity from Firestore data
      final userEntity = UserEntity(
        name: userData['name'] ?? '',
        phone: userData['phone'] ?? '',
        email: userData['email'] ?? '',
        employeeId: userData['employee_id'] ?? '',
        ipDevice: userData['ip_device'] ?? '',
        status: userData['status'] ?? 'active',
      );

      // Step 7: Return success with token and user data
      return Right(DataEntity(
        token: idToken,
        userEntity: userEntity,
      ));
    } catch (e) {
      return Left(Failure(message: 'Login failed: $e'));
    }
  }

  // Phone OTP Authentication methods (to be implemented later)
  @override
  Future<Either<Failure, String>> sendOTP(String phoneNumber) async {
    // TODO: Implement Firebase Phone Authentication
    return Left(Failure(message: 'Phone OTP not implemented yet'));
  }

  @override
  Future<Either<Failure, DataEntity>> verifyOTP(String verificationId, String otpCode) async {
    // TODO: Implement OTP verification
    return Left(Failure(message: 'OTP verification not implemented yet'));
  }

  @override
  Future<Either<Failure, bool>> checkUserApproval(String phoneNumber) async {
    try {
      // Query Firestore for user by phone number
      final usersResult = await _firestoreService.getUsersByApprovalStatus(
        approved: true,
      );

      if (!usersResult['success']) {
        return Left(Failure(message: 'Failed to check approval status'));
      }

      final users = usersResult['data'] as List;
      final approvedUser = users.firstWhere(
        (user) => user['phone'] == phoneNumber,
        orElse: () => null,
      );

      return Right(approvedUser != null);
    } catch (e) {
      return Left(Failure(message: 'Failed to check approval status: $e'));
    }
  }

  /// Checks if a user is approved by employee ID
  Future<Either<Failure, bool>> checkApprovalStatus(String employeeId) async {
    try {
      // Query Firestore for user by employee_id
      final usersResult = await _firestoreService.getUsersByApprovalStatus(
        approved: true,
      );

      if (!usersResult['success']) {
        return Left(Failure(message: 'Failed to check approval status'));
      }

      final users = usersResult['data'] as List;
      final approvedUser = users.firstWhere(
        (user) => user['employee_id'] == employeeId,
        orElse: () => null,
      );

      return Right(approvedUser != null);
    } catch (e) {
      return Left(Failure(message: 'Failed to check approval status: $e'));
    }
  }

  /// Listens to user approval status changes
  Stream<bool> listenToApprovalStatus(String userId) {
    return _firestoreService.listenToUser(userId).map((snapshot) {
      if (!snapshot.exists) return false;
      final data = snapshot.data() as Map<String, dynamic>?;
      return data?['approved'] ?? false;
    });
  }
}
