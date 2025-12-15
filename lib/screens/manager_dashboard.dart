// lib/screens/manager_dashboard.dart
import 'package:flutter/material.dart';
import '../Model/user.dart';

class ManagerDashboard extends StatelessWidget {
  final User user;

  const ManagerDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // ✅ Add this
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
                      Icons.manage_accounts,
                      size: 40,
                      color: Colors.blue[700],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Manager Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Team management and oversight',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 20),

              // Team Stats
              Text(
                'Team Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildTeamStatCard(
                      title: 'Team Members',
                      value: '12',
                      icon: Icons.people,
                      color: Colors.blue,
                    ),
                    SizedBox(width: 12),
                    _buildTeamStatCard(
                      title: 'Present Today',
                      value: '10',
                      icon: Icons.check_circle,
                      color: Colors.green,
                    ),
                    SizedBox(width: 12),
                    _buildTeamStatCard(
                      title: 'On Leave',
                      value: '2',
                      icon: Icons.beach_access,
                      color: Colors.orange,
                    ),
                    SizedBox(width: 12),
                    _buildTeamStatCard(
                      title: 'Pending Tasks',
                      value: '8',
                      icon: Icons.task,
                      color: Colors.red,
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Manager Actions
              Text(
                'Management Tools',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),

              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _buildManagerAction(
                    icon: Icons.calendar_today,
                    label: 'Schedule',
                    color: Colors.blue,
                  ),
                  _buildManagerAction(
                    icon: Icons.assignment,
                    label: 'Tasks',
                    color: Colors.green,
                  ),
                  _buildManagerAction(
                    icon: Icons.assessment,
                    label: 'Reports',
                    color: Colors.purple,
                  ),
                  _buildManagerAction(
                    icon: Icons.meeting_room,
                    label: 'Meetings',
                    color: Colors.orange,
                  ),
                  _buildManagerAction(
                    icon: Icons.approval,
                    label: 'Approvals',
                    color: Colors.red,
                  ),
                  _buildManagerAction(
                    icon: Icons.trending_up,
                    label: 'Performance',
                    color: Colors.teal,
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Team Members
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.group, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Team Members',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Spacer(),
                          TextButton(onPressed: () {}, child: Text('View All')),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildTeamMember(
                        'John Doe',
                        'Senior Developer',
                        Icons.engineering,
                      ),
                      _buildTeamMember(
                        'Jane Smith',
                        'UI Designer',
                        Icons.design_services,
                      ),
                      _buildTeamMember(
                        'Robert Johnson',
                        'QA Engineer',
                        Icons.bug_report,
                      ),
                      _buildTeamMember(
                        'Sarah Williams',
                        'Project Lead',
                        Icons.leaderboard,
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

  Widget _buildTeamStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      width: 140,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
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
          Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildManagerAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: color),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember(String name, String position, IconData icon) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Icon(icon, color: Colors.blue),
      ),
      title: Text(name, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(position),
      trailing: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'Active',
          style: TextStyle(color: Colors.green[800], fontSize: 12),
        ),
      ),
    );
  }
}

// HR Dashboard
class HRDashboard extends StatelessWidget {
  final User user;

  const HRDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // ✅ Add this
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.purple[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.handshake, size: 40, color: Colors.purple[700]),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HR Manager Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.purple[900],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Human Resources Management',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Icon(Icons.handshake, size: 100, color: Colors.purple),
                    SizedBox(height: 20),
                    Text(
                      'HR Management System',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to Human Resources Dashboard',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('View Employee Records'),
                    ),
                  ],
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

// Accountant Dashboard
class AccountantDashboard extends StatelessWidget {
  final User user;

  const AccountantDashboard({Key? key, required this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // ✅ Add this
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet,
                      size: 40,
                      color: Colors.green[700],
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Accountant Dashboard',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green[900],
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Financial Management & Payroll',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40),

              Center(
                child: Column(
                  children: [
                    Icon(Icons.account_balance, size: 100, color: Colors.green),
                    SizedBox(height: 20),
                    Text(
                      'Accounting System',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to Financial Dashboard',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: () {},
                      child: Text('Process Payroll'),
                    ),
                  ],
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
