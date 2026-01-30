import 'package:firebase_auth/firebase_auth.dart';
import 'package:edara_hub_app_123/core/services/firebase_service.dart';

/// Service for handling Firebase Authentication operations.
/// 
/// This service provides methods for:
/// - User registration with email/password
/// - User login with email/password
/// - User logout
/// - Getting current authenticated user
/// 
/// All methods return results wrapped in a Map with success status and data/error messages.
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseService.auth;

  /// Signs up a new user with email and password.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if signup was successful
  /// - message: String with success or error message
  /// - data: User object if successful, null otherwise
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.signUp('user@example.com', 'password123');
  /// if (result['success']) {
  ///   print('User created: ${result['data'].uid}');
  /// }
  /// ```
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'message': 'User registered successfully',
        'data': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'weak-password':
          errorMessage = 'The password provided is too weak.';
          break;
        case 'email-already-in-use':
          errorMessage = 'An account already exists for that email.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'data': null,
      };
    }
  }

  /// Logs in a user with email and password.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if login was successful
  /// - message: String with success or error message
  /// - data: User object if successful, null otherwise
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.login('user@example.com', 'password123');
  /// if (result['success']) {
  ///   print('Logged in: ${result['data'].uid}');
  /// }
  /// ```
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      return {
        'success': true,
        'message': 'Login successful',
        'data': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No user found for that email.';
          break;
        case 'wrong-password':
          errorMessage = 'Wrong password provided.';
          break;
        case 'invalid-email':
          errorMessage = 'The email address is not valid.';
          break;
        case 'user-disabled':
          errorMessage = 'This user account has been disabled.';
          break;
        default:
          errorMessage = 'Login failed: ${e.message}';
      }
      
      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'data': null,
      };
    }
  }

  /// Logs out the current user.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if logout was successful
  /// - message: String with success or error message
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.logout();
  /// if (result['success']) {
  ///   print('User logged out');
  /// }
  /// ```
  Future<Map<String, dynamic>> logout() async {
    try {
      await _auth.signOut();
      
      return {
        'success': true,
        'message': 'Logout successful',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'Logout failed: $e',
      };
    }
  }

  /// Gets the current authenticated user.
  /// 
  /// Returns the current User object if authenticated, null otherwise.
  /// 
  /// Example:
  /// ```dart
  /// final user = authService.getCurrentUser();
  /// if (user != null) {
  ///   print('Current user: ${user.email}');
  /// }
  /// ```
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  /// Stream of authentication state changes.
  /// 
  /// Emits the current User when authentication state changes.
  /// Useful for listening to login/logout events.
  /// 
  /// Example:
  /// ```dart
  /// authService.authStateChanges.listen((user) {
  ///   if (user != null) {
  ///     print('User is signed in');
  ///   } else {
  ///     print('User is signed out');
  ///   }
  /// });
  /// ```
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sends OTP verification code to the provided phone number.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if OTP was sent successfully
  /// - message: String with success or error message
  /// - verificationId: String with verification ID (needed for OTP verification)
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.sendOTP('+201234567890');
  /// if (result['success']) {
  ///   String verificationId = result['verificationId'];
  ///   // Navigate to OTP input screen
  /// }
  /// ```
  Future<Map<String, dynamic>> sendOTP({
    required String phoneNumber,
  }) async {
    try {
      String? verificationIdResult;
      String? errorMessage;

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        
        // Called when verification is completed automatically (Android only)
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification successful, sign in the user
          await _auth.signInWithCredential(credential);
        },
        
        // Called when verification fails
        verificationFailed: (FirebaseAuthException e) {
          switch (e.code) {
            case 'invalid-phone-number':
              errorMessage = 'The phone number format is invalid.';
              break;
            case 'too-many-requests':
              errorMessage = 'Too many requests. Please try again later.';
              break;
            case 'quota-exceeded':
              errorMessage = 'SMS quota exceeded. Please try again later.';
              break;
            default:
              errorMessage = 'Verification failed: ${e.message}';
          }
        },
        
        // Called when OTP code is sent
        codeSent: (String verificationId, int? resendToken) {
          verificationIdResult = verificationId;
        },
        
        // Called when auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          verificationIdResult = verificationId;
        },
      );

      // Wait a bit to ensure callbacks are processed
      await Future.delayed(const Duration(milliseconds: 500));

      if (errorMessage != null) {
        return {
          'success': false,
          'message': errorMessage,
          'verificationId': null,
        };
      }

      if (verificationIdResult != null) {
        return {
          'success': true,
          'message': 'OTP sent successfully',
          'verificationId': verificationIdResult,
        };
      }

      return {
        'success': false,
        'message': 'Failed to send OTP. Please try again.',
        'verificationId': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'verificationId': null,
      };
    }
  }

  /// Verifies the OTP code entered by the user.
  /// 
  /// Returns a Map containing:
  /// - success: bool indicating if OTP verification was successful
  /// - message: String with success or error message
  /// - data: User object if successful, null otherwise
  /// 
  /// Example:
  /// ```dart
  /// final result = await authService.verifyOTP(
  ///   verificationId: verificationId,
  ///   otpCode: '123456',
  /// );
  /// if (result['success']) {
  ///   print('Phone verified: ${result['data'].phoneNumber}');
  /// }
  /// ```
  Future<Map<String, dynamic>> verifyOTP({
    required String verificationId,
    required String otpCode,
  }) async {
    try {
      // Create phone auth credential
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: otpCode,
      );

      // Sign in with the credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);

      return {
        'success': true,
        'message': 'Phone number verified successfully',
        'data': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'invalid-verification-code':
          errorMessage = 'The verification code is invalid.';
          break;
        case 'invalid-verification-id':
          errorMessage = 'The verification ID is invalid.';
          break;
        case 'session-expired':
          errorMessage = 'The verification code has expired. Please request a new one.';
          break;
        case 'quota-exceeded':
          errorMessage = 'SMS quota exceeded. Please try again later.';
          break;
        default:
          errorMessage = 'Verification failed: ${e.message}';
      }

      return {
        'success': false,
        'message': errorMessage,
        'data': null,
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred: $e',
        'data': null,
      };
    }
  }

  /// Gets the phone number of the current authenticated user.
  /// 
  /// Returns the phone number string if available, null otherwise.
  String? getCurrentUserPhoneNumber() {
    return _auth.currentUser?.phoneNumber;
  }
}
