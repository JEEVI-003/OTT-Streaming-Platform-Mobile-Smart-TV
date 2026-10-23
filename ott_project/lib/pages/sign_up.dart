import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/myTextField.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/pages/login_page.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/url.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();
  final TextEditingController mobilenumberController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool isLoading = false;
  bool isSendingOtp = false;
  bool isVerifyingOtp = false;
  bool visiblePassword = false;
  bool confirmVisiblePassword = false;
  bool isEmailVerified = false;
  File? _imageFile;
  final Service service = Service();

  @override
  void dispose() {
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmpasswordController.dispose();
    mobilenumberController.dispose();
    otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });
      }
    } catch (e) {
      debugPrint('Image pick error: $e');
    }
  }

  void _showDialog(String title, String message, {VoidCallback? onConfirm}) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: Text(title,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        content: Text(
          message,
          style: const TextStyle(color: Colors.black, fontSize: 15),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm?.call();
            },
            child: const Text('OK',
                style: TextStyle(color: Colors.black, fontSize: 16)),
          ),
        ],
      ),
    );
  }

  bool _validateEmail() {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      _showDialog('Validation Error', 'Email is required.');
      return false;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      _showDialog('Validation Error', 'Please enter a valid email address.');
      return false;
    }
    return true;
  }

  Future<void> _sendOtp() async {
    if (!_validateEmail()) return;

    setState(() => isSendingOtp = true);

    try {
      // ✅ FIXED: Removed duplicate '/api/v2' — baseUrl already contains it.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/send-code'),
      );
      request.fields['email'] = emailController.text.trim();

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        _showDialog('OTP Sent', response.body.isNotEmpty
            ? response.body
            : 'Verification code sent to your email.');
      } else if (response.statusCode == 409) {
        _showDialog(
          'Already Registered',
          response.body.isNotEmpty
              ? response.body
              : 'This email is already registered.',
          onConfirm: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (_) => const LoginPage()),
              (route) => false,
            );
          },
        );
      } else if (response.statusCode == 400) {
        _showDialog('Bad Request',
            response.body.isNotEmpty ? response.body : 'Failed to send OTP.');
      } else if (response.statusCode == 500) {
        _showDialog('Server Error',
            response.body.isNotEmpty ? response.body : 'Internal server error.');
      } else {
        _showDialog('Error',
            response.body.isNotEmpty ? response.body : 'An unexpected error occurred.');
      }
    } on SocketException {
      if (!mounted) return;
      _showDialog('Network Error',
          'Failed to connect to the server. Please check your connection.');
    } catch (e) {
      if (!mounted) return;
      _showDialog('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => isSendingOtp = false);
    }
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();
    if (otp.isEmpty) {
      _showDialog('Validation Error', 'Please enter the OTP code.');
      return;
    }

    setState(() => isVerifyingOtp = true);

    try {
      // ✅ FIXED: Removed duplicate '/api/v2' — baseUrl already contains it.
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/verify-code'),
      );
      request.fields['email'] = emailController.text.trim();
      request.fields['code'] = otp;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() => isEmailVerified = true);
        _showDialog('Verified', 'Email verified successfully!');
      } else if (response.statusCode == 400) {
        String message = 'Invalid or expired OTP.';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {
          if (response.body.isNotEmpty) message = response.body;
        }
        _showDialog('Verification Failed', message);
      } else if (response.statusCode == 500) {
        String message = 'An internal server error occurred.';
        try {
          final body = jsonDecode(response.body);
          message = body['message'] ?? message;
        } catch (_) {
          if (response.body.isNotEmpty) message = response.body;
        }
        _showDialog('Server Error', message);
      } else {
        _showDialog('Error', 'An unexpected error occurred. Please try again.');
      }
    } on SocketException {
      if (!mounted) return;
      _showDialog('Network Error', 'Failed to connect. Please check your connection.');
    } catch (e) {
      if (!mounted) return;
      _showDialog('Error', 'An unexpected error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => isVerifyingOtp = false);
    }
  }

  Future<bool> _registerUser() async {
    return await service.createUser(
      context,
      usernameController.text.trim(),
      emailController.text.trim(),
      mobilenumberController.text.trim(),
      passwordController.text,
      confirmpasswordController.text,
      _imageFile,
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!isEmailVerified) {
      _showDialog('Email Not Verified',
          'Please verify your email with the OTP before registering.');
      return;
    }

    if (passwordController.text != confirmpasswordController.text) {
      _showDialog('Validation Error', 'Passwords do not match.');
      return;
    }

    setState(() => isLoading = true);

    try {
      final success = await _registerUser();

      if (!mounted) return;

      if (success) {
        usernameController.clear();
        emailController.clear();
        mobilenumberController.clear();
        passwordController.clear();
        confirmpasswordController.clear();
        otpController.clear();
        setState(() => _imageFile = null);

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            backgroundColor: Colors.white,
            content: const Text(
              'Registration successful! Please login.',
              style: TextStyle(color: Colors.black, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginPage()),
                    (route) => false,
                  );
                },
                child: const Text('Login',
                    style: TextStyle(color: Colors.black, fontSize: 16)),
              ),
            ],
          ),
        );
      } else {
        _showDialog('Registration Failed',
            'Email may already be in use. Please try again.');
      }
    } catch (e) {
      if (!mounted) return;
      _showDialog('Error', 'An error occurred. Please try again.');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async => false,
      child: Stack(
        children: [
          const BackgroundImage(),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.10),

                    // Profile picture picker
                    Stack(
                      children: [
                        Center(
                          child: ClipOval(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                              child: CircleAvatar(
                                radius: size.width * 0.14,
                                backgroundColor:
                                    Colors.grey.shade200.withOpacity(0.3),
                                child: _imageFile == null
                                    ? Icon(FontAwesomeIcons.user,
                                        color: kWhite, size: size.width * 0.11)
                                    : CircleAvatar(
                                        radius: size.width * 0.13,
                                        backgroundImage: FileImage(_imageFile!),
                                      ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: size.height * 0.002,
                          left: size.width * 0.52,
                          child: IconButton(
                            onPressed: _pickImage,
                            icon: Icon(Icons.camera_alt, color: kWhite),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Username
                    MyTextField(
                      controller: usernameController,
                      icon: FontAwesomeIcons.user,
                      hint: 'User Name',
                      inputType: TextInputType.name,
                      inputAction: TextInputAction.next,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '  Please enter your name';
                        }
                        return null;
                      },
                    ),

                    // Email + Get OTP button
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, top: 8, bottom: 4, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: emailController,
                              enabled: !isEmailVerified,
                              decoration: InputDecoration(
                                hintText: 'Email',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.white54),
                                prefixIcon: const Icon(
                                    FontAwesomeIcons.envelope,
                                    color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: TextStyle(
                                  color: isEmailVerified
                                      ? Colors.white54
                                      : Colors.white),
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '  Please enter your email';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 56,
                            child: ElevatedButton(
                              onPressed: (isSendingOtp || isEmailVerified)
                                  ? null
                                  : _sendOtp,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey.shade300,
                                disabledBackgroundColor:
                                    Colors.blueGrey.shade700,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                              ),
                              child: isSendingOtp
                                  ? const SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                          color: Colors.white, strokeWidth: 2),
                                    )
                                  : Text(
                                      'Get OTP',
                                      style: kBodyText.copyWith(fontSize: 13),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // OTP input + Verify button
                    Padding(
                      padding: const EdgeInsets.only(
                          left: 20, top: 4, bottom: 8, right: 20),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: otpController,
                              enabled: !isEmailVerified,
                              decoration: InputDecoration(
                                hintText: 'Enter OTP code',
                                hintStyle: Theme.of(context)
                                    .textTheme
                                    .bodyLarge!
                                    .copyWith(color: Colors.white54),
                                prefixIcon: const Icon(FontAwesomeIcons.key,
                                    color: Colors.white),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: Colors.white.withOpacity(0.4)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.white),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide:
                                      const BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 8),
                          SizedBox(
                            height: 56,
                            child: isEmailVerified
                                ? Container(
                                    width: 70,
                                    decoration: BoxDecoration(
                                      color: Colors.green.shade600,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.check,
                                        color: Colors.white),
                                  )
                                : ElevatedButton(
                                    onPressed:
                                        (isVerifyingOtp || isEmailVerified)
                                            ? null
                                            : _verifyOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          Colors.blueGrey.shade300,
                                      disabledBackgroundColor:
                                          Colors.blueGrey.shade700,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                    ),
                                    child: isVerifyingOtp
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2),
                                          )
                                        : Text(
                                            'Verify',
                                            style:
                                                kBodyText.copyWith(fontSize: 13),
                                          ),
                                  ),
                          ),
                        ],
                      ),
                    ),

                    // Mobile number
                    MyTextField(
                      controller: mobilenumberController,
                      icon: FontAwesomeIcons.phone,
                      hint: 'Mobile Number',
                      inputType: TextInputType.number,
                      inputAction: TextInputAction.next,
                      obscureText: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '  Please enter mobile number';
                        }
                        if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                          return '  Please enter a valid 10-digit number';
                        }
                        return null;
                      },
                    ),

                    // Password
                    MyTextField(
                      controller: passwordController,
                      icon: FontAwesomeIcons.lock,
                      hint: 'Password',
                      inputType: TextInputType.visiblePassword,
                      inputAction: TextInputAction.next,
                      obscureText: !visiblePassword,
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => visiblePassword = !visiblePassword),
                        icon: Icon(
                          visiblePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '  Please enter password';
                        }
                        if (value.length < 6 || value.length > 15) {
                          return '  Password must be 6–15 characters';
                        }
                        if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                          return '  Must contain a special character';
                        }
                        return null;
                      },
                    ),

                    // Confirm Password
                    MyTextField(
                      controller: confirmpasswordController,
                      icon: FontAwesomeIcons.lock,
                      hint: 'Confirm Password',
                      inputType: TextInputType.visiblePassword,
                      inputAction: TextInputAction.done,
                      obscureText: !confirmVisiblePassword,
                      suffixIcon: IconButton(
                        onPressed: () => setState(() =>
                            confirmVisiblePassword = !confirmVisiblePassword),
                        icon: Icon(
                          confirmVisiblePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      confirmPasswordController: passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '  Please confirm your password';
                        }
                        if (value != passwordController.text) {
                          return '  Passwords do not match';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: size.height * 0.03),

                    // Register button — disabled until email is verified
                    Opacity(
                      opacity: isEmailVerified ? 1.0 : 0.5,
                      child: Container(
                        height: size.height * 0.07,
                        width: size.width * 0.6,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          color: Colors.blueGrey.shade300,
                        ),
                        child: TextButton(
                          onPressed:
                              (isLoading || !isEmailVerified) ? null : _handleRegister,
                          child: isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : Text(
                                  'Register',
                                  style: kBodyText.copyWith(
                                      fontWeight: FontWeight.bold),
                                ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    Divider(color: Colors.grey[400], thickness: 0.5),

                    SizedBox(height: size.height * 0.01),

                    Column(
                      children: [
                        Text('Already have an account?', style: kBodyText),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () => Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginPage()),
                            (route) => false,
                          ),
                          child: Text(
                            'Login Here!',
                            style: kBodyText.copyWith(
                                color: kBlue, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: size.height * 0.04),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}