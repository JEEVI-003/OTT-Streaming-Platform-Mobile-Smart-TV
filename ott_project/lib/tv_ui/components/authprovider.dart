import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ott_project/service/service.dart';

class AuthProviderTV extends ChangeNotifier {
  final Service _service = Service();
  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  bool _isLoggedIn = false;
  int? _userId;
  Map<int, bool> _watchlist = {};

  bool get isLoggedIn => _isLoggedIn;
  int? get userId => _userId; 
  Map<int, bool> get watchlist => _watchlist;

  AuthProviderTV() {
    _checkLoginStatus();
  }

  /// Check login status when app starts
  Future<void> _checkLoginStatus() async {
    String? storedUserId = await secureStorage.read(key: 'userId');
    if (storedUserId != null) {
      _isLoggedIn = true;
      _userId = int.tryParse(storedUserId);
    } else {
      _isLoggedIn = false;
      _userId = null;
    }
    notifyListeners();
  }

  Future<bool> login(BuildContext context, String email, String password) async {
  try {
    print("Attempting login with email: $email"); // Debugging print
    bool success = await _service.loginUser1(context, email, password);
    print("Login success status: $success"); // Debugging print

    if (success) {
      _isLoggedIn = true;
      _userId = await _service.getLoggedInUserId();
      print("User ID fetched: $_userId");

      await secureStorage.write(key: 'userId', value: _userId.toString());
      notifyListeners();
    }
    return success;
  } catch (e) {
    print('Login error: $e'); // Debugging print
    return false;
  }
}


  /// Logout function with state reset
  Future<void> logout(BuildContext context) async {
    await _service.logoutUser(context);
    _isLoggedIn = false;
    _userId = null;
    
    // Clear login state from secure storage
    await secureStorage.delete(key: 'userId');

    notifyListeners();
  }

  /// Toggle watchlist items
  void toggleWatchlist(int videoId) {
    _watchlist[videoId] = !(_watchlist[videoId] ?? false);
    notifyListeners();
  }

  /// Initialize login state manually (optional)
  void initializeLoginState(bool isLoggedIn, {int? userId}) {
    _isLoggedIn = isLoggedIn;
    _userId = userId;
    notifyListeners();
  }
}
