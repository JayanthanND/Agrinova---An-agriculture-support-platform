import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

class ProfileWidget extends StatelessWidget {
  const ProfileWidget({
    Key? key,
    required this.title,
    required this.icon,
    required this.onPress,
    this.endIcon = true,
    this.textColor,
    this.textStyle,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final Color? textColor;
  final bool endIcon;
  final TextStyle? textStyle;
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onPress,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),
        ),
        child: Icon(icon, color: textColor ?? Colors.black),
      ),
      title: Text(
        title,
        style: textStyle,
      ),
      trailing: endIcon
          ? Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                color: Colors.grey.withOpacity(0.1),
              ),
              child: const Icon(LineAwesomeIcons.angle_right_solid,
                  size: 18, color: Colors.grey),
            )
          : null, // Conditionally render the trailing icon
    );
  }
}
