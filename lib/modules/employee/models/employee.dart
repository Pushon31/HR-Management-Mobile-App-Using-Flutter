// lib/modules/employee/models/employee.dart
class Employee {
  final int? id;
  final String firstName;
  final String lastName;
  final String employeeId;
  final String email;
  final String? nidNumber;
  final String? bankAccountNumber;
  final String? gender;
  final String? maritalStatus;
  final int? departmentId;
  final String? departmentName;
  final DateTime? birthDate;
  final DateTime? joinDate;
  final String? phoneNumber;
  final String? emergencyContact;
  final String? address;
  final String designation;
  final String? employeeType;
  final String? shift;
  final double? basicSalary;
  final String? profilePic;
  final int? managerId;
  final String? managerName;
  final String status;
  final int? userId;
  final String? workType;

  Employee({
    this.id,
    required this.firstName,
    required this.lastName,
    required this.employeeId,
    required this.email,
    this.nidNumber,
    this.bankAccountNumber,
    this.gender,
    this.maritalStatus,
    this.departmentId,
    this.departmentName,
    this.birthDate,
    this.joinDate,
    this.phoneNumber,
    this.emergencyContact,
    this.address,
    required this.designation,
    this.employeeType,
    this.shift,
    this.basicSalary,
    this.profilePic,
    this.managerId,
    this.managerName,
    required this.status,
    this.userId,
    this.workType,
  });

  String get fullName => '$firstName $lastName';

  bool get isActive => status.toLowerCase() == 'active';

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      employeeId: json['employeeId'] ?? '',
      email: json['email'] ?? '',
      nidNumber: json['nidNumber'],
      bankAccountNumber: json['bankAccountNumber'],
      gender: json['gender'],
      maritalStatus: json['maritalStatus'],
      departmentId: json['departmentId'] != null
          ? int.tryParse(json['departmentId'].toString())
          : null,
      departmentName: json['departmentName'],
      birthDate: json['birthDate'] != null
          ? DateTime.parse(json['birthDate'])
          : null,
      joinDate: json['joinDate'] != null
          ? DateTime.parse(json['joinDate'])
          : null,
      phoneNumber: json['phoneNumber'],
      emergencyContact: json['emergencyContact'],
      address: json['address'],
      designation: json['designation'] ?? '',
      employeeType: json['employeeType'],
      shift: json['shift'],
      basicSalary: json['basicSalary'] != null
          ? double.tryParse(json['basicSalary'].toString())
          : null,
      profilePic: json['profilePic'],
      managerId: json['managerId'] != null
          ? int.tryParse(json['managerId'].toString())
          : null,
      managerName: json['managerName'],
      status: json['status'] ?? 'ACTIVE',
      userId: json['userId'] != null
          ? int.tryParse(json['userId'].toString())
          : null,
      workType: json['workType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'employeeId': employeeId,
      'email': email,
      if (nidNumber != null) 'nidNumber': nidNumber,
      if (bankAccountNumber != null) 'bankAccountNumber': bankAccountNumber,
      if (gender != null) 'gender': gender,
      if (maritalStatus != null) 'maritalStatus': maritalStatus,
      if (departmentId != null) 'departmentId': departmentId,
      if (departmentName != null) 'departmentName': departmentName,
      if (birthDate != null) 'birthDate': birthDate!.toIso8601String(),
      if (joinDate != null) 'joinDate': joinDate!.toIso8601String(),
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (address != null) 'address': address,
      'designation': designation,
      if (employeeType != null) 'employeeType': employeeType,
      if (shift != null) 'shift': shift,
      if (basicSalary != null) 'basicSalary': basicSalary,
      if (profilePic != null) 'profilePic': profilePic,
      if (managerId != null) 'managerId': managerId,
      if (managerName != null) 'managerName': managerName,
      'status': status,
      if (userId != null) 'userId': userId,
      if (workType != null) 'workType': workType,
    };
  }

  Employee copyWith({
    int? id,
    String? firstName,
    String? lastName,
    String? employeeId,
    String? email,
    String? nidNumber,
    String? bankAccountNumber,
    String? gender,
    String? maritalStatus,
    int? departmentId,
    String? departmentName,
    DateTime? birthDate,
    DateTime? joinDate,
    String? phoneNumber,
    String? emergencyContact,
    String? address,
    String? designation,
    String? employeeType,
    String? shift,
    double? basicSalary,
    String? profilePic,
    int? managerId,
    String? managerName,
    String? status,
    int? userId,
    String? workType,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      employeeId: employeeId ?? this.employeeId,
      email: email ?? this.email,
      nidNumber: nidNumber ?? this.nidNumber,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      gender: gender ?? this.gender,
      maritalStatus: maritalStatus ?? this.maritalStatus,
      departmentId: departmentId ?? this.departmentId,
      departmentName: departmentName ?? this.departmentName,
      birthDate: birthDate ?? this.birthDate,
      joinDate: joinDate ?? this.joinDate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      address: address ?? this.address,
      designation: designation ?? this.designation,
      employeeType: employeeType ?? this.employeeType,
      shift: shift ?? this.shift,
      basicSalary: basicSalary ?? this.basicSalary,
      profilePic: profilePic ?? this.profilePic,
      managerId: managerId ?? this.managerId,
      managerName: managerName ?? this.managerName,
      status: status ?? this.status,
      userId: userId ?? this.userId,
      workType: workType ?? this.workType,
    );
  }
}
