// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../Model/login_request.dart';
import '../Model/login_response.dart';
import '../Model/user.dart';
import '../Model/error_response.dart';

class AuthService {
  // Replace with your Render URL
  static const String baseUrl = 'https://garment-management.onrender.com';
  static const String loginEndpoint = '/api/auth/signin';
  static const String userEndpoint = '/api/auth/me';

  static bool isDemoMode = false;

  // Toggle mode
  static void toggleMode(bool value) {
    isDemoMode = value;
  }

  // Login method
  Future<LoginResponse> login(LoginRequest request) async {
    if (isDemoMode) {
      return _demoLogin(request);
    } else {
      return _liveLogin(request);
    }
  }

  // Live backend login
  Future<LoginResponse> _liveLogin(LoginRequest request) async {
    try {
      print('🌐 Sending login request to: $baseUrl$loginEndpoint');
      print('📤 Request body: ${request.toJson()}');

      final response = await http.post(
        Uri.parse('$baseUrl$loginEndpoint'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(request.toJson()),
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response body: ${response.body}');

      if (response.statusCode == 200) {
        // Success response
        final jsonResponse = json.decode(response.body);

        // Your backend returns JwtResponse format
        final token = jsonResponse['token'];
        final id = jsonResponse['id'];
        final username = jsonResponse['username'];
        final email = jsonResponse['email'];
        final fullName = jsonResponse['fullName'];
        final roles = List<String>.from(jsonResponse['roles'] ?? []);
        final type = jsonResponse['type'] ?? 'Bearer';

        // ✅ NEW: Get isActive from response (handle both field names)
        final bool isActive;
        if (jsonResponse.containsKey('isActive')) {
          isActive = jsonResponse['isActive'] ?? true;
        } else if (jsonResponse.containsKey('active')) {
          isActive = jsonResponse['active'] ?? true;
        } else {
          isActive = true; // Default to active if not specified
        }

        // ✅ Check if user is inactive
        if (!isActive) {
          return LoginResponse(
            success: false,
            message:
                'User account is deactivated. Please contact administrator.',
          );
        }

        // Create User object
        final user = User(
          id: id,
          username: username,
          email: email,
          fullName: fullName,
          roles: roles,
          isActive: isActive, // ✅ Pass isActive
          token: token,
          type: type,
        );

        // Save to shared preferences
        await _saveToken(token);
        await _saveUser(user);
        await _saveMode();

        return LoginResponse(
          success: true,
          message: 'Login successful',
          token: token,
          user: user,
        );
      } else if (response.statusCode == 401) {
        // Unauthorized - bad credentials
        try {
          final error = ErrorResponse.fromJson(json.decode(response.body));
          return LoginResponse(success: false, message: error.message);
        } catch (e) {
          return LoginResponse(
            success: false,
            message: 'Invalid username or password',
          );
        }
      } else if (response.statusCode == 403) {
        // ✅ NEW: Handle inactive/disabled user (403 Forbidden)
        return LoginResponse(
          success: false,
          message:
              'Your account has been deactivated. Please contact administrator.',
        );
      } else {
        // Other errors
        return LoginResponse(
          success: false,
          message: 'Server error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('❌ Network error: $e');
      return LoginResponse(
        success: false,
        message: 'Network error: ${e.toString()}',
      );
    }
  }

  // Demo login with SQLite
  Future<LoginResponse> _demoLogin(LoginRequest request) async {
    try {
      print('💾 Demo login attempt: ${request.username}');

      final user = await DatabaseHelper().authenticateUser(
        request.username,
        request.password,
      );

      if (user != null) {
        // ✅ Check if user is active in demo mode
        if (!user.isActive) {
          return LoginResponse(
            success: false,
            message: 'User account is deactivated (Demo Mode)',
          );
        }

        // Generate demo token
        final demoToken = 'demo_token_${DateTime.now().millisecondsSinceEpoch}';

        final demoUser = User(
          id: user.id,
          username: user.username,
          email: user.email,
          fullName: user.fullName,
          roles: user.roles,
          isActive: user.isActive, // ✅ Pass isActive
          token: demoToken,
          type: 'Bearer',
        );

        await _saveToken(demoToken);
        await _saveUser(demoUser);
        await _saveMode();

        return LoginResponse(
          success: true,
          message: 'Login successful (Demo Mode)',
          token: demoToken,
          user: demoUser,
        );
      } else {
        return LoginResponse(
          success: false,
          message: 'Invalid credentials (Demo Mode)',
        );
      }
    } catch (e) {
      print('❌ Demo login error: $e');
      return LoginResponse(success: false, message: 'Demo error: $e');
    }
  }

  // Save token and user data
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> _saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_data', json.encode(user.toJson()));
  }

  Future<void> _saveMode() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_demo_mode', isDemoMode);
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString('user_data');

      if (userJson != null) {
        final userMap = json.decode(userJson);
        return User.fromJson(userMap);
      }
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Get stored token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Get current mode
  static Future<bool> getCurrentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_demo_mode') ?? false;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('auth_token');
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
    await prefs.remove('is_demo_mode');
  }

  // Get user profile from backend (with token)
  Future<User?> getUserProfile() async {
    try {
      final token = await getToken();
      if (token == null) return null;

      final response = await http.get(
        Uri.parse('$baseUrl$userEndpoint'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse);
      } else if (response.statusCode == 403) {
        // User might be deactivated
        print('⚠️ User profile access forbidden - account may be deactivated');
        return null;
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  // ✅ NEW: Check if current user is active
  static Future<bool> isCurrentUserActive() async {
    try {
      final user = await getCurrentUser();
      return user?.isActive ?? false;
    } catch (e) {
      print('Error checking user active status: $e');
      return false;
    }
  }

  // ✅ NEW: Force logout if user is deactivated
  static Future<bool> checkAndHandleDeactivatedUser() async {
    try {
      final user = await getCurrentUser();
      if (user != null && !user.isActive) {
        // User is deactivated, force logout
        await logout();
        return true; // User was deactivated
      }
      return false; // User is active
    } catch (e) {
      print('Error checking deactivated user: $e');
      return false;
    }
  }

  // ✅ NEW: Validate session
  static Future<bool> validateSession() async {
    if (!await isLoggedIn()) {
      return false;
    }

    // Check if user is still active
    final user = await getCurrentUser();
    if (user == null || !user.isActive) {
      await logout();
      return false;
    }

    return true;
  }
}
