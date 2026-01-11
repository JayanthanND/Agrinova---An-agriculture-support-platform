import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/following_page_container.dart';
import 'package:project_agrinova/src/screens/Retailer_HomePage/farmer_in_retailer_details_screen.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/followers_page_container.dart';

class FollowersFollowingRetailerScreen extends StatefulWidget {
  final String currentUserId;

  const FollowersFollowingRetailerScreen(
      {super.key, required this.currentUserId});

  @override
  _FollowersFollowingRetailerScreenState createState() =>
      _FollowersFollowingRetailerScreenState();
}

class _FollowersFollowingRetailerScreenState
    extends State<FollowersFollowingRetailerScreen> {
  final PageController _pageController = PageController();
  String currentUserId = '';
  int _currentIndex = 0;
  String farmerNeed = ''; // Variable to store the farmer's selected need
  bool _requestSent = false;
  bool _requestAccepted = false;
  Map<String, bool> requestStatus = {}; // Store request state for each follower
  @override
  void initState() {
    super.initState();
    initializeUserId();
  }

  // Initialize the user ID and fetch the farmer's need
  Future<void> initializeUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        currentUserId = user.uid;
        // Fetch the user document from Firestore
        var userDoc = await FirebaseFirestore.instance
            .collection('retailers')
            .doc(currentUserId)
            .get();

        print("Retrieved userId from FirebaseAuth: $currentUserId");
      } else {
        print("Error: userId is empty. Redirecting to login.");
        Navigator.pop(context); // Optionally redirect to login
      }
    } catch (e) {
      print("Error initializing userId: $e");
    }
    await _loadRequestStatuses();
  }

  Future<void> _loadRequestStatuses() async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('retailers')
          .doc(widget.currentUserId)
          .get();

      if (userDoc.exists) {
        // Get the list of sent requests from Firestore (assuming this is stored in 'requestsSent' field)
        List<dynamic> requestsSent = userDoc['requestsSent'] ?? [];

        // Set the request status to true for each follower in requestsSent
        for (var followerId in requestsSent) {
          setState(() {
            requestStatus[followerId] = true; // Mark as "Requested"
          });
        }
      }
    } catch (e) {
      print("Error loading request statuses: $e");
    }
  }

  // Switch tabs
  void _onTabSelected(int index) {
    _pageController.animateToPage(
      index,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentIndex = index;
    });
  }

  // Handle page change
  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  Future<void> _sendFollowRequest(String followerId, String collection) async {
    try {
      if (widget.currentUserId.isEmpty || followerId.isEmpty) {
        print('Error: User ID or follower ID is empty.');
        return; // Exit early if IDs are invalid
      }

      // Send the follow request to the target user's 'followRequests' array
      await FirebaseFirestore.instance
          .collection(collection) // Use target collection
          .doc(followerId)
          .set(
        {
          'followRequestsRetailer':
              FieldValue.arrayUnion([widget.currentUserId]),
        },
        SetOptions(merge: true), // Merge to avoid overwriting existing fields
      );

      // Update the current user's 'requestsSent' field
      await FirebaseFirestore.instance
          .collection('retailers') // Always update the 'farmers' collection
          .doc(widget.currentUserId)
          .set(
        {
          'requestsSent': FieldValue.arrayUnion([followerId]),
        },
        SetOptions(merge: true),
      );

      setState(() {
        _requestSent = true; // Update the UI to reflect the request being sent
      });

      print('Follow request sent successfully');
    } catch (e) {
      print('Error sending request: $e');
    }
  }

  // Unfollow a user
  Future<void> _unfollowUser(String userId, String collectionName) async {
    try {
      await FirebaseFirestore.instance
          .collection('retailers')
          .doc(widget.currentUserId)
          .update({
        'following': FieldValue.arrayRemove([
          {'userId': userId, 'collection': collectionName}
        ]),
      });

      await FirebaseFirestore.instance
          .collection(
              collectionName) // Specify the collection based on user type (donors/investors/retailers)
          .doc(userId)
          .update({
        'followers': FieldValue.arrayRemove([
          {'userId': widget.currentUserId, 'collection': 'farmers'}
        ]),
      });

      print('Unfollowed $userId');
    } catch (e) {
      print("Error unfollowing user: $e");
    }
  }

  // Remove a follower
  Future<void> _removeFollower(String followerId, String collectionName) async {
    try {
      await FirebaseFirestore.instance
          .collection('retailers')
          .doc(widget.currentUserId)
          .update({
        'followers': FieldValue.arrayRemove([
          {'userId': followerId, 'collection': collectionName}
        ]),
      });

      await FirebaseFirestore.instance
          .collection(
              collectionName) // Specify the collection based on user type (donors/investors/retailers)
          .doc(followerId)
          .update({
        'following': FieldValue.arrayRemove([
          {'userId': widget.currentUserId, 'collection': 'farmers'}
        ]),
      });

      print('Removed follower $followerId');
    } catch (e) {
      print("Error removing follower: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: IconButton(
              padding: EdgeInsets.only(top: 50, left: 16),
              icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () => _onTabSelected(0),
                      child: Text(
                        context
                            .watch<LocalizationService>()
                            .translate('followers'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              _currentIndex == 0 ? Colors.black : Colors.grey,
                          fontFamily: 'Alatsi',
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _onTabSelected(1),
                      child: Text(
                        context
                            .watch<LocalizationService>()
                            .translate('following'),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color:
                              _currentIndex == 1 ? Colors.black : Colors.grey,
                          fontFamily: 'Alatsi',
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Stack(
                  children: [
                    Container(
                      height: 2,
                      width: MediaQuery.of(context).size.width,
                      color: Colors.grey[300],
                    ),
                    AnimatedPositioned(
                      duration: Duration(milliseconds: 30),
                      left: _currentIndex == 0
                          ? MediaQuery.of(context).size.width * 0.10
                          : MediaQuery.of(context).size.width * 0.55,
                      child: Container(
                        width: MediaQuery.of(context).size.width * 0.35,
                        height: 2,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              children: [
                _buildFollowersPage(),
                _buildFollowingPage(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Build the followers page
  Widget _buildFollowersPage() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('retailers')
          .doc(widget.currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.green,
          ));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(
              child: Text(
            context.watch<LocalizationService>().translate('no_followers'),
            style: SmallTextGrey,
          ));
        }

        var userData = snapshot.data!;
        List<dynamic> followersList = List.from(userData['followers'] ?? []);

        if (followersList.isEmpty) {
          return Center(
              child: Text(
            context.watch<LocalizationService>().translate('no_followers'),
            style: SmallTextGrey,
          ));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: followersList.length,
          itemBuilder: (context, index) {
            String followerId = followersList[index]['userId'];
            String collectionName = followersList[index]['collection'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(
                      collectionName) // Get data from the correct collection based on user type
                  .doc(followerId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  ));
                }

                if (!userSnapshot.hasData || userSnapshot.data == null) {
                  return ListTile(
                      title: Text(context
                          .watch<LocalizationService>()
                          .translate('unknown_follower')));
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
                // Check if the current user has already followed this follower
                List<dynamic> followingList =
                    List.from(user['followers'] ?? []);
                bool isFollower = followingList.any((followers) =>
                    followers['userId'] == currentUserId &&
                    followers['collection'] == 'retailers');

                return ListTile(
                  title: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FarmerInRetailerDetailsScreen(
                            user: {
                              ...user.data()
                                  as Map<String, dynamic>, // Merge user data
                              'id': followerId, // Include userId
                            },
                            crops: user['crops'], // Correct follower data
                            currentUserId: widget.currentUserId,
                            currentUserCollection: 'retailers',
                          ),
                        ),
                      );
                    },
                    child: isFollower
                        ? FollowedUserCard(
                            username: username,
                            profileImageUrl: profileImageUrl,
                            onUnfollow: () {
                              _unfollowUser(followerId, collectionName);
                            },
                            onRemove: () {
                              _removeFollower(followerId, collectionName);
                            },
                          )
                        : UnfollowedUserCard(
                            username: username,
                            profileImageUrl: profileImageUrl,
                            requestSent: requestStatus[followerId] ?? false,
                            onSendRequest: () {
                              _sendFollowRequest(followerId, collectionName);
                              setState(() {
                                requestStatus[followerId] = true;
                              });
                            },
                            onRemove: () {
                              _removeFollower(followerId, collectionName);
                            },
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

  // Build the following page with mixed user types
  Widget _buildFollowingPage() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('retailers')
          .doc(widget.currentUserId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
              child: CircularProgressIndicator(
            color: Colors.green,
          ));
        }

        if (!snapshot.hasData || snapshot.data == null) {
          return Center(child: Text('No data available.'));
        }

        var userData = snapshot.data!;
        List<dynamic> followingList = List.from(userData['following'] ?? []);

        if (followingList.isEmpty) {
          return Center(
              child: Text(context
                  .watch<LocalizationService>()
                  .translate('no_following')));
        }

        return ListView.builder(
          padding: EdgeInsets.zero,
          itemCount: followingList.length,
          itemBuilder: (context, index) {
            String followingId = followingList[index]['userId'];
            String collectionName = followingList[index]['collection'];

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection(
                      collectionName) // Get data from the correct collection based on user type
                  .doc(followingId)
                  .get(),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child: CircularProgressIndicator(
                    color: Colors.white,
                  ));
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
                // Check if the current user has already followed this follower

                return ListTile(
                    title: GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FarmerInRetailerDetailsScreen(
                                user: {
                                  ...user.data() as Map<String,
                                      dynamic>, // Merge user data
                                  'id': followingId, // Include userId
                                },
                                crops: user['crops'], // Correct follower data
                                currentUserId: widget.currentUserId,
                                currentUserCollection: 'retailers',
                              ),
                            ),
                          );
                        },
                        child: FollowingUserCard(
                            username: username,
                            profileImageUrl: profileImageUrl,
                            onUnfollow: () {
                              _unfollowUser(followingId, collectionName);
                            })));
              },
            );
          },
        );
      },
    );
  }
}
