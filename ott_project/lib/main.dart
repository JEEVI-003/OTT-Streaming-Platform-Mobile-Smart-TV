import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:ott_project/components/forget_password/forget_password_email.dart';
import 'package:ott_project/components/music_folder/audio_provider.dart';
import 'package:ott_project/components/music_folder/recently_played.dart';
import 'package:ott_project/main_tv.dart';
import 'package:ott_project/pages/Sign_up.dart';
import 'package:ott_project/pages/login_page.dart';
import 'package:ott_project/service/authservice.dart';
import 'package:ott_project/service/playlist_service.dart';
import 'package:ott_project/splashscreen.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AppRoot());
}

class AppRoot extends StatelessWidget {
  const AppRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const StartupRouter();
  }
}

/// Detects platform and routes to TV UI or Mobile UI.
/// TV UI:     Web (Chrome/Edge), Windows, Linux, Fuchsia, Android TV / Fire TV
/// Mobile UI: Real Android phone / tablet
class StartupRouter extends StatelessWidget {
  const StartupRouter({super.key});

  Future<bool> _isTV() async {
    // Web (Chrome, Edge, localhost) → TV UI
    if (kIsWeb) return true;

    // Windows / Linux / Fuchsia desktop → TV UI
    if (Platform.isWindows || Platform.isLinux || Platform.isFuchsia) {
      return true;
    }

    // Android: distinguish TV/Fire TV from real phone
    if (Platform.isAndroid) {
      final info = await DeviceInfoPlugin().androidInfo;

      // Leanback feature = Android TV / Fire TV
      final features = info.systemFeatures;
      if (features != null &&
          features.contains('android.software.leanback')) {
        return true;
      }

      // Fallback string matching for devices that omit the leanback feature
      final model        = (info.model        ?? '').toLowerCase();
      final manufacturer = (info.manufacturer ?? '').toLowerCase();
      final brand        = (info.brand        ?? '').toLowerCase();
      final product      = (info.product      ?? '').toLowerCase();

      return model.contains('tv')       ||
             model.contains('fire')     ||
             model.contains('bravia')   ||
             product.contains('atv')    ||
             brand.contains('amlogic')  ||
             manufacturer.contains('amazon') ||
             manufacturer.contains('lge');
    }

    // iOS / macOS / anything else → Mobile UI
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _isTV(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              backgroundColor: Colors.black,
              body: Center(child: CircularProgressIndicator()),
            ),
          );
        }

        if (snapshot.data!) {
          // TV UI — standalone, uses its own providers and MaterialApp
          return const MediaJungleApp();
        }

        // Mobile UI — needs mobile providers
        // FIX: Replaced GoogleFonts.sourceSans3TextTheme() with a local
        // TextTheme to avoid AssetManifest.json errors and network font
        // loading failures. The app uses the system default sans-serif font
        // which renders correctly offline on all platforms.
        return MultiProvider(
          providers: [
            Provider<AuthService>(create: (_) => AuthService()),
            Provider<PlaylistService>(create: (_) => PlaylistService()),
            ChangeNotifierProvider(
              create: (ctx) => AudioProvider(
                Provider.of<PlaylistService>(ctx, listen: false),
              ),
            ),
            ChangeNotifierProvider(create: (_) => RecentlyPlayed()),
          ],
          child: MaterialApp(
            title: 'Media Jungle',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // FIX: Use system font instead of GoogleFonts to prevent
              // "Unable to load asset: AssetManifest.json" runtime errors.
              // GoogleFonts requires asset manifest for offline/web fallback.
              fontFamily: 'sans-serif',
              textTheme: const TextTheme(
                displayLarge: TextStyle(fontFamily: 'sans-serif'),
                displayMedium: TextStyle(fontFamily: 'sans-serif'),
                displaySmall: TextStyle(fontFamily: 'sans-serif'),
                headlineLarge: TextStyle(fontFamily: 'sans-serif'),
                headlineMedium: TextStyle(fontFamily: 'sans-serif'),
                headlineSmall: TextStyle(fontFamily: 'sans-serif'),
                titleLarge: TextStyle(fontFamily: 'sans-serif'),
                titleMedium: TextStyle(fontFamily: 'sans-serif'),
                titleSmall: TextStyle(fontFamily: 'sans-serif'),
                bodyLarge: TextStyle(fontFamily: 'sans-serif'),
                bodyMedium: TextStyle(fontFamily: 'sans-serif'),
                bodySmall: TextStyle(fontFamily: 'sans-serif'),
                labelLarge: TextStyle(fontFamily: 'sans-serif'),
                labelMedium: TextStyle(fontFamily: 'sans-serif'),
                labelSmall: TextStyle(fontFamily: 'sans-serif'),
              ),
              primarySwatch: Colors.blue,
              visualDensity: VisualDensity.adaptivePlatformDensity,
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
              useMaterial3: true,
            ),
            routes: {
              '/login':           (context) => const LoginPage(),
              'ForgetPassword':   (context) => ForgetPasswordEmail(),
              'CreateNewAccount': (context) => const SignUp(),
            },
            home: const SplashScreen(),
          ),
        );
      },
    );
  }
}




