import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/tv_ui/components/authprovider.dart';
import 'package:ott_project/tv_ui/login&signup/forgetpassword_tv.dart';
import 'package:ott_project/tv_ui/login&signup/login_tv.dart';
import 'package:ott_project/tv_ui/login&signup/signup_tv.dart';
import 'package:ott_project/tv_ui/components/mainpagetv.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MediaJungleApp());
}

class MediaJungleApp extends StatelessWidget {
  const MediaJungleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProviderTV(),
      child: Shortcuts(
        shortcuts: <ShortcutActivator, Intent>{
          const SingleActivator(LogicalKeyboardKey.enter): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.select): const ActivateIntent(),
          const SingleActivator(LogicalKeyboardKey.gameButtonA): const ActivateIntent(),
        },
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => null,
            ),
          },
          child: MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'Media Jungle',
            theme: ThemeData.dark().copyWith(
              scaffoldBackgroundColor: Colors.black,
            ),
            initialRoute: '/',
            routes: {
              '/': (_) => const TVMainPage(),
              '/login': (_) => const TVLoginPage(),
              '/CreateNewAccount': (_) => const TVSignUp(),
              '/ForgetPassword': (_) => TVForgetPassword(),
            },
          ),
        ),
      ),
    );
  }
}
