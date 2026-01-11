import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/profile_photo_container.dart';
import 'package:provider/provider.dart';
import '../../Language/app_localization.dart';
import '../User Class/user.dart';
import 'constants.dart';

Widget FarmerInRetailerPageContentContainer(
    {required BuildContext context, required User user}) {
  final profileImageUrl = user.profileImageUrl;
  final username = user.username;
  final role = user.role;
  final description = user.description;
  String requirement = '';
  List<Map<String, dynamic>> crops = [];

  // Fetch requirement and crops if the user is a Farmer
  if (user is Farmer) {
    requirement = user.requirement;
    crops = user.crops;
  }

  print("Profile Image URL in ContentContainer: $profileImageUrl"); // Debug log

  return Container(
    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
    margin: const EdgeInsets.symmetric(horizontal: 10),
    constraints: BoxConstraints(maxWidth: 400, minHeight: 300),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.5),
          spreadRadius: 5,
          blurRadius: 10,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Profile section with ProfilePhotoWidget
        Row(
          children: [
            ProfilePhotoWidget(
              profileImageUrl: profileImageUrl,
              onPressed: () {
                // Handle onPressed, e.g., open image picker or another action
                print("Profile photo tapped!");
              },
              showIcon:
                  false, // Set to false if you don't want to show the camera icon
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    username,
                    style: NormalTextBlack,
                  ),
                  Text(role, style: SmallTextGrey),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Divider(),

        // Requirement Section
        // Text('Requirement:', style: TextBlack),
        // const SizedBox(height: 10),
        // Text(
        //   requirement,
        //   maxLines: 3,
        //   overflow: TextOverflow.ellipsis,
        //   style: SmallTextGrey,
        // ),
        // const SizedBox(
        //     height: 15), // Add space between Requirement and Description

        // Description Section
        // Text('Description:', style: TextBlack),
        // Text(
        //   description,
        //   maxLines: 3,
        //   overflow: TextOverflow.ellipsis,
        //   style: SmallTextGrey,
        // ),
        // const SizedBox(
        //     height: 15), // Add space between Description and Crops Section

        // Display Crops Section
        if (crops.isNotEmpty) ...[
          Text(
              '${context.watch<LocalizationService>().translate('crops_available')}:',
              style: TextBlack),
          const SizedBox(height: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: Colors.grey),
              ...crops.asMap().entries.map((entry) {
                final crop = entry.value;
                final index = entry.key;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Text(
                        "${crop['cropType']} - ${crop['totalYield']} ${context.watch<LocalizationService>().translate('kg')}",
                        style: SmallTextGrey,
                      ),
                    ),
                    // Add a Divider after each crop except the last one
                    if (index < crops.length - 1)
                      const Divider(height: 1, color: Colors.grey),
                  ],
                );
              }).toList(),
            ],
          ),
        ]
      ],
    ),
  );
}
