import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/login&signup/textfield_tv.dart';

class TVSignUp extends StatefulWidget {
  const TVSignUp({super.key});

  @override
  State<TVSignUp> createState() => _TVSignUpState();
}

class _TVSignUpState extends State<TVSignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController = TextEditingController();
  final TextEditingController mobilenumberController = TextEditingController();
  bool visiblePassword = false;
  bool confirmVisiblePassword = false;

  final Service service = Service();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FocusNode _usernameFocus = FocusNode(debugLabel: 'signupUsername');
  final FocusNode _emailFocus = FocusNode(debugLabel: 'signupEmail');
  final FocusNode _mobileFocus = FocusNode(debugLabel: 'signupMobile');
  final FocusNode _passwordFocus = FocusNode(debugLabel: 'signupPassword');
  final FocusNode _confirmPasswordFocus = FocusNode(debugLabel: 'signupConfirmPassword');
  final FocusNode _registerFocus = FocusNode(debugLabel: 'signupRegister');
  final FocusNode loginFocus = FocusNode(debugLabel: 'signupLoginLink');
  final FocusNode _passwordToggleFocus = FocusNode(debugLabel: 'signupPasswordToggle');
  final FocusNode _confirmPasswordToggleFocus = FocusNode(debugLabel: 'signupConfirmToggle');
  final FocusNode _keyListenerNode = FocusNode(debugLabel: 'signupKeyListener');

  bool _isRegistering = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _confirmPasswordFocus.addListener(_handleConfirmPasswordFocus);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_usernameFocus);
    });
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
    } else if (key == LogicalKeyboardKey.enter ||
               key == LogicalKeyboardKey.select ||
               key == LogicalKeyboardKey.gameButtonA) {
      _pressFocusedButton();
    }
  }

  void _focusNext() {
    if (_usernameFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_emailFocus);
    } else if (_emailFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_mobileFocus);
    } else if (_mobileFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (_passwordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordToggleFocus);
    } else if (_passwordToggleFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
    } else if (_confirmPasswordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordToggleFocus);
    } else if (_confirmPasswordToggleFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_registerFocus);
    } else if (_registerFocus.hasFocus) {
      FocusScope.of(context).requestFocus(loginFocus);
    }
  }

  void _focusPrevious() {
    if (loginFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_registerFocus);
    } else if (_registerFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordToggleFocus);
    } else if (_confirmPasswordToggleFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
    } else if (_confirmPasswordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordToggleFocus);
    } else if (_passwordToggleFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (_passwordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_mobileFocus);
    } else if (_mobileFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_emailFocus);
    } else if (_emailFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_usernameFocus);
    }
  }

  Future<void> _pressFocusedButton() async {
    if (_passwordToggleFocus.hasFocus) {
      setState(() => visiblePassword = !visiblePassword);
    } else if (_confirmPasswordToggleFocus.hasFocus) {
      setState(() => confirmVisiblePassword = !confirmVisiblePassword);
    } else if (_registerFocus.hasFocus) {
      if (_isRegistering) return;
      _isRegistering = true;
      await validateAndRegisterUser(context);
      _isRegistering = false;
    } else if (loginFocus.hasFocus) {
      Navigator.of(context).pop();
    }
  }

  void _handleConfirmPasswordFocus() {
    if (_confirmPasswordFocus.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _confirmPasswordFocus.removeListener(_handleConfirmPasswordFocus);
    _scrollController.dispose();
    _usernameFocus.dispose();
    _emailFocus.dispose();
    _mobileFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _registerFocus.dispose();
    loginFocus.dispose();
    _passwordToggleFocus.dispose();
    _confirmPasswordToggleFocus.dispose();
    _keyListenerNode.dispose();
    usernameController.dispose();
    emailController.dispose();
    mobilenumberController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF070708), Color(0xFF1D1B53)],
          ),
        ),
        child: Center(
          child: Container(
            color: Colors.grey[900],
            width: MediaQuery.of(context).size.width * 0.5,
            padding: const EdgeInsets.all(20),
            child: KeyboardListener(
              focusNode: _keyListenerNode,
              onKeyEvent: _handleKeyEvent,
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Sign Up',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 30),
                      const Stack(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0x4DEEEEFF),
                            child: Icon(Icons.person_rounded, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      MyTextFieldTV(
                        controller: usernameController,
                        icon: FontAwesomeIcons.user,
                        hint: 'User Name',
                        inputType: TextInputType.name,
                        inputAction: TextInputAction.next,
                        obscureText: false,
                        focusNode: _usernameFocus,
                        nextFocusNode: _emailFocus,
                        focusColor: Colors.white,
                      ),
                      MyTextFieldTV(
                        controller: emailController,
                        icon: FontAwesomeIcons.envelope,
                        hint: 'Email',
                        inputType: TextInputType.emailAddress,
                        inputAction: TextInputAction.next,
                        obscureText: false,
                        focusNode: _emailFocus,
                        nextFocusNode: _mobileFocus,
                        focusColor: Colors.white,
                      ),
                      MyTextFieldTV(
                        controller: mobilenumberController,
                        icon: FontAwesomeIcons.phone,
                        hint: 'Mobile Number',
                        inputType: TextInputType.number,
                        inputAction: TextInputAction.next,
                        obscureText: false,
                        focusNode: _mobileFocus,
                        nextFocusNode: _passwordFocus,
                        focusColor: Colors.white,
                      ),
                      MyTextFieldTV(
                        controller: passwordController,
                        icon: FontAwesomeIcons.lock,
                        hint: 'Password',
                        inputType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          focusNode: _passwordToggleFocus,
                          onPressed: () => setState(() => visiblePassword = !visiblePassword),
                          icon: Icon(visiblePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white),
                        ),
                        inputAction: TextInputAction.next,
                        obscureText: !visiblePassword,
                        focusNode: _passwordFocus,
                        nextFocusNode: _confirmPasswordFocus,
                        focusColor: Colors.white,
                      ),
                      MyTextFieldTV(
                        controller: confirmpasswordController,
                        icon: FontAwesomeIcons.lock,
                        hint: 'Confirm Password',
                        inputType: TextInputType.visiblePassword,
                        suffixIcon: IconButton(
                          focusNode: _confirmPasswordToggleFocus,
                          onPressed: () =>
                              setState(() => confirmVisiblePassword = !confirmVisiblePassword),
                          icon: Icon(
                              confirmVisiblePassword ? Icons.visibility : Icons.visibility_off,
                              color: Colors.white),
                        ),
                        inputAction: TextInputAction.done,
                        obscureText: !confirmVisiblePassword,
                        focusNode: _confirmPasswordFocus,
                        nextFocusNode: _registerFocus,
                        focusColor: Colors.white,
                      ),
                      const SizedBox(height: 10),
                      Focus(
                        focusNode: _registerFocus,
                        onFocusChange: (_) => setState(() {}),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2B2A52),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                color: _registerFocus.hasFocus
                                    ? const Color(0xFF7873FF)
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                          ),
                          onPressed: () async {
                            if (_isRegistering) return;
                            _isRegistering = true;
                            await validateAndRegisterUser(context);
                            _isRegistering = false;
                          },
                          child: const Text('Register', style: TextStyle(fontSize: 18, color: Colors.white)),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Focus(
                        focusNode: loginFocus,
                        onFocusChange: (_) => setState(() {}),
                        child: TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          style: TextButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5),
                              side: BorderSide(
                                color: loginFocus.hasFocus
                                    ? const Color(0xFF7873FF)
                                    : Colors.transparent,
                                width: 2.0,
                              ),
                            ),
                          ),
                          child: const Text(
                            'Already Have an account? Login Here!',
                            style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> validateAndRegisterUser(BuildContext context) async {
    if (usernameController.text.isEmpty ||
        emailController.text.isEmpty ||
        mobilenumberController.text.isEmpty ||
        passwordController.text.isEmpty ||
        confirmpasswordController.text.isEmpty) {
      _showValidationDialog('All fields are required.');
      return;
    }
    if (!_isValidEmail(emailController.text)) {
      _showValidationDialog('Please enter a valid email.');
      return;
    }
    if (passwordController.text != confirmpasswordController.text) {
      _showValidationDialog('Passwords do not match.');
      return;
    }

    try {
      final isRegistered = await service.createUserTV(
        context,
        usernameController.text,
        emailController.text,
        mobilenumberController.text,
        passwordController.text,
        confirmpasswordController.text,
      );
      if (isRegistered && mounted) {
        _clearInputFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            duration: Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) _showValidationDialog('Registration failed. Please try again.');
    }
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void _showValidationDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        content: Text(message, style: const TextStyle(color: Colors.black, fontSize: 18)),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              FocusScope.of(context).requestFocus(_usernameFocus);
            },
            child: const Text('OK', style: TextStyle(color: Colors.black, fontSize: 18)),
          ),
        ],
      ),
    );
  }

  void _clearInputFields() {
    usernameController.clear();
    emailController.clear();
    mobilenumberController.clear();
    passwordController.clear();
    confirmpasswordController.clear();
  }
}
