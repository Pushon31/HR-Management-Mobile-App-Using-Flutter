// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../Model/login_request.dart';
import '../screens/home_screen.dart';
import '../screens/admin_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _isDemoMode = false;
  bool _obscurePassword = true;
  bool _showDemoUsers = false;

  // Demo credentials for quick login (matching your backend roles)
  final List<Map<String, dynamic>> demoUsers = [
    {
      'username': 'admin',
      'password': 'admin123',
      'role': 'Admin',
      'roleType': 'ROLE_ADMIN',
      'color': Colors.red,
    },
    {
      'username': 'manager',
      'password': 'manager123',
      'role': 'Manager',
      'roleType': 'ROLE_MANAGER',
      'color': Colors.blue,
    },
    {
      'username': 'hr',
      'password': 'hr123',
      'role': 'HR Manager',
      'roleType': 'ROLE_HR',
      'color': Colors.purple,
    },
    {
      'username': 'accountant',
      'password': 'accountant123',
      'role': 'Accountant',
      'roleType': 'ROLE_ACCOUNTANT',
      'color': Colors.green,
    },
    {
      'username': 'employee',
      'password': 'employee123',
      'role': 'Employee',
      'roleType': 'ROLE_EMPLOYEE',
      'color': Colors.orange,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadCurrentMode();
    _checkAutoLogin();
  }

  Future<void> _loadCurrentMode() async {
    final mode = await AuthService.getCurrentMode();
    setState(() {
      _isDemoMode = mode;
    });
  }

  Future<void> _checkAutoLogin() async {
    final isLoggedIn = await AuthService.isLoggedIn();
    if (isLoggedIn) {
      _navigateToHome();
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    // Hide keyboard
    FocusScope.of(context).unfocus();

    setState(() => _isLoading = true);

    // Set mode in AuthService
    AuthService.toggleMode(_isDemoMode);

    final authService = AuthService();
    final response = await authService.login(
      LoginRequest(
        username: _usernameController.text.trim(),
        password: _passwordController.text,
      ),
    );

    setState(() => _isLoading = false);

    if (response.success) {
      // Navigate to appropriate screen based on role
      _navigateToHome();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(response.message),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => HomeScreen()),
    );
  }

  void _fillDemoCredentials(String username, String password) {
    _usernameController.text = username;
    _passwordController.text = password;
    setState(() {});
  }

  Widget _buildRoleChip(String role, Color color) {
    return Chip(
      label: Text(role, style: TextStyle(color: Colors.white, fontSize: 12)),
      backgroundColor: color,
      side: BorderSide.none,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Section
              SizedBox(height: 40),
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.business_center,
                      size: 80,
                      color: Colors.blue[700],
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Garment Management',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Login to your account',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 30),

              // Mode Toggle Card
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Connection Mode',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                _isDemoMode ? 'Local Demo' : 'Live Server',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _isDemoMode,
                            onChanged: (value) {
                              setState(() {
                                _isDemoMode = value;
                              });
                            },
                            activeColor: Colors.blue,
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: _isDemoMode
                              ? Colors.amber[50]
                              : Colors.green[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isDemoMode ? Colors.amber : Colors.green,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _isDemoMode ? Icons.storage : Icons.cloud,
                              color: _isDemoMode
                                  ? Colors.amber[700]
                                  : Colors.green[700],
                              size: 20,
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _isDemoMode
                                    ? 'Using SQLite Database (Offline)'
                                    : 'Connecting to Live Backend',
                                style: TextStyle(
                                  fontSize: 13,
                                  color: _isDemoMode
                                      ? Colors.amber[800]
                                      : Colors.green[800],
                                  fontWeight: FontWeight.w500,
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

              SizedBox(height: 30),

              // Login Form Card
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Username Field
                        TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            labelText: 'Username',
                            prefixIcon: Icon(Icons.person_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter username';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 20),

                        // Password Field
                        TextFormField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'Password',
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey[600],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Colors.blue),
                            ),
                            filled: true,
                            fillColor: Colors.grey[50],
                          ),
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

                        SizedBox(height: 30),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 55,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[700],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                              shadowColor: Colors.blue.withOpacity(0.3),
                            ),
                            child: _isLoading
                                ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation(
                                            Colors.white,
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text('Authenticating...'),
                                    ],
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.login, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'LOGIN',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        SizedBox(height: 20),

                        // Demo Users Toggle
                        if (_isDemoMode)
                          Column(
                            children: [
                              Divider(),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Demo Users',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _showDemoUsers
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _showDemoUsers = !_showDemoUsers;
                                      });
                                    },
                                  ),
                                ],
                              ),
                              if (_showDemoUsers)
                                ...demoUsers.map((user) {
                                  return Card(
                                    margin: EdgeInsets.symmetric(vertical: 5),
                                    elevation: 1,
                                    child: ListTile(
                                      leading: CircleAvatar(
                                        backgroundColor: user['color'],
                                        child: Text(
                                          user['role'][0],
                                          style: TextStyle(color: Colors.white),
                                        ),
                                      ),
                                      title: Text(
                                        '${user['role']}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      subtitle: Text(
                                        'Username: ${user['username']}',
                                      ),
                                      trailing: ElevatedButton(
                                        onPressed: () {
                                          _fillDemoCredentials(
                                            user['username'],
                                            user['password'],
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue[50],
                                          foregroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                        ),
                                        child: Text('Use'),
                                      ),
                                    ),
                                  );
                                }).toList(),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 30),

              // Demo Users Quick Login Chips
              if (_isDemoMode && !_showDemoUsers)
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: demoUsers.map((user) {
                    return FilterChip(
                      label: Text(user['role']),
                      avatar: CircleAvatar(
                        backgroundColor: Colors.white,
                        radius: 12,
                        child: Text(
                          user['role'][0],
                          style: TextStyle(fontSize: 12, color: user['color']),
                        ),
                      ),
                      backgroundColor: user['color'].withOpacity(0.1),
                      selectedColor: user['color'].withOpacity(0.2),
                      selected: false,
                      onSelected: (selected) {
                        _fillDemoCredentials(
                          user['username'],
                          user['password'],
                        );
                      },
                      labelStyle: TextStyle(
                        color: user['color'],
                        fontWeight: FontWeight.w500,
                      ),
                      shape: StadiumBorder(
                        side: BorderSide(color: user['color'].withOpacity(0.3)),
                      ),
                    );
                  }).toList(),
                ),

              SizedBox(height: 40),

              // Info Text
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue, size: 20),
                        SizedBox(width: 10),
                        Text(
                          'Connection Information',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text(
                      _isDemoMode
                          ? '• Demo Mode: Using local SQLite database\n• No internet connection required\n• Data is stored locally on your device'
                          : '• Live Mode: Connecting to cloud server\n• Internet connection required\n• Real-time data synchronization',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
