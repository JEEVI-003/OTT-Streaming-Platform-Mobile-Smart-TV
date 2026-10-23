import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/myTextField.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/pages/main_tab.dart';
import 'package:ott_project/service/authservice.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ott_project/service/service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isChecked = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool visiblePassword = false;
  bool isLoading = false;

  final Service service = Service();

  @override
  void initState() {
    super.initState();
    visiblePassword = false;
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => true,
      child: Stack(
        children: [
          const BackgroundImage(),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Logo
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/icon/media_jungle.png',
                          fit: BoxFit.cover,
                          height: size.height * 0.20,
                          width: size.width * 0.50,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          'With our app, you\'ll have access to a vast library of movies, TV shows, documentaries and more, all at your fingertips',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: kWhite,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),

                      // Email field
                      MyTextField(
                        controller: emailController,
                        hint: 'Enter Email',
                        obscureText: false,
                        icon: FontAwesomeIcons.envelope,
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.next,
                      ),

                      // Password field
                      MyTextField(
                        controller: passwordController,
                        hint: 'Enter Password',
                        obscureText: !visiblePassword,
                        icon: FontAwesomeIcons.lock,
                        inputType: TextInputType.visiblePassword,
                        inputAction: TextInputAction.done,
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() => visiblePassword = !visiblePassword);
                          },
                          icon: Icon(
                            visiblePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),

                      // Remember me + Forgot password
                      Row(
                        children: [
                          Theme(
                            data: ThemeData(
                              unselectedWidgetColor: const Color(0xff00C8E8),
                            ),
                            child: Checkbox(
                              activeColor:
                                  const Color.fromARGB(255, 109, 110, 110),
                              value: _isChecked,
                              onChanged: (value) {
                                setState(() => _isChecked = value ?? false);
                              },
                            ),
                          ),
                          const Text(
                            'Remember me',
                            style: TextStyle(fontSize: 14, color: Colors.white),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                                context, 'ForgetPassword'),
                            child: const Padding(
                              padding: EdgeInsets.only(right: 16),
                              child: Text(
                                'Forgot Password?',
                                style:
                                    TextStyle(fontSize: 14, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: size.height * 0.02),

                      // Login button
                      Container(
                        height: size.height * 0.07,
                        width: size.width * 0.8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.blueGrey.shade300,
                        ),
                        child: TextButton(
                          onPressed: isLoading ? null : _handleLogin,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Login',
                                  style: kBodyText.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),

                      SizedBox(height: size.height * 0.02),

                      Divider(color: Colors.grey[400], thickness: 0.5),

                      SizedBox(height: size.height * 0.02),

                      // Sign up link
                      const Text(
                        'Not a Member?',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 6),
                      GestureDetector(
                        onTap: () => Navigator.pushReplacementNamed(
                            context, 'CreateNewAccount'),
                        child: Container(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom:
                                  BorderSide(width: 1, color: Colors.white),
                            ),
                          ),
                          child: Text('Create New Account', style: kBodyText),
                        ),
                      ),
                      SizedBox(height: size.height * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Login Failed', 'Email and password are required.');
      return;
    }

    setState(() => isLoading = true);

    try {
      // loginUser should return a Map with token, userId, username on success
      // or null on failure. Update Service.loginUser to return this map.
      final result = await service.loginUser(
        context,
        email,
        password,
        emailController,
        passwordController,
      );

      if (!mounted) return;

      if (result != null) {
        final authService = Provider.of<AuthService>(context, listen: false);

        // Extract real values from the login response.
        // Adjust the keys below to match what your backend actually returns.
        final token = result['token']?.toString() ?? '';
        final userId = result['userId']?.toString() ??
            result['id']?.toString() ??
            result['user_id']?.toString() ??
            '';
        final username = result['username']?.toString() ??
            result['name']?.toString() ??
            email;

        await authService.saveAuthData(
          token: token,
          userId: userId,
          username: username,
        );

        if (!mounted) return;

        if (_isChecked) {
          _saveCredentials(email, password);
        } else {
          _clearSavedCredentials();
        }

        emailController.clear();
        passwordController.clear();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => MainTab(initialTab: 0)),
        );
      } else {
        _showDialog(
            'Login Failed', 'Invalid email or password. Please try again.');
      }
    } on Exception catch (e) {
      if (!mounted) return;

      final msg = e.toString();
      if (msg.contains('SocketException') ||
          msg.contains('Connection timed out') ||
          msg.contains('No route to host')) {
        _showDialog(
          'Connection Error',
          'Cannot reach the server. Please make sure your phone and PC are on the same Wi-Fi network.',
        );
      } else {
        _showDialog('Error', 'Something went wrong. Please try again.');
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void _showDialog(String title, String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', true);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  Future<void> _clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('rememberMe');
    await prefs.remove('email');
    await prefs.remove('password');
  }

  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    if (rememberMe) {
      setState(() {
        _isChecked = true;
        emailController.text = prefs.getString('email') ?? '';
        passwordController.text = prefs.getString('password') ?? '';
      });
    }
  }
}