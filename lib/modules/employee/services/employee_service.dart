// lib/modules/employee/services/employee_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/auth_service.dart';
import '../models/employee.dart';
import '../../../database/employee_database.dart';

class EmployeeService {
  static const String baseUrl = 'https://garment-management.onrender.com';

  // Live backend methods
  Future<List<Employee>> getEmployees() async {
    if (AuthService.isDemoMode) {
      return await _getDemoEmployees();
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/employees'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching employees: $e');
      return [];
    }
  }

  Future<Employee?> getEmployeeById(int id) async {
    if (AuthService.isDemoMode) {
      return await _getDemoEmployeeById(id);
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/employees/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching employee: $e');
      return null;
    }
  }

  Future<Employee?> getEmployeeByUserId(int userId) async {
    if (AuthService.isDemoMode) {
      return await _getDemoEmployeeByUserId(userId);
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/employees/user/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data);
      }
      return null;
    } catch (e) {
      print('Error fetching employee by user ID: $e');
      return null;
    }
  }

  Future<Employee> updateEmployee(int id, Employee employee) async {
    if (AuthService.isDemoMode) {
      return await _updateDemoEmployee(id, employee);
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/api/employees/$id'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(employee.toJson()),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Employee.fromJson(data);
      }
      throw Exception('Failed to update employee');
    } catch (e) {
      print('Error updating employee: $e');
      throw e;
    }
  }

  Future<List<Employee>> searchEmployees(String query) async {
    if (AuthService.isDemoMode) {
      return await _searchDemoEmployees(query);
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/employees/search?query=$query'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching employees: $e');
      return [];
    }
  }

  Future<List<Employee>> getEmployeesByDesignation(String designation) async {
    if (AuthService.isDemoMode) {
      return await _getDemoEmployeesByDesignation(designation);
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/employees/designation/$designation'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching employees by designation: $e');
      return [];
    }
  }

  Future<List<Employee>> getEmployeesByStatus(String status) async {
    if (AuthService.isDemoMode) {
      return await _getDemoEmployeesByStatus(status);
    }

    try {
      final token = await AuthService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/api/employees/status/$status'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Employee.fromJson(json)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching employees by status: $e');
      return [];
    }
  }

  // Demo mode methods
  Future<List<Employee>> _getDemoEmployees() async {
    final db = await EmployeeDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');
    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'],
        firstName: maps[i]['first_name'],
        lastName: maps[i]['last_name'],
        employeeId: maps[i]['employee_id'],
        email: maps[i]['email'],
        designation: maps[i]['designation'],
        status: maps[i]['status'],
        phoneNumber: maps[i]['phone_number'],
        departmentId: maps[i]['department_id'],
        departmentName: maps[i]['department_name'],
        joinDate: maps[i]['join_date'] != null
            ? DateTime.parse(maps[i]['join_date'])
            : null,
        workType: maps[i]['work_type'],
      );
    });
  }

  Future<Employee?> _getDemoEmployeeById(int id) async {
    final db = await EmployeeDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Employee(
        id: maps[0]['id'],
        firstName: maps[0]['first_name'],
        lastName: maps[0]['last_name'],
        employeeId: maps[0]['employee_id'],
        email: maps[0]['email'],
        designation: maps[0]['designation'],
        status: maps[0]['status'],
        phoneNumber: maps[0]['phone_number'],
        departmentId: maps[0]['department_id'],
        departmentName: maps[0]['department_name'],
        joinDate: maps[0]['join_date'] != null
            ? DateTime.parse(maps[0]['join_date'])
            : null,
        workType: maps[0]['work_type'],
      );
    }
    return null;
  }

  Future<Employee?> _getDemoEmployeeByUserId(int userId) async {
    final db = await EmployeeDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (maps.isNotEmpty) {
      return Employee(
        id: maps[0]['id'],
        firstName: maps[0]['first_name'],
        lastName: maps[0]['last_name'],
        employeeId: maps[0]['employee_id'],
        email: maps[0]['email'],
        designation: maps[0]['designation'],
        status: maps[0]['status'],
        phoneNumber: maps[0]['phone_number'],
        departmentId: maps[0]['department_id'],
        departmentName: maps[0]['department_name'],
        joinDate: maps[0]['join_date'] != null
            ? DateTime.parse(maps[0]['join_date'])
            : null,
        workType: maps[0]['work_type'],
      );
    }
    return null;
  }

  Future<Employee> _updateDemoEmployee(int id, Employee employee) async {
    final db = await EmployeeDatabase.instance.database;
    await db.update(
      'employees',
      {
        'first_name': employee.firstName,
        'last_name': employee.lastName,
        'email': employee.email,
        'phone_number': employee.phoneNumber,
        'designation': employee.designation,
        'status': employee.status,
        'department_id': employee.departmentId,
        'department_name': employee.departmentName,
        'work_type': employee.workType,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    return employee.copyWith(id: id);
  }

  Future<List<Employee>> _searchDemoEmployees(String query) async {
    final db = await EmployeeDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where:
          'first_name LIKE ? OR last_name LIKE ? OR email LIKE ? OR employee_id LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%', '%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'],
        firstName: maps[i]['first_name'],
        lastName: maps[i]['last_name'],
        employeeId: maps[i]['employee_id'],
        email: maps[i]['email'],
        designation: maps[i]['designation'],
        status: maps[i]['status'],
        phoneNumber: maps[i]['phone_number'],
        departmentId: maps[i]['department_id'],
        departmentName: maps[i]['department_name'],
        joinDate: maps[i]['join_date'] != null
            ? DateTime.parse(maps[i]['join_date'])
            : null,
        workType: maps[i]['work_type'],
      );
    });
  }

  Future<List<Employee>> _getDemoEmployeesByDesignation(
    String designation,
  ) async {
    final db = await EmployeeDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'designation = ?',
      whereArgs: [designation],
    );

    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'],
        firstName: maps[i]['first_name'],
        lastName: maps[i]['last_name'],
        employeeId: maps[i]['employee_id'],
        email: maps[i]['email'],
        designation: maps[i]['designation'],
        status: maps[i]['status'],
        phoneNumber: maps[i]['phone_number'],
        departmentId: maps[i]['department_id'],
        departmentName: maps[i]['department_name'],
        joinDate: maps[i]['join_date'] != null
            ? DateTime.parse(maps[i]['join_date'])
            : null,
        workType: maps[i]['work_type'],
      );
    });
  }

  Future<List<Employee>> _getDemoEmployeesByStatus(String status) async {
    final db = await EmployeeDatabase.instance.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'employees',
      where: 'status = ?',
      whereArgs: [status.toUpperCase()],
    );

    return List.generate(maps.length, (i) {
      return Employee(
        id: maps[i]['id'],
        firstName: maps[i]['first_name'],
        lastName: maps[i]['last_name'],
        employeeId: maps[i]['employee_id'],
        email: maps[i]['email'],
        designation: maps[i]['designation'],
        status: maps[i]['status'],
        phoneNumber: maps[i]['phone_number'],
        departmentId: maps[i]['department_id'],
        departmentName: maps[i]['department_name'],
        joinDate: maps[i]['join_date'] != null
            ? DateTime.parse(maps[i]['join_date'])
            : null,
        workType: maps[i]['work_type'],
      );
    });
  }
}
