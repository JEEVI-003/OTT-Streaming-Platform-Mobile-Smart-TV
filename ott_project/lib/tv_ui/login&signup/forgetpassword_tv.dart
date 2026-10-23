import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/tv_ui/FocusManager/focus_manager.dart';
import 'package:ott_project/tv_ui/login&signup/textfield_tv.dart';
import 'package:ott_project/url.dart';

class TVForgetPassword extends StatefulWidget {
  TVForgetPassword({super.key});

  @override
  State<TVForgetPassword> createState() => _TVForgetPasswordState();
}

class _TVForgetPasswordState extends State<TVForgetPassword> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  bool visiblePassword = false;
  bool confirmVisiblePassword = false;

  final FocusNode _emailFocus = FocusNode(debugLabel: 'fpEmail');
  final FocusNode _passwordFocus = FocusNode(debugLabel: 'fpPassword');
  final FocusNode _confirmPasswordFocus = FocusNode(debugLabel: 'fpConfirmPassword');
  final FocusNode _submitButtonFocus = FocusNode(debugLabel: 'fpSubmit');
  final FocusNode _keyListenerNode = FocusNode(debugLabel: 'fpKeyListener');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _emailFocus.requestFocus();
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
    if (_emailFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (_passwordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
    } else if (_confirmPasswordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_submitButtonFocus);
    }
  }

  void _focusPrevious() {
    if (_submitButtonFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_confirmPasswordFocus);
    } else if (_confirmPasswordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_passwordFocus);
    } else if (_passwordFocus.hasFocus) {
      FocusScope.of(context).requestFocus(_emailFocus);
    }
  }

  void _pressFocusedButton() {
    if (_submitButtonFocus.hasFocus) resetPassword(context);
  }

  Future<void> resetPassword(BuildContext context) async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showDialog('Please fill out all fields.');
      return;
    }

    if (password != confirmPassword) {
      _showDialog('Passwords do not match. Please enter the same password.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/forgetPassword'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password, 'confirmPassword': confirmPassword}),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password reset successfully')),
        );
        emailController.clear();
        passwordController.clear();
        confirmPasswordController.clear();
        FocusManagerService.setZone(TVFocusZone.sidebar);
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to reset password: ${response.body}')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Network error: $e')),
        );
      }
    }
  }

  void _showDialog(String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _emailFocus.requestFocus();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();
    _submitButtonFocus.dispose();
    _keyListenerNode.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: FocusScope(
        autofocus: true,
        child: KeyboardListener(
          focusNode: _keyListenerNode,
          onKeyEvent: _handleKeyEvent,
          child: Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    width: size.width * 0.6,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          SizedBox(height: size.height * 0.03),
                          const Text('Forget Password',
                              style: TextStyle(fontSize: 18, color: Colors.white, height: 1.5)),
                          SizedBox(height: size.height * 0.03),
                          SizedBox(
                            width: size.width * 0.9,
                            height: size.height * 0.06,
                            child: const Align(
                              alignment: Alignment.center,
                              child: Text(
                                'Enter your email and new password to reset your password',
                                style: TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
                              ),
                            ),
                          ),
                          SizedBox(height: size.height * 0.02),
                          MyTextFieldTV(
                            controller: emailController,
                            icon: FontAwesomeIcons.envelope,
                            hint: 'Email',
                            inputType: TextInputType.emailAddress,
                            inputAction: TextInputAction.next,
                            obscureText: false,
                            focusNode: _emailFocus,
                          ),
                          SizedBox(height: size.height * 0.02),
                          MyTextFieldTV(
                            controller: passwordController,
                            icon: FontAwesomeIcons.lock,
                            hint: 'New Password',
                            inputType: TextInputType.visiblePassword,
                            inputAction: TextInputAction.next,
                            obscureText: !visiblePassword,
                            focusNode: _passwordFocus,
                          ),
                          SizedBox(height: size.height * 0.02),
                          MyTextFieldTV(
                            controller: confirmPasswordController,
                            icon: FontAwesomeIcons.lock,
                            hint: 'Confirm Password',
                            inputType: TextInputType.visiblePassword,
                            inputAction: TextInputAction.done,
                            obscureText: !confirmVisiblePassword,
                            focusNode: _confirmPasswordFocus,
                          ),
                          SizedBox(height: size.height * 0.04),
                          Focus(
                            focusNode: _submitButtonFocus,
                            onFocusChange: (_) => setState(() {}),
                            child: AnimatedScale(
                              scale: _submitButtonFocus.hasFocus ? 1.05 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              child: Container(
                                height: size.height * 0.08,
                                width: size.width * 0.3,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  color: const Color(0xFF2B2A52),
                                  border: Border.all(
                                    color: _submitButtonFocus.hasFocus
                                        ? const Color(0xFF7873FF)
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                ),
                                child: TextButton(
                                  onPressed: () => resetPassword(context),
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(fontSize: 18, color: Colors.white, height: 1.5),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
