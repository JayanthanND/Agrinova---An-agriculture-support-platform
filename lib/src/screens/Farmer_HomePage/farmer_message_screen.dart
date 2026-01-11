import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Language/app_localization.dart';
import '../Common_Pages/Chat Screen/chat_screen.dart';
import '../Customs/constants.dart';
import '../Customs/message_screen_card.dart';

class FarmerMessageScreen extends StatefulWidget {
  @override
  _FarmerMessageScreenState createState() => _FarmerMessageScreenState();
}

class _FarmerMessageScreenState extends State<FarmerMessageScreen> {
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  TextEditingController searchController = TextEditingController();
  String searchQuery = "";
  Future<Map<String, dynamic>?> getUserData(String userId) async {
    DocumentSnapshot investorDoc = await FirebaseFirestore.instance
        .collection('investors')
        .doc(userId)
        .get();
    if (investorDoc.exists) {
      return {
        "collection": "investors",
        ...investorDoc.data() as Map<String, dynamic>
      };
    }
    DocumentSnapshot retailerDoc = await FirebaseFirestore.instance
        .collection('retailers')
        .doc(userId)
        .get();
    if (retailerDoc.exists) {
      return {
        "collection": "retailers",
        ...retailerDoc.data() as Map<String, dynamic>
      };
    }

    DocumentSnapshot donorDoc =
        await FirebaseFirestore.instance.collection('donors').doc(userId).get();
    if (donorDoc.exists) {
      return {
        "collection": "donors",
        ...donorDoc.data() as Map<String, dynamic>
      };
    }

    return null; // User not found
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      body: Column(
        children: [
          // Custom top bar like WhatsApp
          Container(
            color: MainGreen,
            padding: EdgeInsets.only(top: 40, bottom: 10, left: 10, right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    context.watch<LocalizationService>().translate('messages'),
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                ),
                // Icon(Icons.more_vert,
                //     color: Colors.white),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: context
                    .watch<LocalizationService>()
                    .translate('search_users'),
                filled: true,
                fillColor: Colors.grey.shade400,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
            ),
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('farmers')
                  .doc(currentUserId)
                  .collection('messages')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                      child: Text(context
                          .watch<LocalizationService>()
                          .translate('no_conversations')));
                }

                var conversations = snapshot.data!.docs;

                return ListView.builder(
                  padding: EdgeInsets.zero,
                  itemCount: conversations.length,
                  itemBuilder: (context, index) {
                    var conversation = conversations[index];
                    String otherUserId = conversation.id;

                    return FutureBuilder<Map<String, dynamic>?>(
                      future: getUserData(otherUserId),
                      builder: (context, userSnapshot) {
                        if (!userSnapshot.hasData ||
                            userSnapshot.data == null) {
                          return SizedBox(); // Skip if user not found
                        }

                        var otherUser = userSnapshot.data!;
                        String username = otherUser['username'] ?? 'Unknown';
                        if (!username.toLowerCase().contains(searchQuery)) {
                          return SizedBox(); // Hide non-matching users
                        }

                        String profileImage =
                            otherUser['profileImageUrl'] ?? '';
                        String targetCollection = otherUser['collection'];

                        return StreamBuilder<QuerySnapshot>(
                          stream: conversation.reference
                              .collection('chats')
                              .orderBy('timestamp', descending: true)
                              .snapshots(), // Fetch all messages
                          builder: (context, messageSnapshot) {
                            String lastMessage = context
                                .watch<LocalizationService>()
                                .translate('noMessages');
                            String timeAgo = "";
                            int unreadCount = 0; // Count unread messages
                            bool hasUnreadMessages = false;

                            if (messageSnapshot.hasData &&
                                messageSnapshot.data!.docs.isNotEmpty) {
                              var lastMsgDoc = messageSnapshot.data!.docs.first;

                              lastMessage = lastMsgDoc['message'] ?? '';
                              Timestamp timestamp = lastMsgDoc['timestamp'];
                              timeAgo = _formatTime(timestamp);

                              // Check if the last message is unread & not sent by the current user
                              bool isUnread = lastMsgDoc['isRead'] == false &&
                                  lastMsgDoc['receiverId'] == currentUserId;

                              unreadCount = messageSnapshot.data!.docs
                                  .where((msg) =>
                                      msg['isRead'] == false &&
                                      msg['receiverId'] == currentUserId)
                                  .length;

                              hasUnreadMessages = unreadCount > 0;
                            }

                            return Column(
                              children: [
                                UserChatCard(
                                  username: username,
                                  profileImage: profileImage,
                                  lastMessage: lastMessage,
                                  timeAgo: timeAgo,
                                  hasUnreadMessages: hasUnreadMessages,
                                  unreadCount: unreadCount,
                                  onTap: () async {
                                    await _markMessagesAsSeen(
                                        conversation.reference);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ChatScreen(
                                          senderId: currentUserId,
                                          senderCollection: 'farmers',
                                          receiverId: otherUserId,
                                          receiverCollection: targetCollection,
                                          receiverName: username,
                                          receiverProfile: profileImage,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                Divider(
                                    thickness: 1,
                                    color: Colors
                                        .grey.shade300), // ✅ Line between items
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Format timestamp to human-readable text
  String _formatTime(Timestamp timestamp) {
    DateTime messageTime = timestamp.toDate();
    DateTime now = DateTime.now();
    Duration difference = now.difference(messageTime);

    if (difference.inMinutes < 1)
      return context.watch<LocalizationService>().translate('just_now');
    if (difference.inHours < 1)
      return context.watch<LocalizationService>().translate(
          '${difference.inMinutes} ${context.watch<LocalizationService>().translate('minutes_ago')}');
    if (difference.inDays < 1)
      return context.watch<LocalizationService>().translate(
          '${difference.inHours} ${context.watch<LocalizationService>().translate('hours_ago')}');
    return "${messageTime.day}/${messageTime.month}/${messageTime.year}";
  }

  /// Mark all messages as read for a conversation
  Future<void> _markMessagesAsSeen(DocumentReference conversationRef) async {
    QuerySnapshot messages = await conversationRef
        .collection('chats')
        .where('receiverId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in messages.docs) {
      await doc.reference.update({"isRead": true});
    }
  }
}
