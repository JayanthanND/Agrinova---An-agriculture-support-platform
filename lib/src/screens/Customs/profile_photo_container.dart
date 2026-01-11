import 'package:flutter/material.dart';

class ProfilePhotoWidget extends StatelessWidget {
  final String? profileImageUrl;
  final VoidCallback? onPressed; // Allow it to be null
  final bool showIcon; // New parameter to control visibility of the icon

  const ProfilePhotoWidget({
    Key? key,
    required this.profileImageUrl,
    this.onPressed, // Nullable callback
    this.showIcon = true, // Default to true
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        alignment:
            Alignment.bottomRight, // Align the camera icon at the bottom right
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: onPressed, // Trigger the image change on tap
                child: CircleAvatar(
                  radius: 65, // Radius of the circular profile photo
                  backgroundColor: Colors.grey[400], // Default background color
                  backgroundImage: profileImageUrl != null &&
                          profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!) // Load image from URL
                      : null, // No image to load
                  child: profileImageUrl == null ||
                          profileImageUrl!.isEmpty // Show placeholder text
                      ? Icon(Icons.person,
                          size: 60, color: Colors.white) // Placeholder icon
                      : null,
                ),
              ),
            ],
          ),
          // Camera icon
          if (showIcon) // Only show icon if showIcon is true
            Positioned(
              bottom: 8, // Position it slightly above the bottom
              right: 8, // Position it slightly from the right
              child: GestureDetector(
                onTap: onPressed, // Trigger the image change on tap
                child: CircleAvatar(
                  radius: 15, // Radius of the camera icon container
                  backgroundColor:
                      Colors.white, // Background color for the icon container
                  child: Icon(
                    Icons.camera_alt,
                    size: 18, // Size of the camera icon
                    color: Colors.grey[700], // Icon color
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
