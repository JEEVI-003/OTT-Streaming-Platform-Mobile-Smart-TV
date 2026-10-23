import 'package:flutter/material.dart';
import 'package:ott_project/components/forget_password/forget_password_email.dart';
import 'package:ott_project/pages/Sign_up.dart';
import 'package:ott_project/pages/login_page.dart';
import 'package:ott_project/splashscreen.dart';

/// MyApp — NO MultiProvider here (already set up in main.dart AppRoot)
/// NO SplashScreen class here (lives in splashscreen.dart)
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Media Jungle',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // FIX: Removed GoogleFonts.sourceSans3TextTheme() — causes
        // "Unable to load asset: AssetManifest.json" on web/offline.
        // Using system sans-serif font which is equivalent visually and
        // works fully offline without any asset manifest dependency.
        fontFamily: 'sans-serif',
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginPage(),
        'ForgetPassword': (context) => ForgetPasswordEmail(),
        'CreateNewAccount': (context) => const SignUp(),
      },
    );
  }
}
