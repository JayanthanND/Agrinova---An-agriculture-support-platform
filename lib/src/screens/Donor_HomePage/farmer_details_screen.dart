import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Chat%20Screen/chat_screen.dart';
import 'package:provider/provider.dart';
import '../../Language/app_localization.dart';
import '../Common_Pages/Chat Screen/flutterui_chat_screen.dart';
import '../Customs/constants.dart';
import '../Customs/detail_screen_phone_widget.dart';
import '../Customs/detail_screen_widget.dart';
import '../Customs/image_container.dart';
import '../Customs/profile_photo_container.dart';

class FarmerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String currentUserId;
  final String currentUserCollection;
  const FarmerDetailsScreen(
      {super.key,
      required this.user,
      required this.currentUserId,
      required this.currentUserCollection});

  @override
  _FarmerDetailsScreenState createState() => _FarmerDetailsScreenState();
}

class _FarmerDetailsScreenState extends State<FarmerDetailsScreen> {
  bool _requestSent = false; // Track whether the follow request is sent
  bool _requestAccepted = false; // Track whether the follow request is accepted
  String currentUserId = '';
  // Function to send a follow request

  @override
  void initState() {
    super.initState();
    initializeUserId();
    // Debugging: Print the values passed to this screen
    // print('Current User ID: ${currentUserId}');
    // print('Current User Collection: ${widget.currentUserCollection}');
    // print('User Data: ${widget.user}');
  }

  Future<void> initializeUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid; // Fetch userId from FirebaseAuth
        print("Retrieved userId from FirebaseAuth: $currentUserId");
        await _checkRequestStatus();
      } else {}

      if (currentUserId.isEmpty) {
        print("Error: userId is empty. Redirecting to login.");
        // Optionally redirect to login
        Navigator.pop(context);
        return;
      }
    } catch (e) {
      print("Error initializing userId: $e");
    }
  }

  Future<void> _checkRequestStatus() async {
    try {
      // Ensure user id and role are not null
      if (widget.user['id'] == null || widget.user['role'] == null) {
        print('Error: user id or role is null.');
        return; // Exit early if any of these are null
      }
      print(widget.user['id']);
      final currentUserSnapshot = await FirebaseFirestore.instance
          .collection(widget.currentUserCollection)
          .doc(currentUserId)
          .get();

      List<dynamic> requestsSent =
          currentUserSnapshot.get('requestsSent') ?? [];
      if (requestsSent.contains(widget.user['id'])) {
        setState(() {
          _requestSent = true;
        });
      }

      // Check if the request has been accepted
      DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
          .collection('farmers') // Use dynamic target collection
// Use dynamic target collection
          .doc(widget.user['id']) // Use widget.user['id'] as document ID
          .get();

      if (userSnapshot.exists) {
        // Extract the followers list and check for the current user
        List<dynamic> followers = userSnapshot.get('followers') ?? [];
        print("followers: $followers");

        setState(() {
          // Check if the followers list contains the current user
          _requestAccepted = followers.any((follower) =>
              follower is Map<String, dynamic> &&
              follower['userId'] == currentUserId &&
              follower['collection'] == widget.currentUserCollection);
        });
      }
    } catch (e) {
      print("Error checking request status: $e");
    } finally {
      setState(() {});
    }
  }

  // Send follow request to Firestore
  Future<void> _sendFollowRequest() async {
    try {
      if (widget.user['id'] == null || currentUserId.isEmpty) {
        print('Error: User ID or current user ID is null.');
        return;
      }

      print(
          "Sending follow request from: $currentUserId to: ${widget.user['id']}");

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.user['id'])
          .set(
        {
          'followRequests': FieldValue.arrayUnion([currentUserId]),
        },
        SetOptions(merge: true),
      );

      await FirebaseFirestore.instance
          .collection(widget.currentUserCollection)
          .doc(currentUserId)
          .set(
        {
          'requestsSent': FieldValue.arrayUnion([widget.user['id']]),
        },
        SetOptions(merge: true),
      );

      print("✅ Follow request written successfully");

      // Ensure Firestore reflects the update by fetching again
      await Future.delayed(Duration(milliseconds: 500));
      await _checkRequestStatus();
    } catch (e) {
      print('❌ Error sending request: $e');
    }
  }

  // Unfollow the user
  Future<void> _unfollowUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.user['id'])
          .update({
        'followRequests': FieldValue.arrayRemove([currentUserId]),
        'followers': FieldValue.arrayRemove([
          {'userId': currentUserId, 'collection': widget.currentUserCollection}
        ]),
      });

      await FirebaseFirestore.instance
          .collection(widget.currentUserCollection)
          .doc(currentUserId)
          .update({
        'requestsSent': FieldValue.arrayRemove([widget.user['id']]),
        'following': FieldValue.arrayRemove([
          {'userId': widget.user['id'], 'collection': 'farmers'}
        ]),
      });

      setState(() {
        _requestSent = false;
        _requestAccepted = false;
      });

      print('Unfollowed successfully');
    } catch (e) {
      print('Error unfollowing: $e');
    }
  }

  // Send message to the user (Placeholder function)
// Send message to the user (Updated to pass sender details)
  void _sendMessage() {
    print("Opening Chat Box");
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ChatScreen(
          senderId: currentUserId, // Pass sender's ID
          senderCollection:
              widget.currentUserCollection, // Pass sender's collection
          receiverId: widget.user['id'],
          receiverCollection: 'farmers',
          receiverName: widget.user['username'], // Receiver's name
          receiverProfile:
              widget.user['profileImageUrl'], // Receiver's profile picture
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                  top: 0, bottom: 16, right: 16, left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            padding: EdgeInsets.only(top: 45),
                            icon:
                                Icon(Icons.arrow_back_ios, color: Colors.grey),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),

                      // Full-screen text (ignoring the back button space)
                      Expanded(
                        flex: 2,
                        child: Container(
                          alignment: Alignment
                              .topCenter, // Ensures text is centered in available space
                          padding: EdgeInsets.only(top: 45),
                          child: Text(
                            context
                                .watch<LocalizationService>()
                                .translate('profile'),
                            style: NormalTextBlack,
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(),
                      ),
                    ],
                  ),
                  Center(
                    child: ProfilePhotoWidget(
                      profileImageUrl: widget.user['profileImageUrl'],
                      onPressed: () {
                        print('Profile photo tapped!');
                      },
                      showIcon: false,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Using DetailField to display Name
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('username'),
                    value: widget.user['username'],
                  ),
                  const SizedBox(height: 10),

                  // Using DetailField to display Email
                  DetailField(
                    label:
                        context.watch<LocalizationService>().translate('email'),
                    value: widget.user['email'],
                  ),
                  const SizedBox(height: 10),

                  // Using DetailField to display Role
                  DetailField(
                    label:
                        context.watch<LocalizationService>().translate('role'),
                    value: widget.user['role'],
                  ),
                  if (_requestAccepted) ...[
                    const SizedBox(height: 10),
                    DetailField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('location'),
                      value: widget.user['location'],
                    ),
                  ],
                  const SizedBox(height: 10),
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('landmap'),
                    value:
                        '', // You can leave value empty or provide a placeholder
                    imageUrl: widget.user[
                        'landMapImageUrl'], // Pass the land map image URL here
                  ),

                  const SizedBox(height: 10),
                  // Using DetailField to display Description
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('live_stock'),
                    value: widget.user['liveStock'],
                  ),
                  const SizedBox(height: 10),
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('water_facility'),
                    value: widget.user['waterFacility'],
                  ),
                  const SizedBox(height: 10),
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('request'),
                    value: widget.user['request'],
                  ),
                  if (_requestAccepted) ...[
                    const SizedBox(height: 10),
                    PhoneNumberField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('phone_number'),
                      phoneNumber: widget.user['phoneNumber'],
                    ),
                  ],
                  const SizedBox(height: 10),
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('requirement'),
                    value: widget.user['requirement'],
                  ),
                  const SizedBox(height: 10),
                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('description'),
                    value: widget.user['description'],
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
          // Fixed Request Button
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: _requestAccepted
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: _unfollowUser,
                          child: Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('unfollow'),
                              style: SmallTextWhite),
                          style: ElevatedButton.styleFrom(
                              elevation: 10,
                              shadowColor: Colors.blue,
                              fixedSize: Size(150, 40),
                              backgroundColor: Colors.red,
                              side: BorderSide(color: Colors.red, width: 2)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _sendMessage,
                          child: Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('message'),
                              style: SmallTextWhite),
                          style: ElevatedButton.styleFrom(
                              elevation: 10,
                              shadowColor: Colors.blue,
                              fixedSize: Size(150, 40),
                              backgroundColor: Color(0xff1ACD36),
                              side: BorderSide(
                                  color: Color(0xff1ACD36), width: 2)),
                        ),
                      ],
                    )
                  : ElevatedButton(
                      onPressed: _requestSent
                          ? null
                          : _sendFollowRequest, // Disable button if requested
                      child: Text(
                        _requestSent
                            ? context
                                .watch<LocalizationService>()
                                .translate('requested')
                            : context
                                .watch<LocalizationService>()
                                .translate('request'),
                        style: SmallTextWhite,
                      ),
                      style: ElevatedButton.styleFrom(
                        fixedSize: Size(330, 50),
                        elevation: 10,
                        shadowColor: Colors.blue,
                        // padding: const EdgeInsets.symmetric(
                        //     horizontal: 80, vertical: 15),
                        backgroundColor: Color(0xff1ACD36),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
