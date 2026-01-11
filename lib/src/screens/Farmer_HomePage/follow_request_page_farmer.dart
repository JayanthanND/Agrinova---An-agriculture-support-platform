import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/follow_request_container.dart';
import 'investor_donor_details_screen.dart';

class FollowRequestsPageFarmer extends StatefulWidget {
  final String currentUserId;

  const FollowRequestsPageFarmer({super.key, required this.currentUserId});

  @override
  _FollowRequestsPageState createState() => _FollowRequestsPageState();
}

class _FollowRequestsPageState extends State<FollowRequestsPageFarmer> {
  String currentUserId = '';
  String farmerNeed = ''; // Variable to store the farmer's selected need

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
          // Get the farmer's need (Donation or Investment) from Firestore
          setState(() {
            farmerNeed = userDoc['request'] ?? '';
            print("Print:${farmerNeed}");
          });

          // Check if the 'followRequests' field exists, if not, create it
          if (!userDoc.data()!.containsKey('followRequests')) {
            await FirebaseFirestore.instance
                .collection('farmers')
                .doc(currentUserId)
                .update({
              'followRequests': [], // Initialize it as an empty list
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

  // Helper function to get the appropriate collection name
  String getUserTypeCollection(String farmerNeed) {
    if (farmerNeed == 'Donation') {
      return 'donors';
    } else if (farmerNeed == 'Investment') {
      return 'investors';
    }
    return '';
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
                                Navigator.pop(context,
                                    true); // Return 'true' to indicate changes
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
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('follow_requests'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,

                            // Display follow requests dynamically based on farmer's need
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
    if (currentUserId.isEmpty || farmerNeed.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    String userTypeCollection = getUserTypeCollection(farmerNeed);

    if (userTypeCollection.isEmpty) {
      return const Center(child: Text('Invalid farmer need.'));
    }

    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
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

        List<dynamic> requests = snapshot.data!['followRequests'] ?? [];

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
          padding: EdgeInsets.zero, // Remove any default padding for ListView
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: requests.length,
          itemBuilder: (context, index) {
            // Ensure each request is treated as a String userId
            String requestUserId = requests[index];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(userTypeCollection)
                  .doc(requestUserId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return const SizedBox();
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
                          builder: (context) => InvestorDonorDetailsScreen(
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
      String userTypeCollection = getUserTypeCollection(farmerNeed);

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUserId)
          .update({
        'followers': FieldValue.arrayUnion([
          {'userId': requestUserId, 'collection': userTypeCollection}
        ]),
        'followRequests': FieldValue.arrayRemove([requestUserId]),
      });

      await FirebaseFirestore.instance
          .collection(userTypeCollection)
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
      String userTypeCollection = getUserTypeCollection(farmerNeed);

      await FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUserId)
          .update({
        'followRequests': FieldValue.arrayRemove([requestUserId]),
      });

      await FirebaseFirestore.instance
          .collection(userTypeCollection)
          .doc(requestUserId)
          .update({
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
