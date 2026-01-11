import 'package:flutter/material.dart';
import 'constants.dart';

class CustomPageContainerWithimage extends StatelessWidget {
  final String Header;
  final String imagePath;
  final Color overlayColor;
  final VoidCallback? onTap;

  const CustomPageContainerWithimage({
    Key? key,
    required this.Header,
    required this.imagePath,
    this.overlayColor = Colors.grey,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Stack(
          children: [
            Container(
              constraints: const BoxConstraints(minHeight: 70, minWidth: 350),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    overlayColor.withOpacity(1),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  Header,
                  style: NormalTextWhite,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
