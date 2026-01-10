import 'package:edara_hub_app_123/core/routes_manager/routes.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_shared_prefs_local_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_api_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/repositories_impl/auth_repositroy_impl.dart';
import 'package:edara_hub_app_123/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routes_manager/route_generator.dart';

void main() {
  runApp(BlocProvider(
    create: (context)=>AuthCubit(authRepository: AuthRepositoryImpl(
            remoteDataSource: AuthApiRemoteDataSource(),
        localDataSource: AuthSharedPrefsLocalDataSource(),
        )
    ),
      child: const MainApp()
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => MaterialApp(
        debugShowCheckedModeBanner: false,
        onGenerateRoute: RouteGenerator.getRoute,
        initialRoute: Routes.signInRoute,
      ),
    );
  }
}
