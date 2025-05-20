import 'auth.dart';
import 'package:flutter/material.dart';
import 'package:tacab_ai/features/home/screens/home_screen.dart';
import 'package:tacab_ai/features/splash/screens/splash_screen.dart';
import 'package:tacab_ai/features/authentication/screens/app_loading_page.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    this.pageIfNotConnected,
  });

  final Widget? pageIfNotConnected;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      // valueListenable: authService,
      valueListenable: authService,
      builder: (context, authService, child) {
        return StreamBuilder(
          stream: authService.authStateChanges,
          builder: (context, snapshot) {
            Widget widget;
            if (snapshot.connectionState == ConnectionState.waiting) {
              widget = const AppLoadingPage();
            } else if (snapshot.hasData) {
              widget = const HomeScreen();
            } else {
              widget = pageIfNotConnected ?? const SplashScreen();
            }
            return widget;
          },
        );
      },
    );
  }
}
