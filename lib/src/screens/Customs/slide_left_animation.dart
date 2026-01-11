import 'package:flutter/material.dart';

// Custom Page Route for a smoother slide transition
class SlideLeftRoute extends PageRouteBuilder {
  final Widget page;
  SlideLeftRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(
              milliseconds: 400), // Increase duration for smoothness
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0); // Start from right
            const end = Offset.zero; // End at original position
            const curve = Curves.ease; // Smoother curve

            // Define the animation
            var tween =
                Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
            var offsetAnimation = animation.drive(tween);

            return SlideTransition(
              position: offsetAnimation,
              child: child,
            );
          },
        );
}
