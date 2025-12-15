// lib/widgets/user_card.dart
import 'package:flutter/material.dart';
import '../Model/user.dart';

class UserCard extends StatelessWidget {
  final User user;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onToggleStatus;

  const UserCard({
    Key? key,
    required this.user,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.onToggleStatus,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Avatar with role color
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: _getRoleColor(user.roles.first),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        user.fullName.isNotEmpty
                            ? user.fullName[0].toUpperCase()
                            : 'U',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                user.fullName,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            // Status badge
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: user.isActive
                                    ? Colors.green.withOpacity(0.1)
                                    : Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: user.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                user.isActive ? 'Active' : 'Inactive',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: user.isActive
                                      ? Colors.green
                                      : Colors.red,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4),
                        Text(
                          '@${user.username}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          user.email,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12),
              // Roles chips
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: user.roles
                    .map(
                      (role) => Chip(
                        label: Text(
                          role.replaceAll('ROLE_', ''),
                          style: TextStyle(fontSize: 12),
                        ),
                        backgroundColor: _getRoleColor(role).withOpacity(0.1),
                        labelPadding: EdgeInsets.symmetric(horizontal: 8),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: 12),
              // Employee info if available
              if (user.employeeCode != null || user.designation != null) ...[
                Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.badge, size: 16, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        user.employeeCode != null
                            ? '${user.employeeCode} • ${user.designation ?? "Employee"}'
                            : user.designation ?? '',
                        style: TextStyle(fontSize: 13, color: Colors.blue[700]),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 12),
              ],
              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Toggle status button
                  IconButton(
                    icon: Icon(
                      user.isActive ? Icons.toggle_on : Icons.toggle_off,
                      color: user.isActive ? Colors.green : Colors.red,
                      size: 30,
                    ),
                    onPressed: onToggleStatus,
                    tooltip: user.isActive
                        ? 'Deactivate User'
                        : 'Activate User',
                  ),
                  // Edit button
                  IconButton(
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                    tooltip: 'Edit User',
                  ),
                  // Delete button
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
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
}
