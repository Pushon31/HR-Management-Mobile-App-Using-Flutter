// lib/modules/user/widgets/role_chip.dart
import 'package:flutter/material.dart';

class RoleChip extends StatelessWidget {
  final String role;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool showRemove;
  final VoidCallback? onRemove;

  const RoleChip({
    Key? key,
    required this.role,
    this.isSelected = false,
    this.onTap,
    this.showRemove = false,
    this.onRemove,
  }) : super(key: key);

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

  String _getRoleDisplay(String role) {
    return role.replaceAll('ROLE_', '').replaceAll('_', ' ');
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? _getRoleColor(role).withOpacity(0.2)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? _getRoleColor(role) : Colors.grey[300]!,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Icon(Icons.check_circle, size: 14, color: _getRoleColor(role)),
            SizedBox(width: isSelected ? 4 : 0),
            Text(
              _getRoleDisplay(role),
              style: TextStyle(
                color: isSelected ? _getRoleColor(role) : Colors.grey[700],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
            if (showRemove && onRemove != null) ...[
              SizedBox(width: 4),
              GestureDetector(
                onTap: onRemove,
                child: Icon(Icons.close, size: 14, color: Colors.grey[500]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
