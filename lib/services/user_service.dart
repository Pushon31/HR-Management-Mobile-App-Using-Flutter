// lib/services/user_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Model/user.dart';
import '../database/user_database.dart';

class UserService {
  static const String baseUrl = 'https://garment-management.onrender.com';
  static const String usersEndpoint = '/api/admin/users';
  static const String userByIdEndpoint = '/api/admin/users';
  static const String userRolesEndpoint = '/api/admin/users/role';
  static const String employeeEndpoint =
      '/api/employees'; // ✅ Employee endpoint

  static bool isDemoMode = false;

  // Toggle mode
  static void toggleMode(bool value) {
    isDemoMode = value;
  }

  // Get current mode
  static Future<bool> getCurrentMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('is_demo_mode') ?? false;
  }

  // Get auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Headers for API requests
  Future<Map<String, String>> _getHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ✅ NEW: Create employee for user
  Future<Map<String, dynamic>> _createEmployeeForUser(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    try {
      final headers = await _getHeaders();

      // Extract first and last name from full name
      final fullName = userData['fullName'] ?? '';
      final nameParts = fullName.split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final lastName = nameParts.length > 1
          ? nameParts.sublist(1).join(' ')
          : '';

      // Generate employee ID
      final employeeId = 'EMP${DateTime.now().millisecondsSinceEpoch}'
          .substring(0, 10);

      // Determine designation from roles
      final roles = List<String>.from(userData['roles'] ?? []);
      String designation = 'Employee';

      if (roles.contains('ROLE_MANAGER')) {
        designation = 'Manager';
      } else if (roles.contains('ROLE_HR')) {
        designation = 'HR Manager';
      } else if (roles.contains('ROLE_ACCOUNTANT')) {
        designation = 'Accountant';
      }

      final employeeData = {
        'userId': userId,
        'employeeId': employeeId,
        'firstName': firstName,
        'lastName': lastName,
        'email': userData['email'],
        'status': 'ACTIVE',
        'workType': 'ONSITE',
        'employeeType': 'FULL_TIME',
        'designation': designation,
        'phoneNumber': 'Not set',
        'address': 'Address not provided',
      };

      final response = await http.post(
        Uri.parse('$baseUrl$employeeEndpoint'),
        headers: headers,
        body: json.encode(employeeData),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        return {
          'success': true,
          'employeeId': employeeId,
          'designation': designation,
          'employeeData': jsonResponse,
        };
      } else {
        return {
          'success': false,
          'error': 'Failed to create employee: ${response.statusCode}',
        };
      }
    } catch (e) {
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  // ✅ UPDATED: Create new user with employee auto-creation
  Future<User> createUser(
    Map<String, dynamic> userData, {
    BuildContext? context,
    bool autoCreateEmployee = true,
  }) async {
    if (isDemoMode) {
      return _createUserDemo(userData);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('$baseUrl$usersEndpoint'),
        headers: headers,
        body: json.encode(userData),
      );

      print('📥 Create User Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = json.decode(response.body);
        final userId = jsonResponse['userId'] ?? 0;

        // Check if user has employee-related roles
        final roles = List<String>.from(userData['roles'] ?? []);
        final employeeRoles = [
          'ROLE_EMPLOYEE',
          'ROLE_MANAGER',
          'ROLE_HR',
          'ROLE_ACCOUNTANT',
        ];
        final hasEmployeeRole = roles.any(
          (role) => employeeRoles.contains(role),
        );

        String employeeCode = '';
        String designation = '';

        // Auto-create employee if needed
        if (hasEmployeeRole && autoCreateEmployee) {
          final employeeResult = await _createEmployeeForUser(userId, userData);

          if (employeeResult['success'] == true) {
            employeeCode = employeeResult['employeeId'] ?? '';
            designation = employeeResult['designation'] ?? '';

            // Show success message if context is provided
            if (context != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '✅ User created! Employee profile created with ID: $employeeCode',
                    ),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 5),
                  ),
                );
              });
            }
          } else {
            // Show warning if employee creation failed
            if (context != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '⚠️ User created but employee profile creation failed. Please create manually.',
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
              });
            }
          }
        } else if (hasEmployeeRole && !autoCreateEmployee && context != null) {
          // Show instruction for manual creation
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'ℹ️ User created! Please create employee profile manually.',
                ),
                backgroundColor: Colors.blue,
              ),
            );
          });
        }

        // Fetch the created user with updated info
        final createdUser = await getUserById(userId);

        // Update user with employee info if available
        return createdUser.copyWith(
          employeeCode: employeeCode.isNotEmpty ? employeeCode : null,
          designation: designation.isNotEmpty ? designation : null,
        );
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Bad request');
      } else {
        throw Exception('Failed to create user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error creating user: $e');
      rethrow;
    }
  }

  // ✅ NEW: Create user with employee (convenience method)
  Future<User> createUserWithEmployee(
    Map<String, dynamic> userData, {
    BuildContext? context,
  }) async {
    return createUser(userData, context: context, autoCreateEmployee: true);
  }

  // ✅ NEW: Get users without employee profiles
  Future<List<User>> getUsersWithoutEmployee() async {
    try {
      final allUsers = await getAllUsers();
      final employeeRoles = [
        'ROLE_EMPLOYEE',
        'ROLE_MANAGER',
        'ROLE_HR',
        'ROLE_ACCOUNTANT',
      ];

      return allUsers.where((user) {
        final hasEmployeeRole = user.roles.any(
          (role) => employeeRoles.contains(role),
        );
        final hasEmployeeCode =
            user.employeeCode != null && user.employeeCode!.isNotEmpty;
        return hasEmployeeRole && !hasEmployeeCode;
      }).toList();
    } catch (e) {
      print('❌ Error getting users without employee: $e');
      return [];
    }
  }

  // ✅ NEW: Create employee for existing user
  Future<Map<String, dynamic>> createEmployeeForExistingUser(
    int userId, {
    BuildContext? context,
  }) async {
    try {
      final user = await getUserById(userId);

      final userData = {
        'username': user.username,
        'email': user.email,
        'fullName': user.fullName,
        'roles': user.roles,
      };

      final result = await _createEmployeeForUser(userId, userData);

      if (result['success'] == true && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Employee profile created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else if (result['success'] == false && context != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '❌ Failed to create employee profile: ${result['error']}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }

      return result;
    } catch (e) {
      print('❌ Error creating employee for existing user: $e');
      return {'success': false, 'error': 'Exception: $e'};
    }
  }

  // 1. Get all users
  Future<List<User>> getAllUsers() async {
    if (isDemoMode) {
      return _getAllUsersDemo();
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$usersEndpoint'),
        headers: headers,
      );

      print('📥 Get All Users Status: ${response.statusCode}');
      print('📥 Response: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((userJson) => User.fromJson(userJson)).toList();
      } else {
        throw Exception('Failed to load users: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting users: $e');
      throw Exception('Network error: $e');
    }
  }

  // 2. Get user by ID
  Future<User> getUserById(int userId) async {
    if (isDemoMode) {
      return _getUserByIdDemo(userId);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$userByIdEndpoint/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        return User.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting user by ID: $e');
      throw Exception('Network error: $e');
    }
  }

  // 4. Update user
  Future<User> updateUser(int userId, Map<String, dynamic> userData) async {
    if (isDemoMode) {
      return _updateUserDemo(userId, userData);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$userByIdEndpoint/$userId'),
        headers: headers,
        body: json.encode(userData),
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        // Fetch updated user
        return await getUserById(userId);
      } else if (response.statusCode == 400) {
        final error = json.decode(response.body);
        throw Exception(error['message'] ?? 'Bad request');
      } else {
        throw Exception('Failed to update user: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error updating user: $e');
      rethrow;
    }
  }

  // 5. Delete user
  Future<bool> deleteUser(int userId) async {
    if (isDemoMode) {
      return _deleteUserDemo(userId);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.delete(
        Uri.parse('$baseUrl$userByIdEndpoint/$userId'),
        headers: headers,
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error deleting user: $e');
      return false;
    }
  }

  // 6. Activate user
  Future<bool> activateUser(int userId) async {
    final user = await getUserById(userId);
    final updatedUser = user.copyWith(isActive: true);
    final result = await updateUser(userId, updatedUser.toJson());
    return result.isActive;
  }

  // 7. Deactivate user
  Future<bool> deactivateUser(int userId) async {
    final user = await getUserById(userId);
    final updatedUser = user.copyWith(isActive: false);
    final result = await updateUser(userId, updatedUser.toJson());
    return !result.isActive;
  }

  // 8. Update user roles
  Future<bool> updateUserRoles(int userId, List<String> roleNames) async {
    if (isDemoMode) {
      return _updateUserRolesDemo(userId, roleNames);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.put(
        Uri.parse('$baseUrl$userByIdEndpoint/$userId/roles'),
        headers: headers,
        body: json.encode({'roleNames': roleNames}),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('❌ Error updating user roles: $e');
      return false;
    }
  }

  // 9. Get users by role
  Future<List<User>> getUsersByRole(String roleName) async {
    if (isDemoMode) {
      return _getUsersByRoleDemo(roleName);
    }

    try {
      final headers = await _getHeaders();
      final response = await http.get(
        Uri.parse('$baseUrl$userRolesEndpoint/$roleName'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((userJson) => User.fromJson(userJson)).toList();
      } else {
        throw Exception('Failed to load users by role: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error getting users by role: $e');
      throw Exception('Network error: $e');
    }
  }

  // 10. Search users
  Future<List<User>> searchUsers(String query) async {
    final allUsers = await getAllUsers();
    return allUsers.where((user) {
      return user.username.toLowerCase().contains(query.toLowerCase()) ||
          user.email.toLowerCase().contains(query.toLowerCase()) ||
          user.fullName.toLowerCase().contains(query.toLowerCase()) ||
          user.roles.any(
            (role) => role.toLowerCase().contains(query.toLowerCase()),
          );
    }).toList();
  }

  // ==================== DEMO METHODS ====================

  Future<List<User>> _getAllUsersDemo() async {
    await Future.delayed(Duration(seconds: 1)); // Simulate network delay
    return await UserDatabase().getAllUsers();
  }

  Future<User> _getUserByIdDemo(int userId) async {
    await Future.delayed(Duration(seconds: 1));
    return await UserDatabase().getUserById(userId);
  }

  Future<User> _createUserDemo(Map<String, dynamic> userData) async {
    await Future.delayed(Duration(seconds: 1));
    final id = DateTime.now().millisecondsSinceEpoch;

    // Check for employee roles in demo mode too
    final roles = List<String>.from(userData['roles'] ?? ['ROLE_EMPLOYEE']);
    final employeeRoles = [
      'ROLE_EMPLOYEE',
      'ROLE_MANAGER',
      'ROLE_HR',
      'ROLE_ACCOUNTANT',
    ];
    final hasEmployeeRole = roles.any((role) => employeeRoles.contains(role));

    String? employeeCode;
    String? designation;

    if (hasEmployeeRole) {
      employeeCode = 'DEMO-EMP${DateTime.now().millisecondsSinceEpoch}'
          .substring(0, 10);
      if (roles.contains('ROLE_MANAGER')) {
        designation = 'Manager';
      } else if (roles.contains('ROLE_HR')) {
        designation = 'HR Manager';
      } else if (roles.contains('ROLE_ACCOUNTANT')) {
        designation = 'Accountant';
      } else {
        designation = 'Employee';
      }
    }

    final user = User(
      id: id,
      username: userData['username'],
      email: userData['email'],
      fullName: userData['fullName'],
      roles: roles,
      isActive: true,
      employeeCode: employeeCode,
      designation: designation,
    );

    await UserDatabase().insertUser(user);
    return user;
  }

  Future<User> _updateUserDemo(
    int userId,
    Map<String, dynamic> userData,
  ) async {
    await Future.delayed(Duration(seconds: 1));
    final existingUser = await UserDatabase().getUserById(userId);
    final updatedUser = existingUser.copyWith(
      username: userData['username'] ?? existingUser.username,
      email: userData['email'] ?? existingUser.email,
      fullName: userData['fullName'] ?? existingUser.fullName,
      roles: List<String>.from(userData['roles'] ?? existingUser.roles),
      isActive: userData['isActive'] ?? existingUser.isActive,
    );
    await UserDatabase().updateUser(updatedUser);
    return updatedUser;
  }

  Future<bool> _deleteUserDemo(int userId) async {
    await Future.delayed(Duration(seconds: 1));
    return await UserDatabase().deleteUser(userId) > 0;
  }

  Future<bool> _updateUserRolesDemo(int userId, List<String> roleNames) async {
    await Future.delayed(Duration(seconds: 1));
    final user = await UserDatabase().getUserById(userId);
    final updatedUser = user.copyWith(roles: roleNames);
    await UserDatabase().updateUser(updatedUser);
    return true;
  }

  Future<List<User>> _getUsersByRoleDemo(String roleName) async {
    await Future.delayed(Duration(seconds: 1));
    final allUsers = await UserDatabase().getAllUsers();
    return allUsers
        .where((user) => user.roles.any((role) => role.contains(roleName)))
        .toList();
  }
}
