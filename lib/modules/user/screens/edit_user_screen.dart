// lib/modules/user/screens/edit_user_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../services/user_service.dart';
import '../../../../Model/user.dart';

class EditUserScreen extends StatefulWidget {
  final User user;

  const EditUserScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();

  // Form controllers
  late TextEditingController _usernameController;
  late TextEditingController _emailController;
  late TextEditingController _fullNameController;
  late TextEditingController _passwordController;

  // Form state
  bool _isLoading = false;
  bool _isActive = true;
  List<String> _selectedRoles = [];
  bool _changePassword = false;

  // Available roles
  final List<String> _availableRoles = [
    'ROLE_ADMIN',
    'ROLE_MANAGER',
    'ROLE_HR',
    'ROLE_ACCOUNTANT',
    'ROLE_EMPLOYEE',
  ];

  // Error message
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();

    // Initialize controllers with user data
    _usernameController = TextEditingController(text: widget.user.username);
    _emailController = TextEditingController(text: widget.user.email);
    _fullNameController = TextEditingController(text: widget.user.fullName);
    _passwordController = TextEditingController();

    _isActive = widget.user.isActive;
    _selectedRoles = List.from(widget.user.roles);

    _loadDemoMode();
  }

  Future<void> _loadDemoMode() async {
    final isDemoMode = await UserService.getCurrentMode();
    UserService.toggleMode(isDemoMode);
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedRoles.isEmpty) {
      setState(() {
        _errorMessage = 'Please select at least one role';
      });
      return;
    }

    if (_changePassword && _passwordController.text.length < 6) {
      setState(() {
        _errorMessage = 'Password must be at least 6 characters';
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
        'roles': _selectedRoles,
        'isActive': _isActive,
      };

      // Only include password if changed
      if (_changePassword && _passwordController.text.isNotEmpty) {
        userData['password'] = _passwordController.text;
      }

      final updatedUser = await _userService.updateUser(
        widget.user.id,
        userData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('User updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back with result
      Navigator.pop(context, updatedUser);
    } catch (e) {
      print('❌ Error updating user: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update user: ${e.toString().replaceAll('Exception: ', '')}',
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

  Future<void> _createEmployeeForUser() async {
    // TODO: Implement create employee for user
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Create Employee feature coming soon'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _fullNameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _submitForm,
            tooltip: 'Save Changes',
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

                    // User ID Info
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.blue[100],
                              child: Text(
                                widget.user.fullName.isNotEmpty
                                    ? widget.user.fullName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                            SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'User ID: ${widget.user.id}',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    'Created: ${widget.user.roleDisplay}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Username field
                    TextFormField(
                      controller: _usernameController,
                      decoration: InputDecoration(
                        labelText: 'Username',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
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
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter full name';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 24),

                    // Change Password Section
                    ExpansionTile(
                      title: Text(
                        'Change Password',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      leading: Icon(Icons.lock),
                      initiallyExpanded: false,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          _changePassword = expanded;
                        });
                      },
                      children: [
                        Padding(
                          padding: EdgeInsets.all(16),
                          child: Column(
                            children: [
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'New Password',
                                  prefixIcon: Icon(Icons.lock),
                                  border: OutlineInputBorder(),
                                  hintText:
                                      'Leave blank to keep current password',
                                ),
                                obscureText: true,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Note: If you change the password, the user will need to use the new password for login.',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
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
                    SizedBox(height: 24),

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
                                    ? 'User can login to the system'
                                    : 'User account is disabled',
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

                    // Employee Section (if user doesn't have employee record)
                    if (widget.user.employeeCode == null)
                      Column(
                        children: [
                          SizedBox(height: 24),
                          Divider(),
                          SizedBox(height: 16),
                          Text(
                            'Employee Management',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey[700],
                            ),
                          ),
                          SizedBox(height: 8),
                          Card(
                            color: Colors.orange[50],
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'No Employee Record',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.orange[800],
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'This user does not have an employee record. '
                                    'You can create an employee profile for them.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.orange[700],
                                    ),
                                  ),
                                  SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    onPressed: _createEmployeeForUser,
                                    icon: Icon(Icons.badge),
                                    label: Text('Create Employee Profile'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                    SizedBox(height: 32),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _submitForm,
                            icon: Icon(Icons.save, color: Colors.white),
                            label: Text(
                              'Save Changes',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            // TODO: Implement delete user
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Delete user feature')),
                            );
                          },
                          tooltip: 'Delete User',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
