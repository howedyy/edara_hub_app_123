import 'package:get_it/get_it.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edara_hub_app_123/core/services/firebase_auth_service.dart';
import 'package:edara_hub_app_123/core/services/firestore_service.dart';
import 'package:edara_hub_app_123/core/services/firebase_storage_service.dart';
import 'package:edara_hub_app_123/features/auth/data/repositories_impl/auth_firebase_repository_impl.dart';
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart';
import 'package:edara_hub_app_123/features/auth/domain/use_cases/login_use_case.dart';
import 'package:edara_hub_app_123/features/auth/domain/use_cases/register_use_case.dart';
import 'package:edara_hub_app_123/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:edara_hub_app_123/features/main_layout/home/data/data_sources/home_remote_data_source.dart';
import 'package:edara_hub_app_123/features/main_layout/home/data/repositories_impl/home_repository_impl.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/get_events.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/add_comment.dart';
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/toggle_wishlist.dart';
import 'package:edara_hub_app_123/features/main_layout/home/presentation/manager/home_bloc.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/data/data_sources/deals_remote_data_source.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/data/repositories_impl/deals_repository_impl.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/repositories/deals_repository.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/use_cases/get_deals_use_case.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/domain/use_cases/toggle_deal_wishlist_use_case.dart';
import 'package:edara_hub_app_123/features/main_layout/deals/presentation/manager/deals_bloc.dart';

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

  // Home Feature
  // Data Source
  serviceLocator.registerLazySingleton<HomeRemoteDataSource>(
    () => HomeRemoteDataSourceImpl(FirebaseFirestore.instance),
  );

  // Repository
  serviceLocator.registerLazySingleton<HomeRepository>(
    () => HomeRepositoryImpl(remoteDataSource: serviceLocator<HomeRemoteDataSource>()),
  );

  // Use Cases
  serviceLocator.registerLazySingleton<GetEventsUseCase>(
    () => GetEventsUseCase(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerLazySingleton<AddCommentUseCase>(
    () => AddCommentUseCase(serviceLocator<HomeRepository>()),
  );
  serviceLocator.registerLazySingleton<ToggleWishlistUseCase>(
    () => ToggleWishlistUseCase(serviceLocator<HomeRepository>()),
  );

  // Bloc
  serviceLocator.registerFactory<HomeBloc>(
    () => HomeBloc(
      getEventsUseCase: serviceLocator<GetEventsUseCase>(),
      addCommentUseCase: serviceLocator<AddCommentUseCase>(),
      toggleWishlistUseCase: serviceLocator<ToggleWishlistUseCase>(),
    ),
  );

  // Deals Feature
  // Data Source
  serviceLocator.registerLazySingleton<DealsRemoteDataSource>(
    () => DealsRemoteDataSourceImpl(firestore: FirebaseFirestore.instance),
  );

  // Repository
  serviceLocator.registerLazySingleton<DealsRepository>(
    () => DealsRepositoryImpl(remoteDataSource: serviceLocator<DealsRemoteDataSource>()),
  );

  // Use Cases
  serviceLocator.registerLazySingleton<GetDealsUseCase>(
    () => GetDealsUseCase(serviceLocator<DealsRepository>()),
  );
  serviceLocator.registerLazySingleton<ToggleDealWishlistUseCase>(
    () => ToggleDealWishlistUseCase(serviceLocator<DealsRepository>()),
  );

  // Bloc
  serviceLocator.registerFactory<DealsBloc>(
    () => DealsBloc(
      getDealsUseCase: serviceLocator<GetDealsUseCase>(),
      toggleWishlistUseCase: serviceLocator<ToggleDealWishlistUseCase>(),
    ),
  );
}
