// lib/modules/user/screens/user_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:hr_system/modules/user/screens/edit_user_screen.dart';
import 'package:intl/intl.dart';
import '../../../../services/user_service.dart';
import '../../../../Model/user.dart';

class UserDetailScreen extends StatefulWidget {
  final int userId;

  const UserDetailScreen({Key? key, required this.userId}) : super(key: key);

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final UserService _userService = UserService();

  User? _user;
  bool _isLoading = true;
  bool _isRefreshing = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUser();
    _loadDemoMode();
  }

  Future<void> _loadDemoMode() async {
    final isDemoMode = await UserService.getCurrentMode();
    UserService.toggleMode(isDemoMode);
  }

  Future<void> _loadUser() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final user = await _userService.getUserById(widget.userId);
      setState(() {
        _user = user;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading user: $e');
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshUser() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    await _loadUser();

    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> _toggleUserStatus() async {
    if (_user == null) return;

    try {
      if (_user!.isActive) {
        final success = await _userService.deactivateUser(_user!.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User deactivated successfully'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        final success = await _userService.activateUser(_user!.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('User activated successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      await _refreshUser();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update status: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _navigateToEdit() {
    if (_user != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => EditUserScreen(user: _user!)),
      ).then((_) => _refreshUser());
    }
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

  Widget _buildInfoCard(String title, String value, IconData icon) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _refreshUser,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: _navigateToEdit,
            tooltip: 'Edit User',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _user == null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'User not found',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  if (_errorMessage.isNotEmpty)
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadUser, child: Text('Retry')),
                ],
              ),
            )
          : RefreshIndicator(
              onRefresh: _refreshUser,
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Profile Header
                    Card(
                      elevation: 3,
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: _user!.isActive
                                  ? Colors.blue[100]
                                  : Colors.grey[300],
                              child: Text(
                                _user!.fullName.isNotEmpty
                                    ? _user!.fullName[0].toUpperCase()
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 32,
                                  color: _user!.isActive
                                      ? Colors.blue
                                      : Colors.grey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              _user!.fullName,
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              '@${_user!.username}',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _user!.isActive
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: _user!.isActive
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _user!.isActive
                                            ? Icons.check_circle
                                            : Icons.remove_circle,
                                        size: 14,
                                        color: _user!.isActive
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        _user!.isActive ? 'Active' : 'Inactive',
                                        style: TextStyle(
                                          color: _user!.isActive
                                              ? Colors.green
                                              : Colors.red,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'ID: ${_user!.id}',
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Contact Information
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    GridView.count(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      children: [
                        _buildInfoCard('Email', _user!.email, Icons.email),
                        _buildInfoCard(
                          'Username',
                          _user!.username,
                          Icons.person,
                        ),
                      ],
                    ),
                    SizedBox(height: 20),

                    // Roles Section
                    Text(
                      'User Roles',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _user!.roles.map((role) {
                        return Chip(
                          label: Text(
                            role.replaceAll('ROLE_', ''),
                            style: TextStyle(color: Colors.white),
                          ),
                          backgroundColor: _getRoleColor(role),
                          padding: EdgeInsets.symmetric(horizontal: 12),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 20),

                    // Employee Information (if available)
                    if (_user!.employeeCode != null ||
                        _user!.designation != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 12),
                          Card(
                            color: Colors.blue[50],
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (_user!.employeeCode != null)
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.badge,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Employee Code:',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _user!.employeeCode!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (_user!.designation != null) ...[
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.work,
                                          size: 16,
                                          color: Colors.blue,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Designation:',
                                          style: TextStyle(
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          _user!.designation!,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Colors.blue[700],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    SizedBox(height: 20),

                    // Account Actions
                    Text(
                      'Account Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: Icon(
                                _user!.isActive
                                    ? Icons.toggle_off
                                    : Icons.toggle_on,
                                color: _user!.isActive
                                    ? Colors.orange
                                    : Colors.green,
                              ),
                              title: Text(
                                _user!.isActive
                                    ? 'Deactivate User'
                                    : 'Activate User',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                _user!.isActive
                                    ? 'Prevent user from logging in'
                                    : 'Allow user to login again',
                              ),
                              trailing: Switch(
                                value: _user!.isActive,
                                onChanged: (_) => _toggleUserStatus(),
                                activeColor: Colors.green,
                              ),
                              onTap: _toggleUserStatus,
                            ),
                            Divider(),
                            ListTile(
                              leading: Icon(Icons.password, color: Colors.blue),
                              title: Text(
                                'Reset Password',
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text('Send password reset email'),
                              trailing: Icon(Icons.arrow_forward_ios, size: 16),
                              onTap: () {
                                // TODO: Implement password reset
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Password reset feature coming soon',
                                    ),
                                  ),
                                );
                              },
                            ),
                            if (_user!.employeeCode == null) ...[
                              Divider(),
                              ListTile(
                                leading: Icon(Icons.badge, color: Colors.green),
                                title: Text(
                                  'Create Employee Profile',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: Text('Link to employee management'),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                ),
                                onTap: () {
                                  // TODO: Implement create employee
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Create employee feature coming soon',
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Activity Log (Placeholder)
                    Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 12),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          children: [
                            ListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.green[100],
                                child: Icon(
                                  Icons.login,
                                  size: 16,
                                  color: Colors.green,
                                ),
                              ),
                              title: Text('Last Login'),
                              subtitle: Text('Today, 10:30 AM'),
                            ),
                            Divider(),
                            ListTile(
                              leading: CircleAvatar(
                                radius: 16,
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  Icons.edit,
                                  size: 16,
                                  color: Colors.blue,
                                ),
                              ),
                              title: Text('Profile Updated'),
                              subtitle: Text('Yesterday, 3:45 PM'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 40),
                  ],
                ),
              ),
            ),
    );
  }
}
