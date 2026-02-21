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
import 'package:edara_hub_app_123/core/services/firebase_auth_service.dart';

import 'core/routes_manager/route_generator.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  print('=== APP STARTING ===');
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error initializing Firebase: $e');
    print('Stack trace: ${StackTrace.current}');
  }

  // Setup dependency injection
  try {
    setup();
    print('✅ Service locator setup complete');
  } catch (e) {
    print('❌ Error setting up service locator: $e');
    print('Stack trace: ${StackTrace.current}');
  }

  // Determine initial route based on auth status
  String initialRoute = Routes.signInRoute;
  try {
    final user = serviceLocator.get<FirebaseAuthService>().getCurrentUser();
    if (user != null) {
      print('✅ User already logged in: ${user.uid}');
      initialRoute = Routes.mainRoute;
    } else {
      print('ℹ️ No user logged in, showing sign in screen');
    }
  } catch (e) {
    print('❌ Error checking auth status: $e');
    // Default to sign in route on error
  }

  print('ℹ️ Initial route: $initialRoute');
  print('=== LAUNCHING APP ===');

  runApp(BlocProvider(
    create: (context)=>serviceLocator.get<AuthCubit>(),
      child: MainApp(initialRoute: initialRoute)
  ));
}

class MainApp extends StatelessWidget {
  final String initialRoute;
  const MainApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    print('ℹ️ Building MainApp with initialRoute: $initialRoute');
    
    return ScreenUtilInit(
      designSize: const Size(430, 932),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        print('ℹ️ ScreenUtilInit builder called');
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          onGenerateRoute: (settings) {
            print('ℹ️ Generating route for: ${settings.name}');
            return RouteGenerator.getRoute(settings);
          },
          initialRoute: initialRoute,
          // Add error builder to catch widget errors
          builder: (context, widget) {
            if (widget == null) {
              print('❌ Widget is null in MaterialApp builder');
              return const Scaffold(
                body: Center(
                  child: Text('Error: Widget is null'),
                ),
              );
            }
            return widget;
          },
        );
      },
    );
  }
}
