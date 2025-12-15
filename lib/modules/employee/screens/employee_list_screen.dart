// lib/modules/employee/screens/employee_list_screen.dart
import 'package:flutter/material.dart';
import 'package:hr_system/modules/employee/screens/employee_detail_screen.dart';
import 'package:provider/provider.dart';
import '../services/employee_service.dart';
import '../models/employee.dart';
import '../widgets/employee_card.dart';
import '../../../services/auth_service.dart';

class EmployeeListScreen extends StatefulWidget {
  const EmployeeListScreen({Key? key}) : super(key: key);

  @override
  _EmployeeListScreenState createState() => _EmployeeListScreenState();
}

class _EmployeeListScreenState extends State<EmployeeListScreen> {
  final EmployeeService _employeeService = EmployeeService();
  List<Employee> _employees = [];
  List<Employee> _filteredEmployees = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    _loadEmployees();
  }

  Future<void> _loadEmployees() async {
    setState(() => _isLoading = true);
    try {
      final employees = await _employeeService.getEmployees();
      setState(() {
        _employees = employees;
        _filteredEmployees = employees;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading employees: $e')));
    }
  }

  void _searchEmployees(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredEmployees = _employees;
      } else {
        _filteredEmployees = _employees.where((employee) {
          return employee.fullName.toLowerCase().contains(
                query.toLowerCase(),
              ) ||
              employee.email.toLowerCase().contains(query.toLowerCase()) ||
              employee.employeeId.toLowerCase().contains(query.toLowerCase()) ||
              employee.designation.toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  void _filterEmployees(String filter) {
    setState(() {
      _selectedFilter = filter;
      switch (filter) {
        case 'Active':
          _filteredEmployees = _employees.where((e) => e.isActive).toList();
          break;
        case 'Inactive':
          _filteredEmployees = _employees.where((e) => !e.isActive).toList();
          break;
        case 'Manager':
          _filteredEmployees = _employees
              .where((e) => e.designation.toLowerCase().contains('manager'))
              .toList();
          break;
        case 'Staff':
          _filteredEmployees = _employees
              .where((e) => !e.designation.toLowerCase().contains('manager'))
              .toList();
          break;
        default:
          _filteredEmployees = _employees;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDemoMode = AuthService.isDemoMode;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Employees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadEmployees,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode Indicator
          Container(
            padding: const EdgeInsets.all(8),
            color: isDemoMode ? Colors.amber[100] : Colors.green[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isDemoMode ? Icons.storage : Icons.cloud,
                  color: isDemoMode ? Colors.amber[800] : Colors.green[800],
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  isDemoMode ? 'Demo Mode' : 'Live Mode',
                  style: TextStyle(
                    color: isDemoMode ? Colors.amber[800] : Colors.green[800],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search employees...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onChanged: _searchEmployees,
            ),
          ),

          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All', 'Active', 'Inactive', 'Manager', 'Staff']
                  .map(
                    (filter) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: FilterChip(
                        label: Text(filter),
                        selected: _selectedFilter == filter,
                        onSelected: (selected) => _filterEmployees(filter),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Employee Count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total: ${_filteredEmployees.length} employees',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                if (_searchQuery.isNotEmpty)
                  Text(
                    'Search: "$_searchQuery"',
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // Employee List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredEmployees.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.people, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No employees found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadEmployees,
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _filteredEmployees.length,
                      itemBuilder: (context, index) {
                        final employee = _filteredEmployees[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12.0),
                          child: EmployeeCard(
                            employee: employee,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeDetailScreen(
                                    employeeId: employee.id!,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
