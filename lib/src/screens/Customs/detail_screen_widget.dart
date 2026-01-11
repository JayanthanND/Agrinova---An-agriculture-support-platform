import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';

class DetailField extends StatelessWidget {
  final String label;
  final String value;
  final String? imageUrl; // Optional parameter for the image URL
  final Widget? child;
  const DetailField({
    Key? key,
    required this.label,
    required this.value,
    this.imageUrl,
    this.child, // Initialize the optional image URL
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1), // Shadow effect
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: SmallTextGrey, // Label style
          ),
          const SizedBox(height: 5),
          if (child != null)
            child! // Custom child content
          else
            Text(
              value,
              style: TextBlack, // Display text in black
            ),
          if (imageUrl != null) ...[
            Image.network(
              imageUrl!,
              width: double.infinity, // Full width of the container
              height: 150, // Fixed height for the image
              fit: BoxFit.cover, // Cover the area without stretching
              errorBuilder: (context, error, stackTrace) {
                return Center(
                    child: Text('Failed to load image')); // Error handling
              },
            ),
          ],
        ],
      ),
    );
  }
}
