import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';

// Function to create a reusable container for the land map image
Widget landMapImageContainer({
  required BuildContext context,
  required String? landMapImageUrl, // Image URL can be nullable
  required VoidCallback onPressed, // Button callback function
}) {
  return Container(
    padding: EdgeInsets.all(20), // Add padding inside the container
    decoration: BoxDecoration(
      color: Colors.white, // Background color of the container
      borderRadius:
          BorderRadius.circular(12), // Rounded corners for the entire container
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1), // Shadow effect
          spreadRadius: 2,
          blurRadius: 5,
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min, // Make the container adapt to its content
      children: [
        // Display the land map image
        Container(
          width: 350,
          height: 200,
          decoration: BoxDecoration(
            color:
                Colors.grey[300], // Background color if no image is available
            borderRadius: BorderRadius.circular(12), // Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1), // Shadow effect
                spreadRadius: 2,
                blurRadius: 5,
              ),
            ],
          ),
          child: landMapImageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(
                      12), // Clip the image to the container shape
                  child: Image.network(
                    landMapImageUrl!,
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover, // Ensure the image covers the container
                  ),
                )
              : Center(
                  child: Text(
                    context.watch<LocalizationService>().translate('no_image'),
                    style: TextStyle(color: Colors.black45),
                  ),
                ),
        ),
        SizedBox(height: 20),

        // Change Land Map Image button
        ElevatedButton(
          onPressed: onPressed, // Pass the button's callback
          child: Text(
            context.watch<LocalizationService>().translate('select_landmap'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white, // Custom text style
            ),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12), // Rounded button corners
            ),
          ),
        ),
      ],
    ),
  );
}
