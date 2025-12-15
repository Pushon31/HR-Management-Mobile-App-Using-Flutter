// lib/screens/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:hr_system/modules/user/screens/user_list_screen.dart';
import '../Model/user.dart';
import '../modules/employee/screens/employee_list_screen.dart';

class AdminDashboard extends StatelessWidget {
  final User user;

  const AdminDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      size: 40,
                      color: Colors.blue[700],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Administrator Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Welcome, ${user.fullName}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Quick Stats
              Text(
                'Quick Stats',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildStatCard(
                    title: 'Total Employees',
                    value: '45',
                    icon: Icons.people,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Active Users',
                    value: '38',
                    icon: Icons.person,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Departments',
                    value: '8',
                    icon: Icons.business,
                    color: Colors.purple,
                  ),
                  _buildStatCard(
                    title: 'Today Attendance',
                    value: '42',
                    icon: Icons.access_time,
                    color: Colors.orange,
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Admin Actions
              Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildActionCard(
                    title: 'Employee Management',
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EmployeeListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'User Management',
                    icon: Icons.manage_accounts,
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserListScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Attendance',
                    icon: Icons.access_time,
                    color: Colors.purple,
                    onTap: () {
                      // Navigate to attendance
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Attendance System - Coming Soon'),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Payroll',
                    icon: Icons.payment,
                    color: Colors.orange,
                    onTap: () {
                      // Navigate to payroll
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Payroll System - Coming Soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Reports',
                    icon: Icons.analytics,
                    color: Colors.teal,
                    onTap: () {
                      // Navigate to reports
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Reports System - Coming Soon')),
                      );
                    },
                  ),
                  _buildActionCard(
                    title: 'Settings',
                    icon: Icons.settings,
                    color: Colors.red,
                    onTap: () {
                      // Navigate to settings
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('System Settings - Coming Soon'),
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Quick Links Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.dashboard, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Quick Links',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Column(
                        children: [
                          _buildQuickLink(
                            context,
                            'Employee Management',
                            Icons.people,
                            Colors.blue,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => EmployeeListScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickLink(
                            context,
                            'User Management',
                            Icons.people,
                            Colors.blue,
                            () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserListScreen(),
                                ),
                              );
                            },
                          ),
                          _buildQuickLink(
                            context,
                            'Attendance Report',
                            Icons.bar_chart,
                            Colors.purple,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Reports - Coming Soon'),
                                ),
                              );
                            },
                          ),
                          _buildQuickLink(
                            context,
                            'System Settings',
                            Icons.settings,
                            Colors.orange,
                            () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Settings - Coming Soon'),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Recent Activity
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.history, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Recent Activity',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          TextButton(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('View All Activity')),
                              );
                            },
                            child: Text('View All'),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildActivityItem(
                        'Employee Management Module Added',
                        'Just now',
                        Icons.people,
                      ),
                      _buildActivityItem(
                        'User login successful',
                        '5 minutes ago',
                        Icons.login,
                      ),
                      _buildActivityItem(
                        'System backup completed',
                        'Today, 2:00 AM',
                        Icons.backup,
                      ),
                      _buildActivityItem(
                        'New employee registered',
                        'Yesterday',
                        Icons.person_add,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // System Status
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.monitor_heart, color: Colors.green),
                          SizedBox(width: 8),
                          Text(
                            'System Status',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          _buildStatusIndicator('Backend', Colors.green),
                          SizedBox(width: 16),
                          _buildStatusIndicator('Database', Colors.green),
                          SizedBox(width: 16),
                          _buildStatusIndicator('API', Colors.green),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        'All systems operational',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w500,
                        ),
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

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 32, color: color),
              SizedBox(height: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title),
      trailing: Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildActivityItem(String activity, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: Colors.blue),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(activity, style: TextStyle(fontSize: 14)),
                SizedBox(height: 2),
                Text(time, style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIndicator(String label, Color color) {
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color),
          ),
          child: Center(child: Icon(Icons.check, color: color, size: 20)),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 12)),
      ],
    );
  }
}
