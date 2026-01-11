import 'package:flutter/material.dart';
import 'package:emoji_regex/emoji_regex.dart';

class UserChatCard extends StatelessWidget {
  final String username;
  final String profileImage;
  final String lastMessage;
  final String timeAgo;
  final bool hasUnreadMessages;
  final int unreadCount;
  final VoidCallback onTap;

  UserChatCard({
    required this.username,
    required this.profileImage,
    required this.lastMessage,
    required this.timeAgo,
    required this.hasUnreadMessages,
    required this.unreadCount,
    required this.onTap,
  });

  bool isEmojiOnly(String text) {
    final regex = emojiRegex();
    return regex.allMatches(text).isNotEmpty &&
        text.trim().length == regex.allMatches(text).length;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      splashColor: Colors.green.shade200,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundImage:
            profileImage.isNotEmpty ? NetworkImage(profileImage) : null,
        child: profileImage.isEmpty
            ? Icon(Icons.person, color: Colors.white)
            : null,
        radius: 25,
        backgroundColor: Colors.grey.shade300,
      ),
      title: Text(
        username,
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      subtitle: Text(
        lastMessage,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: isEmojiOnly(lastMessage) ? 20 : 14,
          fontWeight: hasUnreadMessages ? FontWeight.bold : FontWeight.normal,
          color: hasUnreadMessages ? Colors.black : Colors.grey,
        ),
      ),
      trailing: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            timeAgo,
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          if (hasUnreadMessages)
            Container(
              margin: EdgeInsets.only(top: 5),
              padding: unreadCount > 0
                  ? EdgeInsets.symmetric(horizontal: 6, vertical: 2)
                  : EdgeInsets.zero,
              decoration: BoxDecoration(
                color: Colors.green,
                shape: unreadCount > 0 ? BoxShape.rectangle : BoxShape.circle,
                borderRadius:
                    unreadCount > 0 ? BorderRadius.circular(12) : null,
              ),
              child: unreadCount > 0
                  ? Text(
                      unreadCount > 9 ? '9+' : unreadCount.toString(),
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    )
                  : Container(width: 8, height: 8), // Green dot when no count
            ),
        ],
      ),
    );
  }
}
