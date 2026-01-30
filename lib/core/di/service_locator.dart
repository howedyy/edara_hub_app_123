import 'package:get_it/get_it.dart';
import 'package:edara_hub_app_123/core/services/firebase_auth_service.dart';
import 'package:edara_hub_app_123/core/services/firestore_service.dart';
import 'package:edara_hub_app_123/core/services/firebase_storage_service.dart';
import 'package:edara_hub_app_123/features/auth/data/repositories_impl/auth_firebase_repository_impl.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';
import 'package:edara_hub_app_123/features/auth/domain/use_cases/login_use_case.dart';
import 'package:edara_hub_app_123/features/auth/domain/use_cases/register_use_case.dart';
import 'package:edara_hub_app_123/features/auth/presentation/cubit/auth_cubit.dart';

final serviceLocator = GetIt.instance;

void setup() {
  // Register Firebase services
  serviceLocator.registerLazySingleton<FirebaseAuthService>(
    () => FirebaseAuthService(),
  );
  
  serviceLocator.registerLazySingleton<FirestoreService>(
    () => FirestoreService(),
  );
  
  serviceLocator.registerLazySingleton<FirebaseStorageService>(
    () => FirebaseStorageService(),
  );

  // Register Auth Repository (Firebase implementation)
  serviceLocator.registerLazySingleton<AuthRepository>(
    () => AuthFirebaseRepositoryImpl(
      authService: serviceLocator<FirebaseAuthService>(),
      firestoreService: serviceLocator<FirestoreService>(),
    ),
  );

  // Register Use Cases
  serviceLocator.registerLazySingleton<RegisterUseCase>(
    () => RegisterUseCase(
      authRepository: serviceLocator<AuthRepository>(),
    ),
  );

  serviceLocator.registerLazySingleton<LoginUseCase>(
    () => LoginUseCase(
      authRepository: serviceLocator<AuthRepository>(),
    ),
  );

  // Register Cubit
  serviceLocator.registerFactory<AuthCubit>(
    () => AuthCubit(
      registerUseCase: serviceLocator<RegisterUseCase>(),
      loginUseCase: serviceLocator<LoginUseCase>(),
    ),
  );
}
