// lib/modules/user/widgets/user_status_badge.dart
import 'package:flutter/material.dart';

class UserStatusBadge extends StatelessWidget {
  final bool isActive;
  final bool showText;
  final double size;

  const UserStatusBadge({
    Key? key,
    required this.isActive,
    this.showText = true,
    this.size = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: showText
          ? EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : EdgeInsets.zero,
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.1)
            : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(showText ? 12 : size / 2),
        border: Border.all(
          color: isActive ? Colors.green : Colors.red,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? Colors.green : Colors.red,
            ),
            child: Center(
              child: Icon(
                isActive ? Icons.check : Icons.close,
                size: size * 0.6,
                color: Colors.white,
              ),
            ),
          ),
          if (showText) ...[
            SizedBox(width: 6),
            Text(
              isActive ? 'Active' : 'Inactive',
              style: TextStyle(
                fontSize: 12,
                color: isActive ? Colors.green : Colors.red,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
