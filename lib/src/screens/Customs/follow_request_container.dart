import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import 'constants.dart';

class FollowRequestCard extends StatelessWidget {
  final String username;
  final String profileImageUrl;
  final VoidCallback onAccept;
  final VoidCallback onDecline;
  final double width;
  final double height;
  final double padding;

  const FollowRequestCard({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.onAccept,
    required this.onDecline,
    this.width = double.infinity,
    this.height = 100.0,
    this.padding = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: EdgeInsets.all(padding),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.6),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            radius: 25,
            backgroundImage: profileImageUrl.isNotEmpty
                ? NetworkImage(profileImageUrl)
                : null,
            child: profileImageUrl.isEmpty
                ? const Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.white,
                  )
                : null,
          ),

          const SizedBox(width: 16),

          // Username and Request Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  username,
                  style: TextBlack,
                  overflow: TextOverflow.ellipsis, // Ensure text truncates
                  maxLines: 1, // Limit username to one line
                ),
              ],
            ),
          ),

          // Accept Button and X Mark for Decline
          ElevatedButton(
            onPressed: onAccept,
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xff1ACD36),
              padding: const EdgeInsets.symmetric(horizontal: 12),
            ),
            child: Text(
                context.watch<LocalizationService>().translate('accept'),
                style: SmallTextWhite),
          ),

          // X Mark for Decline
          IconButton(
            onPressed: onDecline,
            icon: const Icon(Icons.close, color: Colors.grey),
            iconSize: 20,
            tooltip: 'Decline Request',
          ),
        ],
      ),
    );
  }
}
