import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseFirestore.instance.settings = const Settings(
    sslEnabled: true,
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  runApp(const App());
}



// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:tacab_ai/routes/app_routes.dart';
// import 'routes/app_pages.dart';
// import 'package:firebase_core/firebase_core.dart';
// import 'firebase_options.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Firebase.initializeApp(
//     options: DefaultFirebaseOptions.currentPlatform,
//   );
//   // Configure Firestore settings
//   FirebaseFirestore.instance.settings = const Settings(
//     // host: 'firestore.googleapis.com',
//     sslEnabled: true,
//     persistenceEnabled: true,
//     cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
//   );

//   // Enable network explicitly and catch errors
//   FirebaseFirestore.instance.enableNetwork().catchError((e) {
//     print('Firestore enable network error: $e');
//   });
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return GetMaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: "Tacab AI",
//       theme: ThemeData.light(),
//       initialRoute: AppRoutes.SPLASH,
//       // initialRoute: AppRoutes.HOME,
//       getPages: AppPages.routes,
//     );
//   }
// }

