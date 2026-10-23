import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/service/icon_service.dart';
import 'package:ott_project/tv_ui/components/authprovider.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/login&signup/forgetpassword_tv.dart';
import 'package:ott_project/tv_ui/login&signup/signup_tv.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TVLoginPage extends StatefulWidget {
  static Function()? requestEmailFocus;
  final VoidCallback? onLoginSuccess;

  const TVLoginPage({Key? key, this.onLoginSuccess}) : super(key: key);

  @override
  State<TVLoginPage> createState() => _TVLoginPageState();
}

class _TVLoginPageState extends State<TVLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocus = FocusNode(debugLabel: 'loginEmail');
  final FocusNode passwordFocus = FocusNode(debugLabel: 'loginPassword');
  final FocusNode loginButtonFocus = FocusNode(debugLabel: 'loginButton');
  final FocusNode rememberMeFocus = FocusNode(debugLabel: 'rememberMe');
  final FocusNode forgotPasswordFocus = FocusNode(debugLabel: 'forgotPassword');
  final FocusNode signUpFocus = FocusNode(debugLabel: 'signUp');
  final FocusNode visibilityFocus = FocusNode(debugLabel: 'visibility');
  final FocusNode _keyListenerNode = FocusNode(debugLabel: 'loginKeyListener');

  bool visiblePassword = false;
  bool _isChecked = false;
  String? emailError;
  String? passwordError;
  Uint8List? cachedImageBytes;

  @override
  void initState() {
    super.initState();
    loadUserEmailPassword();
    _loadIcon();

    TVLoginPage.requestEmailFocus = () {
      if (mounted) {
        FocusManagerService.unfocusAll();
        Future.delayed(const Duration(milliseconds: 80), () {
          if (mounted) {
            _keyListenerNode.requestFocus();
            emailFocus.requestFocus();
          }
        });
      }
    };
  }

  Future<void> _loadIcon() async {
    if (cachedImageBytes != null) return;
    try {
      final icon = await IconService.fetchIcon();
      if (mounted) setState(() => cachedImageBytes = icon.imageBytes);
    } catch (e) {
      debugPrint('[Login] Icon load error: $e');
    }
  }

  void _handleKeyEvent(KeyEvent event) {
    if (event is! KeyDownEvent) return;

    final focused = FocusManager.instance.primaryFocus;
    if (focused?.context?.widget is EditableText) return;

    final key = event.logicalKey;

    if (key == LogicalKeyboardKey.arrowDown) {
      _focusNext();
    } else if (key == LogicalKeyboardKey.arrowUp) {
      _focusPrevious();
    } else if (key == LogicalKeyboardKey.arrowLeft) {
      _handleLeftArrowPress();
    } else if (key == LogicalKeyboardKey.arrowRight) {
      _focusRight();
    } else if (key == LogicalKeyboardKey.enter ||
               key == LogicalKeyboardKey.select ||
               key == LogicalKeyboardKey.gameButtonA) {
      _pressFocusedButton();
    }
  }

  void _handleLeftArrowPress() {
    if (visibilityFocus.hasFocus) {
      _focusOn(passwordFocus);
    } else if (forgotPasswordFocus.hasFocus) {
      _focusOn(rememberMeFocus);
    } else {
      _moveToSidebar();
    }
  }

  void _focusOn(FocusNode target) {
    _unfocusAllLoginNodes();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) FocusScope.of(context).requestFocus(target);
    });
  }

  void _moveToSidebar() {
    _unfocusAllLoginNodes();
    FocusManagerService.setZone(TVFocusZone.sidebar);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusManagerService.setSidebarFocus();
    });
  }

  void _unfocusAllLoginNodes() {
    emailFocus.unfocus();
    passwordFocus.unfocus();
    rememberMeFocus.unfocus();
    forgotPasswordFocus.unfocus();
    loginButtonFocus.unfocus();
    signUpFocus.unfocus();
    visibilityFocus.unfocus();
  }

  void _focusNext() {
    if (emailFocus.hasFocus) {
      _focusOn(passwordFocus);
    } else if (passwordFocus.hasFocus || visibilityFocus.hasFocus) {
      _focusOn(rememberMeFocus);
    } else if (rememberMeFocus.hasFocus || forgotPasswordFocus.hasFocus) {
      _focusOn(loginButtonFocus);
    } else if (loginButtonFocus.hasFocus) {
      _focusOn(signUpFocus);
    }
  }

  void _focusPrevious() {
    if (signUpFocus.hasFocus) {
      _focusOn(loginButtonFocus);
    } else if (loginButtonFocus.hasFocus) {
      _focusOn(rememberMeFocus);
    } else if (rememberMeFocus.hasFocus) {
      _focusOn(passwordFocus);
    } else if (passwordFocus.hasFocus) {
      _focusOn(emailFocus);
    }
  }

  void _focusRight() {
    if (passwordFocus.hasFocus) {
      _focusOn(visibilityFocus);
    } else if (rememberMeFocus.hasFocus) {
      _focusOn(forgotPasswordFocus);
    }
  }

  void _pressFocusedButton() {
    if (loginButtonFocus.hasFocus) {
      handleLogin(context);
    } else if (forgotPasswordFocus.hasFocus) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => TVForgetPassword()))
          .then((_) {
        if (mounted) FocusScope.of(context).requestFocus(emailFocus);
      });
    } else if (signUpFocus.hasFocus) {
      Navigator.of(context)
          .push(MaterialPageRoute(builder: (_) => const TVSignUp()))
          .then((_) {
        if (mounted) FocusScope.of(context).requestFocus(emailFocus);
      });
    } else if (rememberMeFocus.hasFocus) {
      setState(() => _isChecked = !_isChecked);
    }
  }

  Future<void> handleLogin(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showDialog('Login Failed', 'Email and password are required.');
      return;
    }

    final authProvider = Provider.of<AuthProviderTV>(context, listen: false);
    debugPrint('[Login] Attempting login: $email');
    final success = await authProvider.login(context, email, password);
    debugPrint('[Login] Result: $success');

    if (!mounted) return;

    if (success) {
      if (_isChecked) saveUserCredentials(email, password);
      emailController.clear();
      passwordController.clear();
      FocusManagerService.setZone(TVFocusZone.sidebar);
      widget.onLoginSuccess?.call();
    } else {
      _showDialog('Login Failed', 'Invalid email or password.');
    }
  }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kWhite,
        title: Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black)),
        content: Text(content, style: const TextStyle(color: Colors.black, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.black, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void saveUserCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('rememberMe', true);
    await prefs.setString('email', email);
    await prefs.setString('password', password);
  }

  void loadUserEmailPassword() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool('rememberMe') ?? false;
    final email = prefs.getString('email') ?? '';
    final password = prefs.getString('password') ?? '';
    if (mounted) {
      setState(() {
        _isChecked = rememberMe;
        emailController.text = email;
        passwordController.text = password;
      });
    }
  }

  @override
  void dispose() {
    emailFocus.dispose();
    passwordFocus.dispose();
    loginButtonFocus.dispose();
    rememberMeFocus.dispose();
    forgotPasswordFocus.dispose();
    signUpFocus.dispose();
    visibilityFocus.dispose();
    _keyListenerNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    TVLoginPage.requestEmailFocus = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: KeyboardListener(
        focusNode: _keyListenerNode,
        onKeyEvent: _handleKeyEvent,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF070708), Color(0xFF1D1B53)],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    const BackgroundImage(),
                    Expanded(
                      flex: 6,
                      child: Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text('Sign In',
                                style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white)),
                            const SizedBox(height: 20),
                            _buildTextField('Email or Mobile Number', emailController, emailFocus, passwordFocus, emailError),
                            const SizedBox(height: 20),
                            _buildTextField('Enter Password', passwordController, passwordFocus, rememberMeFocus, passwordError, isPassword: true),
                            const SizedBox(height: 20),
                            _buildRememberMeAndForgotPasswordRow(),
                            const SizedBox(height: 20),
                            _buildLoginButton(),
                            const SizedBox(height: 20),
                            _buildSignUpButton(),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    _buildSidebar(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller, FocusNode currentFocus,
      FocusNode nextFocus, String? errorText, {bool isPassword = false}) {
    return TextFormField(
      controller: controller,
      focusNode: currentFocus,
      style: const TextStyle(color: Colors.white),
      obscureText: isPassword ? !visiblePassword : false,
      keyboardType: isPassword ? TextInputType.visiblePassword : TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        errorText: errorText,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        suffixIcon: isPassword
            ? IconButton(
                focusNode: visibilityFocus,
                icon: Icon(visiblePassword ? Icons.visibility : Icons.visibility_off, color: Colors.white),
                onPressed: () => setState(() => visiblePassword = !visiblePassword),
              )
            : null,
      ),
    );
  }

  Widget _buildRememberMeAndForgotPasswordRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Focus(
          focusNode: rememberMeFocus,
          onFocusChange: (_) => setState(() {}),
          child: AnimatedScale(
            scale: rememberMeFocus.hasFocus ? 1.125 : 1.0,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: Checkbox(
              value: _isChecked,
              side: rememberMeFocus.hasFocus
                  ? const BorderSide(color: Color(0xFF7873FF), width: 2)
                  : const BorderSide(color: Colors.grey),
              onChanged: (value) => setState(() => _isChecked = value ?? false),
            ),
          ),
        ),
        const Text('Remember Me', style: TextStyle(color: Colors.white, fontSize: 12)),
        AnimatedScale(
          scale: forgotPasswordFocus.hasFocus ? 1.125 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: TextButton(
            focusNode: forgotPasswordFocus,
            onPressed: () {
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => TVForgetPassword()))
                  .then((_) {
                if (mounted) FocusScope.of(context).requestFocus(emailFocus);
              });
            },
            child: Text(
              'Forgot Password?',
              style: TextStyle(
                color: forgotPasswordFocus.hasFocus ? const Color(0xFF7873FF) : Colors.white,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return Focus(
      focusNode: loginButtonFocus,
      onFocusChange: (_) => setState(() {}),
      child: AnimatedScale(
        scale: loginButtonFocus.hasFocus ? 1.125 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        child: ElevatedButton(
          onPressed: () => handleLogin(context),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2B2A52),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
              side: BorderSide(
                color: loginButtonFocus.hasFocus ? const Color(0xFF7873FF) : Colors.transparent,
                width: 2.0,
              ),
            ),
          ),
          child: const Text('Log In', style: TextStyle(fontSize: 18)),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ", style: TextStyle(color: Colors.white, fontSize: 12)),
        AnimatedScale(
          scale: signUpFocus.hasFocus ? 1.125 : 1.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              border: Border.all(
                color: signUpFocus.hasFocus ? const Color(0xFF7873FF) : Colors.transparent,
                width: 2.0,
              ),
            ),
            child: TextButton(
              focusNode: signUpFocus,
              onPressed: () {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (_) => const TVSignUp()))
                    .then((_) {
                  if (mounted) FocusScope.of(context).requestFocus(emailFocus);
                });
              },
              child: const Text('Sign Up', style: TextStyle(color: Colors.white, fontSize: 12)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Expanded(
      flex: 5,
      child: Center(
        child: FittedBox(
          fit: BoxFit.contain,
          child: SizedBox(
            width: 300,
            height: 300,
            child: cachedImageBytes != null
                ? Image.memory(cachedImageBytes!)
                : Image.asset('assets/icon/media_jungle.png'),
          ),
        ),
      ),
    );
  }
}
