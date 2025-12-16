// lib/Model/employee.dart
class Employee {
  final int? id;
  final String employeeId;
  final String firstName;
  final String lastName;
  final String email;
  final String? status;
  final String? workType;
  final String? employeeType;
  final String? designation;
  final String? phoneNumber;
  final String? address;
  final int? userId;
  final int? departmentId;
  final String? departmentName;
  final int? managerId;
  final String? managerName;

  Employee({
    this.id,
    required this.employeeId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.status = 'ACTIVE',
    this.workType = 'ONSITE',
    this.employeeType = 'FULL_TIME',
    this.designation,
    this.phoneNumber,
    this.address,
    this.userId,
    this.departmentId,
    this.departmentName,
    this.managerId,
    this.managerName,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      employeeId: json['employeeId'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      status: json['status'],
      workType: json['workType'],
      employeeType: json['employeeType'],
      designation: json['designation'],
      phoneNumber: json['phoneNumber'],
      address: json['address'],
      userId: json['userId'],
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      managerId: json['managerId'],
      managerName: json['managerName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employeeId': employeeId,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'status': status,
      'workType': workType,
      'employeeType': employeeType,
      'designation': designation,
      'phoneNumber': phoneNumber,
      'address': address,
      'userId': userId,
      'departmentId': departmentId,
      'departmentName': departmentName,
      'managerId': managerId,
      'managerName': managerName,
    };
  }
}
