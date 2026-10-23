import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

import 'package:ott_project/plan_and_payment/subscription_page.dart';
import 'package:ott_project/profile/change_password_page.dart';
import 'package:ott_project/pages/login_page.dart';
import 'package:ott_project/profile/view_profile_page.dart';
import 'package:ott_project/service/authservice.dart';
import 'package:ott_project/service/service.dart';
import 'package:ott_project/url.dart';
import 'package:provider/provider.dart';
import '../components/background_image.dart';
import '../components/pallete.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  // Map<String, dynamic>? userData;
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobilenumberController = TextEditingController();
 // String base64Image = '';
  Uint8List? profile;
   Uint8List? profileImageBytes;
  final Service service = Service();
  @override
  void initState() {
    super.initState();
    fetchUserProfile(context);
  }
Future<void> fetchUserProfile(BuildContext context) async {
  final authService = Provider.of<AuthService>(context, listen: false);

  String? token = await authService.getToken();
  String? userId = await authService.getUserId();

  try {
    var response = await http.get(
      Uri.parse('$baseUrl/GetUserById/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var userData = jsonDecode(response.body);

      Uint8List? updatedImage = await service.fetchProfileImage();

      setState(() {
        usernameController.text = userData['username'] ?? '';
        emailController.text = userData['email'] ?? '';
        mobilenumberController.text = userData['mobnum'] ?? '';
        profileImageBytes = updatedImage;
      });
    } else {
      print('Failed to fetch user profile');
    }
  } catch (e) {
    print('Error fetching user profile: $e');
  }
}


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async{
        return false;
      },
      child: Stack(
        children: [
          BackgroundImage(),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              // leading: IconButton(
              //     onPressed: () {
              //       Navigator.pop(context);
              //     },
              //     icon: Icon(
              //       Icons.arrow_back_rounded,
              //       color: kWhite,
              //     )),
              backgroundColor: Colors.transparent,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    GestureDetector(
                      //onTap: _pickProfilePicture,
                      child: CircleAvatar(
                        backgroundColor: const Color.fromARGB(255, 51, 49, 49),
                        radius: 50,
                        backgroundImage: 
                         profileImageBytes!= null ? MemoryImage(profileImageBytes!) : null,
                            // : null,
                        // child: base64Image.isEmpty
                        //     ? Icon(
                        //         Icons.person,
                        //         size: 50,
                        //         color: Colors.white,
                        //       )
                        //     : null,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    Text(
                      usernameController.text,
                      style: TextStyle(color: kWhite),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.04,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.subscriptions_rounded,
                        color: Colors.white70,
                      ),
                      title: Text(
                        'Subscription Plan',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SubscriptionPage()));
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.password_rounded,
                        color: Colors.white70,
                      ),
                      title: Text(
                        'Change Password',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => ChangePasswordPage()));
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    ListTile(
                      leading: Icon(
                        Icons.edit_document,
                        color: Colors.white70,
                      ),
                      title: Text(
                        'Profile',
                        style: TextStyle(color: kWhite),
                      ),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ViewProfilePage(onProfileUpdated: () {
                                      fetchUserProfile(context);
                                    })));
                      },
                    ),
                    SizedBox(height: MediaQuery.sizeOf(context).height * 0.09),
      
                    // const SizedBox(height: 16.0),
                    SizedBox(
                      //width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _handleLogout(context);
                        },
                        style: ElevatedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                          padding: EdgeInsets.symmetric(
                              horizontal:
                                  MediaQuery.sizeOf(context).height * 0.07,
                              vertical: 15),
                          backgroundColor: Color.fromARGB(174, 93, 104, 195),
                          foregroundColor: kWhite,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.logout_outlined,
                              size: 20,
                              color: kWhite,
                            ),
                             SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.02,
                            ),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.sizeOf(context).height * 0.02,
                    ),
                    // SizedBox(
                    //   // width: double.infinity,
                    //   child: ElevatedButton(
                    //     onPressed: () {
                    //       showDialog(
                    //         context: context,
                    //         builder: (BuildContext context) {
                    //           return AlertDialog(
                    //             title: Text('Account Deletion!!'),
                    //             content: Text(
                    //                 'Are you sure want to delete your account?'),
                    //             actions: [
                    //               TextButton(
                    //                   onPressed: () => Navigator.pop(context),
                    //                   child: Text('Cancel')),
                    //               TextButton(
                    //                   onPressed: () {
                    //                     _handleLogout(context);
                    //                   },
                    //                   child: Text('Ok'))
                    //             ],
                    //           );
                    //         },
                    //       );
                    //     },
                    //     style: ElevatedButton.styleFrom(
                    //       shape: RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(14)),
                    //       padding: EdgeInsets.symmetric(
                    //           horizontal:
                    //               MediaQuery.sizeOf(context).height * 0.04,
                    //           vertical: 15),
                    //       backgroundColor: Color.fromARGB(174, 93, 104, 195),
                    //       foregroundColor: kWhite,
                    //     ),
                    //     child: Row(
                    //       mainAxisSize: MainAxisSize.min,
                    //       mainAxisAlignment: MainAxisAlignment.center,
                    //       children: [
                    //         Icon(
                    //           Icons.delete_sweep_rounded,
                    //           size: 20,
                    //           color: kWhite,
                    //         ),
                    //         const SizedBox(
                    //           width: 8,
                    //         ),
                    //         Text('Delete Account'),
                    //       ],
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // void _handleLogout(BuildContext context) async {

  //   showDialog(context: context, builder: (BuildContext context){
  //       return AlertDialog(
  //         backgroundColor: Colors.white,
  //         title: Text('Are you sure you want to logout?',style: TextStyle(fontSize: 16,color: Colors.black),),
  //         actions: [
  //           TextButton(onPressed: (){
  //             Navigator.pop(context);
  //           }, child: Text('Cancel',style: TextStyle(color:Colors.black),)),

  //           TextButton(onPressed: () async {
  //             bool success = await service.logoutUser(context);
  //   if (success) {
  // final authService = Provider.of<AuthService>(context, listen: false);
  //    await authService.logout();
  //     // Navigate to the login screen upon successful logout
  //           Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => LoginPage()),
  //         (route) => false,
  //       );
  //   } else {
  //     // Handle unsuccessful logout if necessary
  //     // For example, show an error message
  //     _showErrorDialog(context, 'Logout failed', 'Please try again.');
  //   }

  //           }, child: Text('Logout',style: TextStyle(color: Colors.black),)),
  //         ],
  //       );
  //   });
  // }

 void _handleLogout(BuildContext context) async {
  final rootContext = context;

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(fontSize: 16, color: Colors.black),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancel',
                style: TextStyle(color: Colors.black)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog first

              // ✅ STEP 1: CLEAR TOKEN FIRST (MOST IMPORTANT)
              final authService =
                  Provider.of<AuthService>(rootContext, listen: false);

              await authService.logout();

              // ✅ STEP 2: OPTIONAL backend logout (don't block UI)
              try {
                await service.logoutUser(rootContext);
              } catch (e) {
                print("Logout API failed: $e");
              }

              // ✅ STEP 3: NAVIGATE CLEANLY (REMOVE ALL STACK)
              Navigator.pushAndRemoveUntil(
                rootContext,
                MaterialPageRoute(
                    builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text('Logout',
                style: TextStyle(color: Colors.black)),
          ),
        ],
      );
    },
  );
 }
}