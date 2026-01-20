// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_local_data_source.dart'
    as _i405;
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_shared_prefs_local_data_source.dart'
    as _i167;
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_api_remote_data_source.dart'
    as _i391;
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_remote_data_source.dart'
    as _i279;
import 'package:edara_hub_app_123/features/auth/data/repositories_impl/auth_repositroy_impl.dart'
    as _i252;
import 'package:edara_hub_app_123/features/auth/domain/repositories/auth_repository.dart'
    as _i691;
import 'package:edara_hub_app_123/features/auth/domain/use_cases/login_use_case.dart'
    as _i988;
import 'package:edara_hub_app_123/features/auth/domain/use_cases/register_use_case.dart'
    as _i917;
import 'package:edara_hub_app_123/features/auth/presentation/cubit/auth_cubit.dart'
    as _i158;
import 'package:edara_hub_app_123/features/main_layout/home/data/data_sources/home_remote_data_source.dart'
    as _i420;
import 'package:edara_hub_app_123/features/main_layout/home/data/data_sources/remote/home_api_remote_data_source.dart'
    as _i125;
import 'package:edara_hub_app_123/features/main_layout/home/data/repositories_impl/home_repository_impl.dart'
    as _i226;
import 'package:edara_hub_app_123/features/main_layout/home/domain/repositories/home_repository.dart'
    as _i612;
import 'package:edara_hub_app_123/features/main_layout/home/domain/use_cases/get_events_use_case.dart'
    as _i786;
import 'package:edara_hub_app_123/features/main_layout/home/presentation/manager/home_bloc.dart'
    as _i382;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.singleton<_i279.AuthRemoteDataSource>(
      () => _i391.AuthApiRemoteDataSource(),
    );
    gh.singleton<_i405.AuthLocalDataSource>(
      () => _i167.AuthSharedPrefsLocalDataSource(),
    );
    gh.singleton<_i691.AuthRepository>(
      () => _i252.AuthRepositoryImpl(
        remoteDataSource: gh<_i279.AuthRemoteDataSource>(),
        localDataSource: gh<_i405.AuthLocalDataSource>(),
      ),
    );
    gh.singleton<_i420.HomeRemoteDataSource>(
      () => _i125.HomeApiRemoteDataSource(gh<_i405.AuthLocalDataSource>()),
    );
    gh.singleton<_i988.LoginUseCase>(
      () => _i988.LoginUseCase(authRepository: gh<_i691.AuthRepository>()),
    );
    gh.singleton<_i917.RegisterUseCase>(
      () => _i917.RegisterUseCase(authRepository: gh<_i691.AuthRepository>()),
    );
    gh.singleton<_i612.HomeRepository>(
      () => _i226.HomeRepositoryImpl(
        remoteDataSource: gh<_i420.HomeRemoteDataSource>(),
      ),
    );
    gh.factory<_i786.GetEventsUseCase>(
      () => _i786.GetEventsUseCase(gh<_i612.HomeRepository>()),
    );
    gh.singleton<_i158.AuthCubit>(
      () => _i158.AuthCubit(
        registerUseCase: gh<_i917.RegisterUseCase>(),
        loginUseCase: gh<_i988.LoginUseCase>(),
      ),
    );
    gh.factory<_i382.HomeBloc>(
      () => _i382.HomeBloc(gh<_i786.GetEventsUseCase>()),
    );
    return this;
  }
}
