// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../Model/user.dart';
import './admin_dashboard.dart';
import './manager_dashboard.dart';
import './employee_dashboard.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User? _currentUser;
  bool _isDemoMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final user = await AuthService.getCurrentUser();
    final mode = await AuthService.getCurrentMode();

    setState(() {
      _currentUser = user;
      _isDemoMode = mode;
      _isLoading = false;
    });
  }

  Widget _buildDashboard() {
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 60, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'No user data available',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              child: Text('Go to Login'),
            ),
          ],
        ),
      );
    }

    if (_currentUser!.isAdmin) {
      return AdminDashboard(user: _currentUser!);
    } else if (_currentUser!.isManager) {
      return ManagerDashboard(user: _currentUser!);
    } else if (_currentUser!.isHR) {
      return HRDashboard(user: _currentUser!);
    } else if (_currentUser!.isAccountant) {
      return AccountantDashboard(user: _currentUser!);
    } else {
      return EmployeeDashboard(user: _currentUser!);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20),
              Text('Loading dashboard...'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Garment Management'),
        backgroundColor: Colors.blue[700],
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              bool confirm = await showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text('Logout'),
                  content: Text('Are you sure you want to logout?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await AuthService.logout();
                Navigator.pushReplacementNamed(context, '/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // User Info Card
          Card(
            margin: EdgeInsets.all(16),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: Colors.blue[100],
                        radius: 30,
                        child: Icon(Icons.person, size: 30, color: Colors.blue),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentUser?.fullName ?? 'User',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Chip(
                              label: Text(
                                _currentUser?.roleDisplay ?? 'User',
                                style: TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Colors.blue,
                            ),
                            SizedBox(height: 4),
                            Text(
                              _currentUser?.email ?? '',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _isDemoMode ? Colors.amber[50] : Colors.green[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isDemoMode ? Colors.amber : Colors.green,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _isDemoMode ? Icons.storage : Icons.cloud,
                          color: _isDemoMode ? Colors.amber : Colors.green,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _isDemoMode
                                ? 'Demo Mode (Local Database)'
                                : 'Live Mode (Cloud Connected)',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: _isDemoMode
                                  ? Colors.amber[800]
                                  : Colors.green[800],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Dashboard - Use Expanded properly
          Expanded(child: _buildDashboard()),
        ],
      ),
    );
  }
}
