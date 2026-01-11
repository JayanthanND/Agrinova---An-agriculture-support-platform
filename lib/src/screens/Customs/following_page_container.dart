import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import 'constants.dart';

class FollowingUserCard extends StatelessWidget {
  final String username;
  final String profileImageUrl;
  final VoidCallback onUnfollow;
  final double width;
  final double height;
  final double padding;

  const FollowingUserCard({
    super.key,
    required this.username,
    required this.profileImageUrl,
    required this.onUnfollow,
    this.width = double.infinity,
    this.height = 80.0,
    this.padding = 10.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: EdgeInsets.all(padding),
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
      child: Column(
        children: [
          // Profile Image and Username
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                radius: 25,
                backgroundImage: profileImageUrl.isNotEmpty
                    ? NetworkImage(profileImageUrl)
                    : null,
                child: profileImageUrl.isEmpty
                    ? const Icon(Icons.person, size: 40, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  username,
                  style: TextBlack,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),
            ],
          ),
          Line,
          // Buttons Section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: onUnfollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: FittedBox(
                    child: Text(
                      context
                          .watch<LocalizationService>()
                          .translate('unfollow'),
                      style: SmallTextWhite,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
