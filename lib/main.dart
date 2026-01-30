import 'package:edara_hub_app_123/core/di/service_locator.dart';
import 'package:edara_hub_app_123/core/routes_manager/routes.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/local/auth_shared_prefs_local_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/data_sources/remote/auth_api_remote_data_source.dart';
import 'package:edara_hub_app_123/features/auth/data/repositories_impl/auth_repositroy_impl.dart';
import 'package:edara_hub_app_123/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'core/routes_manager/route_generator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Error initializing Firebase: $e');
    // Note: The app will continue to run, but Firebase features won't work
    // Make sure to configure your Firebase project credentials in firebase_options.dart
  }

  setup();

  runApp(BlocProvider(
    create: (context)=>serviceLocator.get<AuthCubit>(),
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
