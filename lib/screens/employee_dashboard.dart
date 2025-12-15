// lib/screens/employee_dashboard.dart
import 'package:flutter/material.dart';
import '../Model/user.dart';

class EmployeeDashboard extends StatelessWidget {
  final User user;

  const EmployeeDashboard({Key? key, required this.user}) : super(key: key);

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
              // Welcome Card
              Container(
                padding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.blue[400]!, Colors.blue[700]!],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 30,
                      child: Icon(Icons.person, size: 30, color: Colors.blue),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.fullName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              SizedBox(height: 12),

              GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(), // ✅ Add this
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: [
                  _buildEmployeeAction(
                    icon: Icons.access_time,
                    label: 'Attendance',
                    color: Colors.blue,
                  ),
                  _buildEmployeeAction(
                    icon: Icons.request_quote,
                    label: 'Leave',
                    color: Colors.green,
                  ),
                  _buildEmployeeAction(
                    icon: Icons.payment,
                    label: 'Salary',
                    color: Colors.purple,
                  ),
                  _buildEmployeeAction(
                    icon: Icons.task,
                    label: 'Tasks',
                    color: Colors.orange,
                  ),
                  _buildEmployeeAction(
                    icon: Icons.event_note,
                    label: 'Schedule',
                    color: Colors.red,
                  ),
                  _buildEmployeeAction(
                    icon: Icons.description,
                    label: 'Documents',
                    color: Colors.teal,
                  ),
                ],
              ),

              SizedBox(height: 24),

              // Today's Information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.today, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            "Today's Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTodayInfo('Check-in', '09:00 AM', Colors.green),
                          _buildTodayInfo('Check-out', '06:00 PM', Colors.red),
                          _buildTodayInfo('Work Hours', '9h 0m', Colors.blue),
                        ],
                      ),
                      SizedBox(height: 16),
                      Divider(),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildTodayInfo('Tasks', '5/8', Colors.orange),
                          _buildTodayInfo('Meetings', '2', Colors.purple),
                          _buildTodayInfo('Leaves', '0', Colors.teal),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Upcoming Events
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.event, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'Upcoming Events',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      _buildEventItem(
                        'Team Meeting',
                        'Today, 2:00 PM',
                        Icons.meeting_room,
                      ),
                      _buildEventItem(
                        'Project Deadline',
                        'Tomorrow',
                        Icons.event_note,
                      ),
                      _buildEventItem(
                        'Training Session',
                        'Dec 20, 10:00 AM',
                        Icons.school,
                      ),
                      _buildEventItem(
                        'Performance Review',
                        'Dec 22',
                        Icons.assessment,
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 24),

              // Quick Links
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.link, color: Colors.blue),
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
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          _buildQuickLink('Company Policy', Icons.policy),
                          _buildQuickLink('HR Portal', Icons.people),
                          _buildQuickLink('IT Support', Icons.support_agent),
                          _buildQuickLink('Feedback', Icons.feedback),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20), // ✅ Add extra space at bottom
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeAction({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
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
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildTodayInfo(String title, String value, Color color) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildEventItem(String event, String time, IconData icon) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.blue, size: 20),
      ),
      title: Text(event, style: TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(time, style: TextStyle(color: Colors.grey)),
      trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }

  Widget _buildQuickLink(String title, IconData icon) {
    return Container(
      width: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
