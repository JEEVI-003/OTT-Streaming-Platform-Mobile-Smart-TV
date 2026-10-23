import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/myTextField.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/pages/login_page.dart';
import 'package:ott_project/url.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgetPassword extends StatefulWidget {
  ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
 

  final TextEditingController passwordController = TextEditingController();

  final TextEditingController confirmPasswordController =
      TextEditingController();
  String? savedEmail;

  bool visiblePassword = false;

   bool confirmVisiblePassword = false;

 void initState(){
  visiblePassword = false;
  confirmVisiblePassword = false;
  _loadSavedEmail();
 }

 Future<void> _loadSavedEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedEmail = prefs.getString('savedEmail');
    });
  }

  Future<void> resetPassword(BuildContext context) async {
   
    final String password = passwordController.text;
    final String confirmpassword = confirmPasswordController.text;

    if (password != confirmpassword) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content:
              Text('Passwords do not match. Please enter the same password.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }
    final response = await http.post(
      Uri.parse(
         "$baseUrl/forgetPassword"),
        //  'http://192.168.0.19:8010/api/v2/forgetPassword'),
        //"http://192.168.40.165:8080/api/v2/forgetPassword"),
      headers: <String, String>{'Content-Type': 'application/json'},
      body: jsonEncode(<String, String>{
        'email': savedEmail!,
        'password': password,
        'confirmPassword': confirmpassword,
      }),
    );
    print('Response code: ${response.statusCode}');
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Password reset successfully')),
      );
      Future.delayed(Duration(seconds: 5),(){
        Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context)=> LoginPage()), (route)=> false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reset password: ${response.body}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Stack(
      children: [
        BackgroundImage(),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: kWhite,
              ),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: Column(
                    children: [
                      SizedBox(
                        height: size.height * 0.03,
                      ),
                      Text('Forget Password', style: kBodyText),
                      SizedBox(
                        height: size.height * 0.07,
                      ),
                      Container(
                        width: size.width * 0.9,
                        height: size.height * 0.09,
                        child: Text(
                            'Enter New password to reset your password',
                            style: kBodyText),
                      ),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.01,
                      ),
                      MyTextField(
                          controller: passwordController,
                          icon: FontAwesomeIcons.lock,
                          hint: 'New Password',
                          inputType: TextInputType.visiblePassword,
                         suffixIcon: IconButton(onPressed: (){
                              setState(() {
                                visiblePassword = !visiblePassword;
                              });
                            },
                             icon: Icon(visiblePassword ? Icons.visibility :Icons.visibility_off,color: Colors.white,size: 20,)),
                          inputAction: TextInputAction.next,
                          obscureText: !visiblePassword),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.01,
                      ),
                      MyTextField(
                          controller: confirmPasswordController,
                          icon: FontAwesomeIcons.lock,
                          hint: 'Confirm Password',
                          inputType: TextInputType.visiblePassword,
                          suffixIcon: IconButton(onPressed: (){
                              setState(() {
                                confirmVisiblePassword = !confirmVisiblePassword;
                              });
                            },
                             icon: Icon(confirmVisiblePassword ? Icons.visibility :Icons.visibility_off,color: Colors.white,size: 20,)),
                          inputAction: TextInputAction.next,
                          obscureText: !confirmVisiblePassword),
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                      Container(
                        height: size.height * 0.08,
                        width: size.width * 0.6,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.blueGrey.shade300),
                        child: TextButton(
                            onPressed: () {
                              resetPassword(context);
                             setState(() {
                              
                               passwordController.clear();
                               confirmPasswordController.clear();
                             });
                            },
                            child: Text(
                              'Submit',
                              style: kBodyText.copyWith(
                                  fontWeight: FontWeight.bold),
                            )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
