// lib/modules/employee/screens/employee_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hr_system/modules/employee/screens/edit_employee_screen.dart';
import '../services/employee_service.dart';
import '../models/employee.dart';

class EmployeeDetailScreen extends StatefulWidget {
  final int employeeId;

  const EmployeeDetailScreen({Key? key, required this.employeeId})
    : super(key: key);

  @override
  _EmployeeDetailScreenState createState() => _EmployeeDetailScreenState();
}

class _EmployeeDetailScreenState extends State<EmployeeDetailScreen> {
  final EmployeeService _employeeService = EmployeeService();
  Employee? _employee;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmployee();
  }

  Future<void> _loadEmployee() async {
    try {
      final employee = await _employeeService.getEmployeeById(
        widget.employeeId,
      );
      setState(() {
        _employee = employee;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading employee: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employee Details'),
        actions: [
          if (_employee != null)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditEmployeeScreen(employee: _employee!),
                  ),
                ).then((_) => _loadEmployee());
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _employee == null
          ? const Center(child: Text('Employee not found'))
          : _buildEmployeeDetails(),
    );
  }

  Widget _buildEmployeeDetails() {
    final employee = _employee!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        employee.firstName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          employee.fullName,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          employee.designation,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          employee.employeeId,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Basic Information
          _buildSection(
            title: 'Basic Information',
            children: [
              _buildDetailRow('Email', employee.email),
              if (employee.phoneNumber != null)
                _buildDetailRow('Phone', employee.phoneNumber!),
              if (employee.birthDate != null)
                _buildDetailRow(
                  'Date of Birth',
                  '${employee.birthDate!.day}/${employee.birthDate!.month}/${employee.birthDate!.year}',
                ),
              if (employee.gender != null)
                _buildDetailRow('Gender', employee.gender!),
              if (employee.maritalStatus != null)
                _buildDetailRow('Marital Status', employee.maritalStatus!),
            ],
          ),

          const SizedBox(height: 20),

          // Employment Details
          _buildSection(
            title: 'Employment Details',
            children: [
              if (employee.departmentName != null)
                _buildDetailRow('Department', employee.departmentName!),
              _buildDetailRow('Designation', employee.designation),
              if (employee.employeeType != null)
                _buildDetailRow('Employee Type', employee.employeeType!),
              if (employee.shift != null)
                _buildDetailRow('Shift', employee.shift!),
              if (employee.joinDate != null)
                _buildDetailRow(
                  'Join Date',
                  '${employee.joinDate!.day}/${employee.joinDate!.month}/${employee.joinDate!.year}',
                ),
              if (employee.workType != null)
                _buildDetailRow('Work Type', employee.workType!),
              _buildDetailRow('Status', employee.status),
            ],
          ),

          const SizedBox(height: 20),

          // Contact Information
          if (employee.address != null || employee.emergencyContact != null)
            _buildSection(
              title: 'Contact Information',
              children: [
                if (employee.address != null)
                  _buildDetailRow('Address', employee.address!),
                if (employee.emergencyContact != null)
                  _buildDetailRow(
                    'Emergency Contact',
                    employee.emergencyContact!,
                  ),
              ],
            ),

          const SizedBox(height: 20),

          // Financial Information
          if (employee.basicSalary != null ||
              employee.bankAccountNumber != null)
            _buildSection(
              title: 'Financial Information',
              children: [
                if (employee.basicSalary != null)
                  _buildDetailRow(
                    'Basic Salary',
                    '৳${employee.basicSalary!.toStringAsFixed(2)}',
                  ),
                if (employee.bankAccountNumber != null)
                  _buildDetailRow('Bank Account', employee.bankAccountNumber!),
                if (employee.nidNumber != null)
                  _buildDetailRow('NID Number', employee.nidNumber!),
              ],
            ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
