// lib/modules/user/screens/add_user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/user_service.dart';
import '../../../../Model/user.dart';

class AddUserScreen extends StatefulWidget {
  const AddUserScreen({Key? key}) : super(key: key);

  @override
  _AddUserScreenState createState() => _AddUserScreenState();
}

class _AddUserScreenState extends State<AddUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Form controllers
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Form state
  bool _isLoading = false;
  bool _isActive = true;
  bool _autoCreateEmployee = true; // ✅ NEW: Auto-create employee option
  List<String> _selectedRoles = ['ROLE_EMPLOYEE'];

  // Available roles
  final List<String> _availableRoles = [
    'ROLE_ADMIN',
    'ROLE_MANAGER',
    'ROLE_HR',
    'ROLE_ACCOUNTANT',
    'ROLE_EMPLOYEE',
  ];

  // Employee roles
  final List<String> _employeeRoles = [
    'ROLE_EMPLOYEE',
    'ROLE_MANAGER',
    'ROLE_HR',
    'ROLE_ACCOUNTANT',
  ];

  // Error message
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadDemoMode();
  }

  Future<void> _loadDemoMode() async {
    final isDemoMode = await UserService.getCurrentMode();
    UserService.toggleMode(isDemoMode);
  }

  bool _validatePasswords() {
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return false;
    }

    if (_passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
      });
      return false;
    }

    return true;
  }

  // ✅ NEW: Check if user has employee roles
  bool get _hasEmployeeRole {
    return _selectedRoles.any((role) => _employeeRoles.contains(role));
  }

  // ✅ NEW: Get designation based on roles
  String get _designationFromRoles {
    if (_selectedRoles.contains('ROLE_MANAGER')) return 'Manager';
    if (_selectedRoles.contains('ROLE_HR')) return 'HR Manager';
    if (_selectedRoles.contains('ROLE_ACCOUNTANT')) return 'Accountant';
    return 'Employee';
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_validatePasswords()) {
      return;
    }

    if (_selectedRoles.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one role';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final userData = {
        'username': _usernameController.text.trim(),
        'email': _emailController.text.trim(),
        'fullName': _fullNameController.text.trim(),
        'password': _passwordController.text,
        'roles': _selectedRoles,
        'isActive': _isActive,
      };

      User newUser;

      // ✅ Check if user has employee role and auto-create option is enabled
      if (_hasEmployeeRole && _autoCreateEmployee) {
        // Show confirmation dialog
        final shouldProceed =
            await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: Text('Create Employee Profile'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('This user will have:'),
                    SizedBox(height: 8),
                    Text(
                      '• Role: ${_selectedRoles.map((r) => r.replaceAll('ROLE_', '')).join(', ')}',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    Text(
                      '• Designation: $_designationFromRoles',
                      style: TextStyle(fontWeight: FontWeight.w500),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Do you want to automatically create an employee profile?',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text('Skip'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text('Create Employee'),
                  ),
                ],
              ),
            ) ??
            false;

        if (shouldProceed) {
          // Create user with employee
          newUser = await _userService.createUserWithEmployee(
            userData,
            context: context,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '✅ User created successfully! Employee profile created with designation: $_designationFromRoles',
              ),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 5),
            ),
          );
        } else {
          // Create user only
          newUser = await _userService.createUser(
            userData,
            context: context,
            autoCreateEmployee: false,
          );

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'User created! Remember to create employee profile later.',
              ),
              backgroundColor: Colors.blue,
            ),
          );
        }
      } else if (_hasEmployeeRole && !_autoCreateEmployee) {
        // User has employee role but auto-create is disabled
        newUser = await _userService.createUser(
          userData,
          context: context,
          autoCreateEmployee: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User created! Employee profile was not created.'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        // User doesn't have employee role
        newUser = await _userService.createUser(
          userData,
          context: context,
          autoCreateEmployee: false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('User created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }

      // Navigate back with result
      Navigator.pop(context, newUser);
    } catch (e) {
      print('❌ Error creating user: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to create user: ${e.toString().replaceAll('Exception: ', '')}',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _toggleRole(String role) {
    setState(() {
      if (_selectedRoles.contains(role)) {
        _selectedRoles.remove(role);
      } else {
        _selectedRoles.add(role);
      }
    });
  }

  String _getRoleDisplayName(String role) {
    return role.replaceAll('ROLE_', '').replaceAll('_', ' ');
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'ROLE_ADMIN':
        return Colors.red;
      case 'ROLE_MANAGER':
        return Colors.blue;
      case 'ROLE_HR':
        return Colors.purple;
      case 'ROLE_ACCOUNTANT':
        return Colors.green;
      case 'ROLE_EMPLOYEE':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add New User'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
            tooltip: 'Save User',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error message
                    if (_errorMessage.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.red[700]),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                        hintText: 'Enter username',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter username';
                        }
                        if (value.length < 3) {
                          return 'Username must be at least 3 characters';
                        }
                        return null;
                      },
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                          RegExp(r'[a-zA-Z0-9_]'),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Email field
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        hintText: 'Enter email address',
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter email';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                          return 'Please enter a valid email';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Full Name field
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Enter full name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Password field
                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        hintText: 'Enter password (min 6 characters)',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Confirm Password field
                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                        hintText: 'Confirm your password',
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please confirm password';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Role Selection
                    Text(
                      'Select Roles',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: 8),

                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableRoles.map((role) {
                        final isSelected = _selectedRoles.contains(role);
                        return FilterChip(
                          label: Text(_getRoleDisplayName(role)),
                          selected: isSelected,
                          onSelected: (_) => _toggleRole(role),
                          backgroundColor: isSelected
                              ? _getRoleColor(role).withOpacity(0.2)
                              : Colors.grey[100],
                          selectedColor: _getRoleColor(role).withOpacity(0.3),
                          checkmarkColor: _getRoleColor(role),
                          labelStyle: TextStyle(
                            color: isSelected
                                ? _getRoleColor(role)
                                : Colors.grey[700],
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                          shape: StadiumBorder(
                            side: BorderSide(
                              color: isSelected
                                  ? _getRoleColor(role)
                                  : Colors.grey[300]!,
                              width: 1,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // ✅ NEW: Auto-create Employee Option
                    if (_hasEmployeeRole)
                      Card(
                        color: Colors.orange[50],
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.badge, color: Colors.orange),
                                  SizedBox(width: 8),
                                  Text(
                                    'Employee Profile',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[800],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Text(
                                'This user has employee-related roles. You can automatically create an employee profile.',
                                style: TextStyle(color: Colors.orange[700]),
                              ),
                              SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(
                                    _autoCreateEmployee
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    color: _autoCreateEmployee
                                        ? Colors.green
                                        : Colors.grey,
                                  ),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Auto-create Employee Profile',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        Text(
                                          'Designation: $_designationFromRoles',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Switch(
                                    value: _autoCreateEmployee,
                                    onChanged: (value) {
                                      setState(() {
                                        _autoCreateEmployee = value;
                                      });
                                    },
                                    activeColor: Colors.green,
                                  ),
                                ],
                              ),
                              if (_autoCreateEmployee)
                                Padding(
                                  padding: EdgeInsets.only(top: 8),
                                  child: Text(
                                    '✓ Employee ID will be auto-generated\n'
                                    '✓ Status will be set to ACTIVE\n'
                                    '✓ Work Type: ONSITE\n'
                                    '✓ Employee Type: FULL_TIME',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.green[700],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(height: 16),

                    // Status Toggle
                    Row(
                      children: [
                        Icon(
                          _isActive ? Icons.toggle_on : Icons.toggle_off,
                          color: _isActive ? Colors.green : Colors.red,
                          size: 40,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Account Status',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                _isActive
                                    ? 'User will be able to login immediately'
                                    : 'User account will be inactive',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: _isActive,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                          activeColor: Colors.green,
                        ),
                      ],
                    ),
                    SizedBox(height: 32),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.person_add, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              _hasEmployeeRole && _autoCreateEmployee
                                  ? 'Create User with Employee'
                                  : 'Create User',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 16),

                    // Info Card
                    Card(
                      color: Colors.blue[50],
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User Creation Note',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue[800],
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'User will receive login credentials. '
                                    'Employee profiles can be created later if skipped.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.blue[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // ✅ NEW: Quick Tips
                    SizedBox(height: 16),
                    Card(
                      color: Colors.grey[50],
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick Tips:',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            SizedBox(height: 8),
                            _buildTipItem(
                              'Admin Role',
                              'Can access all system features',
                              Colors.red,
                            ),
                            _buildTipItem(
                              'Manager Role',
                              'Can manage employees and view reports',
                              Colors.blue,
                            ),
                            _buildTipItem(
                              'Employee Role',
                              'Basic system access, requires employee profile',
                              Colors.orange,
                            ),
                            _buildTipItem(
                              'HR & Accountant',
                              'Specialized roles with specific permissions',
                              Colors.purple,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTipItem(String title, String description, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: EdgeInsets.only(top: 6, right: 8),
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                ),
                Text(
                  description,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
