// import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:tacab_ai/features/home/models/market_product.dart';
import 'package:tacab_ai/routes/app_routes.dart';
import '../features/authentication/screens/login_screen.dart';
import '../features/authentication/screens/signup_screen.dart';
import '../features/authentication/screens/signup_phone_screen.dart';
import '../features/home/screens/home_screen.dart';
import '../features/home/screens/BlogScreen.dart';
import '../features/home/screens/profile_screen.dart';
import '../features/home/screens/SettingScreen.dart';
import '../features/home/screens/chat_ai_screen.dart';
import '../features/home/screens/AboutUsScreen.dart';
import '../features/home/screens/market_detail_screen.dart';
// import '../features/home/screens/MarketDetailScreenInner.dart';

// import '../features/voice_query/screens/voice_chat_screen.dart';
// import '../features/weather/screens/weather_screen.dart';
import '../features/splash/screens/splash_screen.dart';

// class AppPages {
//   static const initial = "/splash"; // Start at login screen

//   static final routes = [
//     GetPage(name: '/splash', page: () => SplashScreen()),
//     GetPage(name: '/login', page: () => LoginScreen()),
//     // GetPage(name: AppRoutes.HOME, page: () => HomeScreen()),
//     // GetPage(name: AppRoutes.VOICE_CHAT, page: () => VoiceChatScreen()),
//     // GetPage(name: AppRoutes.WEATHER, page: () => WeatherScreen()),
//   ];
// }

class AppPages {
  static const initial = AppRoutes.SPLASH; // Start at login screen

  static final routes = [
    GetPage(name: AppRoutes.SPLASH, page: () => SplashScreen()),
    GetPage(name: AppRoutes.LOGIN, page: () => LoginScreen()),
    GetPage(name: AppRoutes.HOME, page: () => HomeScreen()),
    GetPage(name: AppRoutes.SIGNUP, page: () => SignupScreen()),
    GetPage(name: AppRoutes.SIGNUPPHONE, page: () => SignupPhoneScreen()),
    GetPage(
      name: '/marketdetail',
      page: () => const MarketDetailScreen(),
    ),
    GetPage(name: AppRoutes.BLOG, page: () => BlogScreen()),
    GetPage(name: AppRoutes.PROFILE, page: () => ProfileScreen()),
    GetPage(name: AppRoutes.SETTINGS, page: () => SettingScreen()),
    GetPage(name: AppRoutes.CHAT, page: () => ChatAIScreen()),
    GetPage(name: AppRoutes.ABOUT_US, page: () => AboutUsScreen()),

  ];
}
