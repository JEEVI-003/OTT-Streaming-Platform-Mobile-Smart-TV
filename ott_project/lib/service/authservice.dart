import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  // Keys
  static const String _tokenKey = 'token';
  static const String _userIdKey = 'userId';
  static const String _usernameKey = 'username';

  Future<void> saveAuthData({
    required String token,
    required String userId,
    required String username,
  }) async {
    await _secureStorage.write(key: _tokenKey, value: token);
    await _secureStorage.write(key: _userIdKey, value: userId);
    await _secureStorage.write(key: _usernameKey, value: username);
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: _tokenKey);
    await _secureStorage.delete(key: _userIdKey);
    await _secureStorage.delete(key: _usernameKey);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _userIdKey);
  }

  Future<String?> getUsername() async {
    return await _secureStorage.read(key: _usernameKey);
  }

  Future<bool> isLoggedIn() async {
    String? token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
