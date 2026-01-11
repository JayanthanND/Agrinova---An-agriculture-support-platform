import 'package:flutter/material.dart';
import 'constants.dart';

class CustomPageContainerSchemesOrange extends StatelessWidget {
  final String Header;
  final VoidCallback? onTap;

  const CustomPageContainerSchemesOrange({
    Key? key,
    required this.Header,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        constraints: const BoxConstraints(minHeight: 70, minWidth: 350),
        decoration: BoxDecoration(
          color: Colors.deepOrange.shade200,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 5,
            ),
          ],
        ),
        child: Row(
          children: [
            // Rounded India Logo
            CircleAvatar(
              radius: 25, // Adjust the size
              backgroundColor: Colors.transparent, // Transparent background
              foregroundImage: AssetImage('assets/images/india1.png'),
            ),

            // Header Text
            Expanded(
              child: Text(
                Header,
                style: NormalTextGrey,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
