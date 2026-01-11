import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/profile_photo_container.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../User Class/user.dart';
import 'constants.dart';

Widget FarmerPageContentContainer(
    {required BuildContext context, required User user}) {
  final profileImageUrl = user.profileImageUrl;
  final username = user.username;
  final role = user.role;
  final description = user.description;

  print("Profile Image URL in ContentContainer: $profileImageUrl"); // Debug log

  return Container(
    padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
    margin: const EdgeInsets.symmetric(horizontal: 10),
    constraints: BoxConstraints(minHeight: 300, maxWidth: double.infinity),
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
        // Replace CircleAvatar with ProfilePhotoWidget
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
        Text(
          '${context.watch<LocalizationService>().translate('description')}:',
          style: TextBlack,
        ),
        Text(
          description,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: SmallTextGrey,
        ),
      ],
    ),
  );
}
