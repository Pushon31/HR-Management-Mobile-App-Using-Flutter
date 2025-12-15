import 'package:hr_system/Model/user.dart';

class LoginResponse {
  final bool success;
  final String message;
  final String? token;
  final User? user;
  final bool isActive;

  LoginResponse({
    required this.success,
    required this.message,
    this.token,
    this.user,
    this.isActive = true,
  });
}
