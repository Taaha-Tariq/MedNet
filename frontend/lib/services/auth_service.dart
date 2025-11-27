import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'api_service.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiService _apiService = ApiService();
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  /// Sign up a new user
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
    required int age,
  }) async {
    final result = await _apiService.signUp(
      fullName: fullName,
      email: email,
      password: password,
      age: age,
    );

    if (result['success'] == true) {
      final data = result['data'];
      final token = data['token'] ?? data['accessToken'];
      final user = User.fromJson(data['user'] ?? data);

      // Save token and user data
      if (token != null) {
        await _saveToken(token);
        await _saveUser(user);
      }

      return {'success': true, 'user': user, 'token': token};
    }

    return result;
  }

  /// Login user
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final result = await _apiService.login(email: email, password: password);

    if (result['success'] == true) {
      final data = result['data'];
      final token = data['token'] ?? data['accessToken'];
      final user = User.fromJson(data['user'] ?? data);

      // Save token and user data
      if (token != null) {
        await _saveToken(token);
        await _saveUser(user);
      }

      return {'success': true, 'user': user, 'token': token};
    }

    return result;
  }

  /// Logout user
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  /// Get current auth token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get current user
  Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final userMap = jsonDecode(userJson) as Map<String, dynamic>;
        return User.fromJson(userMap);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Save auth token
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Save user data
  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = jsonEncode(user.toJson());
    await prefs.setString(_userKey, userJson);
  }
}

