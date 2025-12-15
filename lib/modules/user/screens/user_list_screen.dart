// lib/screens/user_list_screen.dart
import 'package:flutter/material.dart';
import 'package:hr_system/modules/user/screens/add_user_screen.dart';
import 'package:hr_system/modules/user/screens/edit_user_screen.dart';
import 'package:hr_system/modules/user/screens/user_detail_screen.dart';
import '../../../services/user_service.dart';
import '../../../widgets/user_card.dart';
import '../../../Model/user.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({Key? key}) : super(key: key);

  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final UserService _userService = UserService();
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedRole = 'All';
  bool _showActiveOnly = false;

  final List<String> _roles = [
    'All',
    'ROLE_ADMIN',
    'ROLE_MANAGER',
    'ROLE_HR',
    'ROLE_ACCOUNTANT',
    'ROLE_EMPLOYEE',
  ];

  @override
  void initState() {
    super.initState();
    _loadUsers();
    _loadDemoMode();
  }

  Future<void> _loadDemoMode() async {
    final isDemoMode = await UserService.getCurrentMode();
    UserService.toggleMode(isDemoMode);
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error loading users: $e');
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load users: $e')));
    }
  }

  void _filterUsers() {
    List<User> filtered = _users;

    // Filter by search query
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((user) {
        return user.username.toLowerCase().contains(
              _searchQuery.toLowerCase(),
            ) ||
            user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            user.fullName.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Filter by role
    if (_selectedRole != 'All') {
      filtered = filtered.where((user) {
        return user.roles.contains(_selectedRole);
      }).toList();
    }

    // Filter by active status
    if (_showActiveOnly) {
      filtered = filtered.where((user) => user.isActive).toList();
    }

    setState(() {
      _filteredUsers = filtered;
    });
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      if (user.isActive) {
        final success = await _userService.deactivateUser(user.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User deactivated successfully')),
          );
        }
      } else {
        final success = await _userService.activateUser(user.id);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User activated successfully')),
          );
        }
      }
      await _loadUsers(); // Reload users
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update user status: $e')),
      );
    }
  }

  Future<void> _deleteUser(int userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete User'),
        content: Text(
          'Are you sure you want to delete this user? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _userService.deleteUser(userId);
        if (success) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('User deleted successfully')));
          await _loadUsers();
        }
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to delete user: $e')));
      }
    }
  }

  void _navigateToAddUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddUserScreen()),
    ).then((_) => _loadUsers());
  }

  void _navigateToUserDetails(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailScreen(userId: user.id),
      ),
    );
  }

  void _navigateToEditUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditUserScreen(user: user)),
    ).then((_) => _loadUsers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Management'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadUsers,
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: Icon(Icons.person_add),
            onPressed: _navigateToAddUser,
            tooltip: 'Add New User',
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter section
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[50],
            child: Column(
              children: [
                // Search bar
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Search users...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                    _filterUsers();
                  },
                ),
                SizedBox(height: 12),
                Row(
                  children: [
                    // Role filter dropdown
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: _selectedRole,
                        items: _roles.map((role) {
                          return DropdownMenuItem(
                            value: role,
                            child: Text(role.replaceAll('ROLE_', '')),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedRole = value!;
                          });
                          _filterUsers();
                        },
                        decoration: InputDecoration(
                          labelText: 'Role',
                          border: OutlineInputBorder(),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Active filter switch
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Active Only'),
                          SizedBox(width: 8),
                          Switch(
                            value: _showActiveOnly,
                            onChanged: (value) {
                              setState(() {
                                _showActiveOnly = value;
                              });
                              _filterUsers();
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // User count
          Container(
            padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.blue[50],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Users: ${_filteredUsers.length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[700],
                  ),
                ),
                Text(
                  'Active: ${_filteredUsers.where((u) => u.isActive).length}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.green[700],
                  ),
                ),
              ],
            ),
          ),
          // Users list
          Expanded(
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : _filteredUsers.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey[300],
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey[500],
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Try a different search term'
                              : 'Add new users to get started',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _loadUsers,
                    child: ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return UserCard(
                          user: user,
                          onTap: () => _navigateToUserDetails(user),
                          onEdit: () => _navigateToEditUser(user),
                          onDelete: () => _deleteUser(user.id),
                          onToggleStatus: () => _toggleUserStatus(user),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddUser,
        child: Icon(Icons.person_add),
        tooltip: 'Add New User',
      ),
    );
  }
}
