import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_agrinova/src/Language/app_localization.dart';
import 'package:project_agrinova/src/screens/Authentication/splash_screen.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  // Initialize Firebase
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyA6yQJ9JPOU35xRYtvY-LVsQjzEKjy3MWc",
        authDomain: "agrinova-7550f.firebaseapp.com",
        projectId: "agrinova-7550f",
        storageBucket: "agrinova-7550f.appspot.com",
        messagingSenderId: "462931104473",
        appId: "1:462931104473:web:c91ed6a04ea164ed34e4c8",
        measurementId: "G-8R9VVRVKES",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: Platform.isAndroid
          ? FirebaseOptions(
              apiKey: "AIzaSyD_FWhoc6BggXNkPWUFPJ5qmdIj8KuZCGk",
              appId: "1:462931104473:android:8f51cfbe2f666ec634e4c8",
              messagingSenderId: "462931104473",
              projectId: "agrinova-7550f",
              storageBucket:
                  "agrinova-7550f.appspot.com", // Ensure this is added
            )
          : FirebaseOptions(
              apiKey:
                  "AIzaSyDQ3NbI3jVdhlOueTPFY0ecmIpr8s5JWXs", // Replace with your iOS API key
              appId:
                  "1:462931104473:ios:1ba6037227a1bedd34e4c8", // Replace with your iOS app ID
              messagingSenderId: "462931104473",
              projectId: "agrinova-7550f",
              storageBucket:
                  "agrinova-7550f.appspot.com", // Ensure this is added
            ),
    );
  }

  LocalizationService localizationService = LocalizationService();
  await localizationService.loadLanguage();

  runApp(
    ChangeNotifierProvider(
      create: (_) => localizationService,
      child: MyApp(),
    ),
  );
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky,
  //     overlays: [SystemUiOverlay.bottom]);
  // SystemChrome.setSystemUIOverlayStyle(
  //     SystemUiOverlayStyle(statusBarColor: Color(0xff1ACD36)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationService>(
      builder: (context, localizationService, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          locale: context.watch<LocalizationService>().locale,
          home: SplashScreen(),
        );
      },
    );
  }
}
