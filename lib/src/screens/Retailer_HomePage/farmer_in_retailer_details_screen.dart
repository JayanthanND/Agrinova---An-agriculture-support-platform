import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/detail_screen_phone_widget.dart';
import '../Customs/detail_screen_widget.dart';
import '../Customs/profile_photo_container.dart';
import '../Common_Pages/Chat Screen/chat_screen.dart';

class FarmerInRetailerDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final List<dynamic> crops; // Added crops parameter to accept crops data
  final String currentUserId;
  final String currentUserCollection;
  const FarmerInRetailerDetailsScreen(
      {super.key,
      required this.user,
      required this.crops,
      required this.currentUserId,
      required this.currentUserCollection // Initialize crops
      });

  @override
  _FarmerInRetailerDetailsScreenState createState() =>
      _FarmerInRetailerDetailsScreenState();
}

class _FarmerInRetailerDetailsScreenState
    extends State<FarmerInRetailerDetailsScreen> {
  String currentUserId = '';
  bool _requestSent = false;
  bool _requestAccepted = false;

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
          .collection(
              widget.currentUserCollection) // Use dynamic target collection
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
      // Ensure user ID and current user ID are not null
      if (widget.user['id'] == null || currentUserId.isEmpty) {
        print('Error: User ID or current user ID is null.');
        return; // Exit early if IDs are invalid
      }

      // Determine the target collection based on the role of the user (Donor or Investor)

      // Update the target user's 'followRequests' field (create if it doesn't exist)
      await FirebaseFirestore.instance
          .collection('farmers') // Use dynamic target collection
          .doc(widget.user['id'])
          .set(
        {
          'followRequestsRetailer': FieldValue.arrayUnion([currentUserId]),
        },
        SetOptions(merge: true), // Merge to avoid overwriting existing fields
      );

      // Update the current user's 'requestsSent' field (create if it doesn't exist)
      await FirebaseFirestore.instance
          .collection(widget.currentUserCollection)
          .doc(currentUserId)
          .set(
        {
          'requestsSent': FieldValue.arrayUnion([widget.user['id']]),
        },
        SetOptions(merge: true), // Merge to avoid overwriting existing fields
      );

      setState(() {
        _requestSent = true; // Update the UI to reflect the request being sent
      });

      print('Follow request sent successfully');
      await _checkRequestStatus();
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  // Unfollow the user
  Future<void> _unfollowUser() async {
    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(widget.user['id'])
          .update({
        'followRequestsRetailer': FieldValue.arrayRemove([currentUserId]),
        'followers': FieldValue.arrayRemove([currentUserId]),
      });

      await FirebaseFirestore.instance
          .collection(widget.currentUserCollection)
          .doc(currentUserId)
          .update({
        'requestsSent': FieldValue.arrayRemove([widget.user['id']]),
        'following': FieldValue.arrayRemove([widget.user['id']]),
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
                  if (_requestAccepted) ...[
                    const SizedBox(height: 10),
                    PhoneNumberField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('phone_number'),
                      phoneNumber: widget.user['phoneNumber'],
                    ),
                  ],
                  // Display Crop Details Section
                  const SizedBox(height: 10),

                  DetailField(
                    label: context
                        .watch<LocalizationService>()
                        .translate('crops_available'),
                    value: '', // Leave value empty to act as a label only
                    child: widget.crops.isEmpty
                        ? Center(
                            child: Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('no_crops_available'),
                              style: NormalTextGrey,
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: widget.crops.map((crop) {
                              return Container(
                                constraints: BoxConstraints(minWidth: 600),
                                margin: const EdgeInsets.only(
                                    bottom: 10), // Spacing between crops
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[
                                      100], // Light background for each crop
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black
                                          .withOpacity(0.05), // Light shadow
                                      blurRadius: 4,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate(
                                              ' ${context.watch<LocalizationService>().translate('crop_type')} : ${crop['cropType']}'),
                                      style: SmallTextBlack,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate(
                                              ' ${context.watch<LocalizationService>().translate('total_yield')} : ${crop['totalYield']} kg'),
                                      style: SmallTextBlack,
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate(
                                              ' ${context.watch<LocalizationService>().translate('cost_perkg')} : ₹${crop['sellingPrice']}'),
                                      style: SmallTextBlack,
                                    ),
                                    const SizedBox(height: 5),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
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
