import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/url.dart';
import 'package:ott_project/components/forget_password/verification_code_page.dart';
import 'package:ott_project/components/myTextField.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPasswordEmail extends StatefulWidget {
  const ForgetPasswordEmail({super.key});

  @override
  State<ForgetPasswordEmail> createState() => _ForgetPasswordEmailState();
}

class _ForgetPasswordEmailState extends State<ForgetPasswordEmail> {
  final TextEditingController emailController = TextEditingController();
  bool isLoading = false;

  Future<void> sendVerificationcode(String email) async {
    setState(() => isLoading = true);
    try {
      // ✅ FIXED: baseUrl already contains /api/v2, so just append /send-code
      final response = await http.post(
        Uri.parse('$baseUrl/send-code'),
        body: {'email': email},
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedEmail', email);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code sent successfully')),
        );
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => VerificationCodePage(email: email)),
        );
      } else if (response.statusCode == 400 &&
          response.body.contains('Invalid email')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Email not found. Please try again.')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text(
                  'An error occurred while processing your request. Please try again later.')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                'An error occurred while processing your request. Please try again later.')),
      );
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Stack(
      children: [
        const BackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const Text(
                      'Forgot Password',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 30),
                      child: Text(
                        'Enter your registered email address and we will send you a verification code.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ),
                    SizedBox(height: size.height * 0.04),
                    MyTextField(
                      controller: emailController,
                      hint: 'Enter Email',
                      obscureText: false,
                      icon: FontAwesomeIcons.envelope,
                      inputType: TextInputType.emailAddress,
                      inputAction: TextInputAction.done,
                    ),
                    SizedBox(height: size.height * 0.03),
                    Container(
                      height: size.height * 0.07,
                      width: size.width * 0.8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.blueGrey.shade300,
                      ),
                      child: TextButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                final email = emailController.text.trim();
                                if (email.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text('Please enter your email')),
                                  );
                                  return;
                                }
                                sendVerificationcode(email);
                              },
                        child: isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : Text(
                                'Send Code',
                                style: kBodyText.copyWith(
                                    fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}