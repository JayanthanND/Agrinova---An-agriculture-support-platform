import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/profile_photo_container.dart';
import 'package:provider/provider.dart';
import '../../Language/app_localization.dart';
import '../User Class/user.dart';
import 'constants.dart';

/// Widget for displaying Farmer/Retailer details
class FarmerRetailerContainer extends StatelessWidget {
  final User user;

  FarmerRetailerContainer({required this.user});

  @override
  Widget build(BuildContext context) {
    // Check if the user is a Retailer and cast accordingly
    final isRetailer = user is Retailer;
    final retailer = isRetailer ? user as Retailer : null;

    final profileImageUrl = user.profileImageUrl;
    final username = user.username;
    final role = user.role;
    final description = user.description;
    final companyName = isRetailer
        ? retailer?.companyName ?? 'N/A'
        : 'N/A'; // Provide default value if null
    final cropReqd = isRetailer
        ? retailer?.cropReqd ?? 'N/A'
        : 'N/A'; // Provide default value if null
    final location = user.location;

    return Container(
      padding: const EdgeInsets.only(top: 10, bottom: 10, left: 20, right: 20),
      margin: const EdgeInsets.symmetric(horizontal: 10),
      constraints: BoxConstraints(maxWidth: double.infinity, minHeight: 300),
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
          // Top Row: Profile Image + User Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfilePhotoWidget(
                profileImageUrl: profileImageUrl,
                onPressed: () {
                  // Handle profile photo tap
                  print("Profile photo tapped!");
                },
                showIcon: false,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(username, style: NormalTextBlack),
                    const SizedBox(height: 5),
                    Text(role, style: SmallTextGrey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: Colors.grey.shade300, thickness: 1),
          const SizedBox(height: 10),

          // Company Name Section
          Text(
              '${context.watch<LocalizationService>().translate('company_name')}:',
              style: TextBlack),
          const SizedBox(height: 1),
          Text(companyName, style: SmallTextGrey), // Default value used here

          const SizedBox(height: 10),

          // Crop Required Section
          Text(
              '${context.watch<LocalizationService>().translate('crop_required')}:',
              style: TextBlack),
          const SizedBox(height: 1),
          Text(cropReqd, style: SmallTextGrey), // Default value used here

          const SizedBox(height: 10),

          // Location Section
          Text('${context.watch<LocalizationService>().translate('location')}:',
              style: TextBlack),
          const SizedBox(height: 1),
          Text(location, style: SmallTextGrey),

          // Description Section
        ],
      ),
    );
  }
}
