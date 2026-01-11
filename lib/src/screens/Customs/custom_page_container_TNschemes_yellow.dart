import 'package:flutter/material.dart';
import 'constants.dart';

class CustomPageContainerTnschemesYellow extends StatelessWidget {
  final String Header;
  final VoidCallback? onTap;

  const CustomPageContainerTnschemesYellow({
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
          color: Colors.yellow.shade200,
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
            SizedBox(
              width: 5,
            ),
            CircleAvatar(
              radius: 20, // Adjust the size
              backgroundColor: Colors.transparent, // Transparent background
              foregroundImage: AssetImage('assets/images/tn.png'),
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
