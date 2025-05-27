import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tacab_ai/routes/app_routes.dart';
import 'routes/app_pages.dart';
import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
   // Configure Firestore settings
  FirebaseFirestore.instance.settings = const Settings(
    host: 'firestore.googleapis.com',
    sslEnabled: true,
    persistenceEnabled: true,
  );

  // Enable network explicitly and catch errors
  FirebaseFirestore.instance.enableNetwork().catchError((e) {
    print('Firestore enable network error: $e');
  });
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Tacab AI",
      theme: ThemeData.light(),
      initialRoute: AppRoutes.SPLASH,
      // initialRoute: AppRoutes.HOME,
      getPages: AppPages.routes,
    );
  }
}


// import 'package:flutter/material.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'package:get/get.dart';
// import 'package:tacab_ai/features/home/screens/chat_ai_screen.dart';
// import 'firebase_options.dart';  // <-- Import generated file

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,  // <-- Use options here
//   );
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Tacab AI Chat",
//       theme: ThemeData.light(),
//       home: const ChatAIScreen(),
//     );
//   }
// }
