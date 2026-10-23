import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:ott_project/components/background_image.dart';
import 'package:ott_project/components/forget_password/forget_password.dart';
import 'package:ott_project/components/myTextField.dart';
import 'package:ott_project/components/pallete.dart';
import 'package:http/http.dart' as http;
import 'package:ott_project/url.dart';

class VerificationCodePage extends StatefulWidget {
  final String email;
  const VerificationCodePage({required this.email, super.key});

  @override
  State<VerificationCodePage> createState() => _VerificationCodePageState();
}

class _VerificationCodePageState extends State<VerificationCodePage> {

  final TextEditingController codeController = TextEditingController();
  bool isLoading = false;
  bool visibleOTP = false;

  Future<void> verifyCode(String email,String code) async{
   
     setState(() {
      isLoading = true;
    });
    try{
      final response = await http.post(Uri.parse('$baseUrl/verify-code'),
      body: {'email':email, 'code': code},
      );
      if(response.statusCode == 200){
         ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Code verified')));
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ForgetPassword()));
      } else if (response.statusCode == 400 && response.body.contains('Invalid verification code')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid verification code. Please try again.')),
        );
      } else if (response.statusCode == 400 && response.body.contains('Verification code expired')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Verification code expired. Please resend code.')),
        );
      }else{
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while processing your request. Please try again later.')));
      }
    }catch(e){
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('An error occurred while processing your request. Please try again later.')));
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
                        height: size.height * 0.20,
                      ),
                      Container(
                        width: size.width * 0.9,
                        height: size.height * 0.09,
                        child: Text(
                            'Enter Verification Code',textAlign: TextAlign.center,
                            style: kBodyText),
                      ),
                      //SizedBox(height: 15),
                      MyTextField( 
                          controller: codeController,
                          icon: FontAwesomeIcons.lock,
                          hint: 'Enter OTP',
                          inputType: TextInputType.visiblePassword,
                          inputAction: TextInputAction.done,
                          suffixIcon: IconButton(onPressed: (){
                              setState(() {
                                visibleOTP = !visibleOTP;
                              });
                            },
                             icon: Icon(visibleOTP ? Icons.visibility :Icons.visibility_off,color: Colors.white,size: 20,)),
                          obscureText: !visibleOTP),
                      SizedBox(
                        height: MediaQuery.sizeOf(context).height * 0.01,
                      ),
                     
                      SizedBox(height: MediaQuery.sizeOf(context).height * 0.04),
                      Container(
                        height: size.height * 0.08,
                        width: size.width * 0.6,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: Colors.blueGrey.shade300),
                        child: TextButton(
                            onPressed: isLoading ? null
                             :() {
                              final code = codeController.text.trim();
                               if (code.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Please enter code.')),
                                  );
                                }else{
                                  verifyCode(widget.email, code).then((_){
                                    Future.delayed(Duration(seconds: 3),(){
                                      codeController.clear();
                                    });
                                  });
                                }
                            },
                           
                            child: isLoading ? CircularProgressIndicator(color: Colors.white,)
                            :
                            Text(
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