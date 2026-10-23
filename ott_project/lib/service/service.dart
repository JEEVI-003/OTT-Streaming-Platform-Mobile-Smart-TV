import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:ott_project/components/pallete.dart';
import 'package:ott_project/service/authservice.dart';
import 'package:ott_project/url.dart';
import 'package:http_parser/http_parser.dart';

class Service {
  AuthService authService = AuthService();

  // ─── REGISTER ────────────────────────────────────────────────────────────
  Future<bool> createUser(
    BuildContext context,
    String username,
    String email,
    String mobnum,
    String password,
    String confirmpassword,
    File? profilePicture,
  ) async {
    var uri = Uri.parse('$baseUrl/userregister');
    var request = http.MultipartRequest('POST', uri);
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['mobnum'] = mobnum;
    request.fields['password'] = password;
    request.fields['confirmPassword'] = confirmpassword;

    if (profilePicture != null) {
      request.files.add(await http.MultipartFile.fromPath(
        'profile',
        profilePicture.path,
        contentType: MediaType('image', 'jpeg'),
      ));
    }

    try {
      var response = await request.send();
      print('Register status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('Register error: $e');
      _showAlertDialog(context, 'Error', 'An error occurred: $e');
      return false;
    }
  }

  // TV variant (no profile picture)
  Future<bool> createUserTV(
    BuildContext context,
    String username,
    String email,
    String mobnum,
    String password,
    String confirmpassword,
  ) async {
    var uri = Uri.parse('$baseUrl/userregister');
    var request = http.MultipartRequest('POST', uri);
    request.fields['username'] = username;
    request.fields['email'] = email;
    request.fields['mobnum'] = mobnum;
    request.fields['password'] = password;
    request.fields['confirmPassword'] = confirmpassword;

    try {
      var response = await request.send();
      print('Register TV status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      _showAlertDialog(context, 'Error', 'An error occurred: $e');
      return false;
    }
  }

  // ─── LOGIN ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> loginUser(
    BuildContext context,
    String email,
    String password,
    TextEditingController emailController,
    TextEditingController passwordController,
  ) async {
    var uri = Uri.parse('$baseUrl/login');
    Map<String, String> headers = {'Content-Type': 'application/json'};
    var body = jsonEncode({'email': email, 'password': password});

    try {
      var response = await http.post(uri, headers: headers, body: body);
      print('Login status: ${response.statusCode}');
      print('Login body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        final token = data['token']?.toString() ?? '';
        final userId = data['userId']?.toString() ?? '';
        final username =
            data['username']?.toString() ?? data['name']?.toString() ?? email;
        await authService.saveAuthData(
            token: token, userId: userId, username: username);

        return data;
      } else if (response.statusCode == 401) {
        _showAlertDialog(context, 'Login Failed', 'Incorrect password.');
      } else if (response.statusCode == 404) {
        _showAlertDialog(context, 'Login Failed',
            'User not found. Please check your email.');
        emailController.clear();
        passwordController.clear();
      } else {
        _showAlertDialog(
            context, 'Login Failed', 'An error occurred. Please try again.');
      }
    } catch (e) {
      print('Login error: $e');
      _showAlertDialog(context, 'Error', 'Cannot reach server: $e');
    }

    return null;
  }

  // TV login (simple bool variant kept for TV screens)
  Future<bool> loginUser1(
      BuildContext context, String email, String password) async {
    try {
      var uri = Uri.parse('$baseUrl/login');
      var response = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'email': email, 'password': password}));

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        await authService.saveAuthData(
          token: data['token'] ?? '',
          userId: data['userId']?.toString() ?? '',
          username: data['username'] ?? '',
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Login error: $e');
      return false;
    }
  }

  // ─── PROFILE IMAGE ────────────────────────────────────────────────────────
  // 404 handled silently — returns null → caller shows default avatar.
  Future<Uint8List?> fetchProfileImage() async {
    String? token = await authService.getToken();
    String? userId = await authService.getUserId();
    if (token == null || userId == null) return null;

    try {
      var response = await http.get(
        Uri.parse('$baseUrl/GetProfileImage/$userId'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) return response.bodyBytes;
      // 404 = no profile image set yet — silently return null
      return null;
    } catch (e) {
      // Network error — silently return null, show default avatar
      return null;
    }
  }

  // ─── USER PROFILE ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>?> fetchUserProfile() async {
    String? token = await authService.getToken();
    String? userId = await authService.getUserId();
    if (token == null || userId == null) return null;

    try {
      var response = await http.get(
        Uri.parse('$baseUrl/GetUserById/$userId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) return jsonDecode(response.body);
      print('User profile fetch failed: ${response.statusCode}');
    } catch (e) {
      print('User profile error: $e');
    }
    return null;
  }

  Future<int?> getLoggedInUserId() async {
    String? userId = await authService.getUserId();
    return userId != null ? int.tryParse(userId) : null;
  }

  // ─── UPDATE USER PROFILE ──────────────────────────────────────────────────
  // ✅ FIXED: Now sends 'email' field — backend requires username + email + mobnum.
  //           Missing email was the cause of the 500 error.
  Future<bool> updateUserProfile({
    required String name,
    required String phone,
    required String email, // ✅ ADDED — backend requires this field
    Uint8List? imageBytes,
  }) async {
    try {
      String? token = await authService.getToken();
      String? userId = await authService.getUserId();
      if (token == null || userId == null) return false;

      var url = Uri.parse('$baseUrl/updateUser/$userId');
      var request = http.MultipartRequest('PUT', url);
      request.headers['Authorization'] = 'Bearer $token';
      request.fields['username'] = name;
      request.fields['email'] = email;   // ✅ FIXED — was missing before
      request.fields['mobnum'] = phone;

      if (imageBytes != null) {
        request.files.add(http.MultipartFile.fromBytes(
          'profileImage',
          imageBytes,
          filename: 'profile.jpg',
          contentType: MediaType('image', 'jpeg'),
        ));
      }

      var streamed = await request.send();
      print('updateUserProfile status: ${streamed.statusCode}');
      return streamed.statusCode == 200;
    } catch (e) {
      print('updateUserProfile error: $e');
      return false;
    }
  }

  // ─── UPLOAD PROFILE IMAGE (standalone) ───────────────────────────────────
  // ✅ FIXED: Fetches current profile first so email/name/phone are not empty.
  Future<bool> uploadProfileImage(Uint8List imageBytes) async {
    // Fetch current user data so we don't send empty fields to the backend
    var profile = await fetchUserProfile();
    String currentEmail = profile?['email']?.toString() ?? '';
    String currentName = profile?['username']?.toString() ?? '';
    String currentPhone = profile?['phoneNumber']?.toString() ?? '';

    return updateUserProfile(
      name: currentName,
      phone: currentPhone,
      email: currentEmail, // ✅ pass real email
      imageBytes: imageBytes,
    );
  }

  // ─── CHANGE PASSWORD ──────────────────────────────────────────────────────
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      String? token = await authService.getToken();
      String? userId = await authService.getUserId();
      if (token == null || userId == null) return false;

      var response = await http.patch(
        Uri.parse('$baseUrl/Update/user/$userId?password=$newPassword'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      print('changePassword status: ${response.statusCode}');
      return response.statusCode == 200;
    } catch (e) {
      print('changePassword error: $e');
      return false;
    }
  }

  // ─── LOGOUT ───────────────────────────────────────────────────────────────
  Future<bool> logoutUser(BuildContext context) async {
    String? token = await authService.getToken();
    if (token == null) {
      _showAlertDialog(context, 'Error', 'No active session found.');
      return false;
    }

    var uri = Uri.parse('$baseUrl/logout');
    try {
      var response = await http.post(uri, headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      });

      if (response.statusCode == 200) {
        await authService.logout();
        return true;
      } else {
        _showAlertDialog(context, 'Error', 'Failed to logout.');
        return false;
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'An error occurred: $e');
      return false;
    }
  }

  // ─── HELPER ───────────────────────────────────────────────────────────────
  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade300,
        title: Text(title, style: const TextStyle(color: Colors.black)),
        content: Text(message, style: const TextStyle(color: Colors.black)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}