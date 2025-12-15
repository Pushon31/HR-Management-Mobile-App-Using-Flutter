// lib/models/user.dart
class User {
  final int id;
  final String username;
  final String email;
  final String fullName;
  final List<String> roles;
  final bool isActive; // ✅ NEW FIELD
  final String? token;
  final String? type;
  final String? employeeCode; // ✅ NEW: Employee code if linked
  final String? designation; // ✅ NEW: Designation if employee

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.fullName,
    required this.roles,
    required this.isActive, // ✅ Required now
    this.token,
    this.type = 'Bearer',
    this.employeeCode,
    this.designation,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json['id'] ?? 0,
    username: json['username'] ?? '',
    email: json['email'] ?? '',
    fullName: json['fullName'] ?? json['full_name'] ?? '',
    roles: List<String>.from(json['roles'] ?? []),
    isActive: json['isActive'] ?? json['active'] ?? true, // ✅ Map isActive
    token: json['token'],
    type: json['type'],
    employeeCode: json['employeeCode'],
    designation: json['designation'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'email': email,
    'fullName': fullName,
    'roles': roles,
    'isActive': isActive,
    'token': token,
    'type': type,
    'employeeCode': employeeCode,
    'designation': designation,
  };

  // Copy with method for updates
  User copyWith({
    int? id,
    String? username,
    String? email,
    String? fullName,
    List<String>? roles,
    bool? isActive,
    String? token,
    String? type,
    String? employeeCode,
    String? designation,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      roles: roles ?? this.roles,
      isActive: isActive ?? this.isActive,
      token: token ?? this.token,
      type: type ?? this.type,
      employeeCode: employeeCode ?? this.employeeCode,
      designation: designation ?? this.designation,
    );
  }

  // Helper methods to check roles
  bool get isAdmin => roles.any((role) => role.contains('ADMIN'));
  bool get isManager => roles.any((role) => role.contains('MANAGER'));
  bool get isHR => roles.any((role) => role.contains('HR'));
  bool get isAccountant => roles.any((role) => role.contains('ACCOUNTANT'));
  bool get isEmployee => roles.any((role) => role.contains('EMPLOYEE'));

  String get roleDisplay {
    if (isAdmin) return 'Admin';
    if (isManager) return 'Manager';
    if (isHR) return 'HR Manager';
    if (isAccountant) return 'Accountant';
    if (isEmployee) return 'Employee';
    return 'User';
  }
}
