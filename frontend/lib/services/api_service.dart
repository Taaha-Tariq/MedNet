import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import '../models/health_data_model.dart';

class ApiService {
  // Dynamically select base URL based on platform for local development.
  static String get baseUrl {
    // Hosted backend (Render)
    return 'https://mednet-lwki.onrender.com/api';
  }

  // Headers
  Map<String, String> getHeaders({String? token}) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ============ AUTH ENDPOINTS ============

  /// Sign up a new user
  /// POST /auth/signup
  /// Body: {fullName, email, password, age}
  Future<Map<String, dynamic>> signUp({
    required String fullName,
    required String email,
    required String password,
    required int age,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/signup'),
        headers: getHeaders(),
        body: jsonEncode({
          'fullName': fullName,
          'email': email,
          'password': password,
          'age': age,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Sign up failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Login user
  /// POST /auth/login
  /// Body: {email, password}
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/auth/login'),
        headers: getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Login failed'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ USER ENDPOINTS ============

  /// Get user profile
  /// GET /users/me
  Future<Map<String, dynamic>> getUserProfile(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/me'),
        headers: getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch profile'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Update user profile
  /// PUT /users/me
  /// Body: {fullName?, email?, age?, bloodGroup?, gender?, height?, weight?, phoneNumber?, dateOfBirth?, allergies?, medications?, medicalConditions?, emergencyContactName?, emergencyContactPhone?, emergencyContactRelation?, profileImageUrl?}
  Future<Map<String, dynamic>> updateUserProfile(
    String token, {
    String? fullName,
    String? email,
    int? age,
    String? bloodGroup,
    String? gender,
    double? height,
    double? weight,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? allergies,
    String? medications,
    String? medicalConditions,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? profileImageUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (fullName != null) body['fullName'] = fullName;
      if (email != null) body['email'] = email;
      if (age != null) body['age'] = age;
      if (bloodGroup != null) body['bloodGroup'] = bloodGroup;
      if (gender != null) body['gender'] = gender;
      if (height != null) body['height'] = height;
      if (weight != null) body['weight'] = weight;
      if (phoneNumber != null) body['phoneNumber'] = phoneNumber;
      if (dateOfBirth != null) body['dateOfBirth'] = dateOfBirth.toIso8601String();
      if (allergies != null) body['allergies'] = allergies;
      if (medications != null) body['medications'] = medications;
      if (medicalConditions != null) body['medicalConditions'] = medicalConditions;
      if (emergencyContactName != null) body['emergencyContactName'] = emergencyContactName;
      if (emergencyContactPhone != null) body['emergencyContactPhone'] = emergencyContactPhone;
      if (emergencyContactRelation != null) body['emergencyContactRelation'] = emergencyContactRelation;
      if (profileImageUrl != null) body['profileImageUrl'] = profileImageUrl;

      final response = await http.put(
        Uri.parse('$baseUrl/users/me'),
        headers: getHeaders(token: token),
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update profile'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // ============ HEALTH DATA ENDPOINTS ============

  /// Get current health data (latest readings)
  /// GET /health/current
  Future<Map<String, dynamic>> getCurrentHealthData(String token) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health/current'),
        headers: getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch health data'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get health data by type
  /// GET /health/{type}
  /// Query params: ?limit=10&offset=0
  Future<Map<String, dynamic>> getHealthDataByType(
    String token,
    HealthType type, {
    int limit = 10,
    int offset = 0,
  }) async {
    try {
      final typeString = type.toString().split('.').last;
      final response = await http.get(
        Uri.parse(
            '$baseUrl/health/$typeString?limit=$limit&offset=$offset'),
        headers: getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch health data'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Get health history/analysis
  /// GET /health/history
  /// Query params: ?type={type}&startDate={date}&endDate={date}
  Future<Map<String, dynamic>> getHealthHistory(
    String token, {
    HealthType? type,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (type != null) {
        queryParams['type'] = type.toString().split('.').last;
      }
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }

      final uri = Uri.parse('$baseUrl/health/history')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: getHeaders(token: token),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to fetch history'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  /// Submit health data
  /// POST /health/submit
  /// Body: {type, value, unit, timestamp?, additionalData?}
  Future<Map<String, dynamic>> submitHealthData(
    String token, {
    required HealthType type,
    required double value,
    String? unit,
    DateTime? timestamp,
    Map<String, dynamic>? additionalData,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/health/submit'),
        headers: getHeaders(token: token),
        body: jsonEncode({
          'type': type.toString().split('.').last,
          'value': value,
          'unit': unit ?? type.unit,
          'timestamp': (timestamp ?? DateTime.now()).toIso8601String(),
          if (additionalData != null) 'additionalData': additionalData,
        }),
      );

      final data = jsonDecode(response.body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return {'success': true, 'data': data};
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit health data'
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}


