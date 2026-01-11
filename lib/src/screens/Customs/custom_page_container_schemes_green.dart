import 'package:flutter/material.dart';
import 'constants.dart';

class CustomPageContainerSchemesGreen extends StatelessWidget {
  final String Header;
  final VoidCallback? onTap;

  const CustomPageContainerSchemesGreen({
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
          color: Colors.green.shade200,
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
              backgroundImage: AssetImage('assets/images/india1.png'),
              // Use Image.network('your_url') for online image
            ),

            const SizedBox(width: 12), // Space between logo and text

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
