import 'package:edara_hub_app/core/routes_manager/routes.dart';
import 'package:edara_hub_app/features/auth/presentation/screens/sign_in_screen.dart';
import 'package:edara_hub_app/features/auth/presentation/screens/sign_up_screen.dart';
import 'package:edara_hub_app/features/main_layout/main_layout.dart';
import 'package:flutter/material.dart';

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings settings) {
    switch (settings.name) {


      case Routes.mainRoute:
        return MaterialPageRoute(builder: (_) => const MainLayout());




      case Routes.signInRoute:
        return MaterialPageRoute(builder: (_) => const SignInScreen());

      case Routes.signUpRoute:
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text('No Route Found'),
        ),
        body: const Center(child: Text('No Route Found')),
      ),
    );
  }
}
