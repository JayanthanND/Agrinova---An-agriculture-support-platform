import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_agrinova/src/screens/Donor_HomePage/farmer_details_screen.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/follow_request_container.dart';

class FollowRequestsPageFarmerRetailer extends StatefulWidget {
  final String currentUserId;

  const FollowRequestsPageFarmerRetailer(
      {super.key, required this.currentUserId});

  @override
  _FollowRequestsPageFarmerRetailerState createState() =>
      _FollowRequestsPageFarmerRetailerState();
}

class _FollowRequestsPageFarmerRetailerState
    extends State<FollowRequestsPageFarmerRetailer> {
  String currentUserId = '';

  @override
  void initState() {
    super.initState();
    initializeUserId();
  }

  Future<void> initializeUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;

        // Fetch the user document from Firestore
        var userDoc = await FirebaseFirestore.instance
            .collection('farmers')
            .doc(currentUserId)
            .get();

        if (userDoc.exists) {
          // Check if the 'followRequests' field exists, if not, create it
          if (!userDoc.data()!.containsKey('followRequestsRetailer')) {
            await FirebaseFirestore.instance
                .collection('farmers')
                .doc(currentUserId)
                .update({
              'followRequestsRetailer': [], // Initialize it as an empty list
            });
          }
        }

        print("Retrieved userId from FirebaseAuth: $currentUserId");
      } else {
        print("Error: userId is empty. Redirecting to login.");
        Navigator.pop(context); // Optionally redirect to login
      }
    } catch (e) {
      print("Error initializing userId: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1ACD36),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  color: const Color(0xff1ACD36),
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 30, bottom: 14),
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 15),
                              Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('app_name'),
                                  style: TitleStyle),
                              const SizedBox(height: 5),
                              Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('tagline'),
                                  style: SmallTextWhite),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Line,
                      FollowRequestMainContainer(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                            Row(
                              children: [
                                SizedBox(
                                  width: 10,
                                ),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('follow_requests'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            LineGrey,
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('users_requested_follow'),
                                    style: SmallTextGrey),
                              ],
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            // Follow request cards
                            _buildFollowRequestStream(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFollowRequestStream() {
    if (currentUserId.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
              child: Text(
            context
                .watch<LocalizationService>()
                .translate('no_follow_requests'),
            style: SmallTextGrey,
          ));
        }

        List<dynamic> requests = snapshot.data!['followRequestsRetailer'] ?? [];

        if (requests.isEmpty) {
          return Center(
              child: Text(
            context
                .watch<LocalizationService>()
                .translate('no_follow_requests'),
            style: SmallTextGrey,
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap:
              true, // Allows ListView to size itself within the container
          physics:
              const NeverScrollableScrollPhysics(), // Prevent internal scrolling
          itemCount: requests.length,
          itemBuilder: (context, index) {
            String requestUserId = requests[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('retailers')
                  .doc(requestUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return SizedBox(); // Placeholder while loading
                }

                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return ListTile(
                      title: Text(context
                          .watch<LocalizationService>()
                          .translate('unknown_user')));
                }

                var user = userSnapshot.data!;
                String username = user['username'] ??
                    context
                        .watch<LocalizationService>()
                        .translate('unknown_user');
                var userData = user.data() as Map<String, dynamic>?;

                String profileImageUrl =
                    userData != null && userData.containsKey('profileImageUrl')
                        ? userData['profileImageUrl'] ?? ''
                        : '';
                return Padding(
                  padding: EdgeInsets.only(bottom: 25),
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the specific details screen on tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmerDetailsScreen(
                            user: userData ?? {},
                            currentUserId: currentUserId,
                            currentUserCollection:
                                'farmers', // Replace with your collection
                          ),
                        ),
                      );
                    },
                    child: FollowRequestCard(
                      username: username,
                      profileImageUrl: profileImageUrl,
                      onAccept: () =>
                          _acceptRequest(currentUserId, requestUserId),
                      onDecline: () =>
                          _declineRequest(currentUserId, requestUserId),
                      width: 200,
                      height: 90.0,
                      padding: 12.0,
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  // Accept Follow Request
  Future<void> _acceptRequest(
      String currentUserId, String requestUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUserId)
          .update({
        'followers': FieldValue.arrayUnion([
          {'userId': requestUserId, 'collection': 'retailers'}
        ]),
        'followRequestsRetailer': FieldValue.arrayRemove([requestUserId]),
      });

      await FirebaseFirestore.instance
          .collection('retailers')
          .doc(requestUserId)
          .update({
        'following': FieldValue.arrayUnion([
          {'userId': currentUserId, 'collection': 'farmers'}
        ]),
        'requestsSent': FieldValue.arrayRemove([currentUserId]),
      });

      print('Request accepted from $requestUserId');
      // In your accept/decline functions after Firestore updates:
      if (mounted) {
        setState(() {}); // Force UI update
        Navigator.pop(context); // Then close
      }
    } catch (e) {
      print("Error accepting request: $e");
    }
  }

  // Decline Follow Request
  Future<void> _declineRequest(
      String currentUserId, String requestUserId) async {
    try {
      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUserId)
          .update({
        'followers': FieldValue.arrayUnion([
          {'userId': requestUserId, 'collection': 'retailers'}
        ]),
        'followRequestsRetailer': FieldValue.arrayRemove([requestUserId]),
      });
      await FirebaseFirestore.instance
          .collection('retailers')
          .doc(requestUserId)
          .update({
        'following': FieldValue.arrayUnion([
          {'userId': currentUserId, 'collection': 'farmers'}
        ]),
        'requestsSent': FieldValue.arrayRemove([currentUserId]),
      });

      print('Request declined from $requestUserId');
      // In your accept/decline functions after Firestore updates:
      if (mounted) {
        setState(() {}); // Force UI update
        Navigator.pop(context); // Then close
      }
    } catch (e) {
      print("Error declining request: $e");
    }
  }
}
