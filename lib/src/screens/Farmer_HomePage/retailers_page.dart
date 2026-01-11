import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_agrinova/src/screens/Farmer_HomePage/follow_request_page_farmer_retailer.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/farmer_page_container.dart';
import '../Customs/farmer_retailer_container.dart';
import '../User Class/user.dart' as customUser;
import 'farmer_retailer_detail_screen.dart';
import 'mange_crop_yield_page.dart';
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';

class FarmerRetailerPage extends StatefulWidget {
  final String userId; // Farmer's user ID

  const FarmerRetailerPage({super.key, required this.userId});

  @override
  _FarmerRetailerPage createState() => _FarmerRetailerPage();
}

class _FarmerRetailerPage extends State<FarmerRetailerPage> {
  String userId = ''; // Holds the current user's ID
  List<customUser.User> allRetailers = []; // List of retailers
  List<dynamic> farmerCrops = []; // Farmer's crops
  int _followRequestCount = 0; // Track the count of follow requests
  bool _hasFollowRequests = false;
  TextEditingController _searchController = TextEditingController();
  List<customUser.User> filteredUsers = [];
  @override
  void initState() {
    super.initState();
    initializeUserId();
    // fetchRetailers().then((users) {
    //   setState(() {
    //     allRetailers = users; // Store the fetched users in your state
    //   });
    // }); // Fetch userId during initialization
    _searchController.addListener(_onSearchChanged); // 👈 Listen to search

    _getFollowRequestCount();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allRetailers.where((user) {
        final userMap =
            user.toMap(); // Convert user to Map for easy field access
        return userMap.values.any((value) {
          if (value is String) {
            return value.toLowerCase().contains(query);
          }
          return false;
        });
      }).toList();
    });
  }

  // Initialize userId from FirebaseAuth or SharedPreferences
  Future<void> initializeUserId() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid; // Fetch userId from FirebaseAuth
        print("Retrieved userId from FirebaseAuth: $userId");
      } else {}

      if (userId.isEmpty) {
        print("Error: userId is empty. Redirecting to login.");
        // Optionally redirect to login
        Navigator.pop(context);
        return;
      }

      // Fetch additional data after userId is initialized
      fetchRetailers();
      fetchFarmerCrops();
    } catch (e) {
      print("Error initializing userId: $e");
    }
  }

  Future<void> _getFollowRequestCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> requests = userDoc['followRequestsRetailer'] ?? [];

        if (mounted) {
          setState(() {
            _followRequestCount = requests.length;
            _hasFollowRequests = _followRequestCount > 0;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _followRequestCount = 0;
          _hasFollowRequests = false;
        });
      }
      print("Error getting follow requests: $e");
    }
  }

  // Fetch farmer's crops from Firestore
  Future<void> fetchFarmerCrops() async {
    try {
      if (userId.isEmpty) {
        print("Error: userId is empty, cannot fetch crops.");
        return;
      }

      final farmerDoc = await FirebaseFirestore.instance
          .collection('farmers')
          .doc(userId)
          .get();

      if (farmerDoc.exists) {
        setState(() {
          farmerCrops = farmerDoc.data()?['crops'] ?? [];
        });
      } else {
        print("Farmer document does not exist.");
      }
    } catch (e) {
      print("Error fetching farmer's crops: $e");
    }
  }

  // Fetch retailer data from Firestore
// Fetch retailer data from Firestore
  fetchRetailers() async {
    try {
      setState(() {
        allRetailers.clear(); // Clear existing retailers to avoid duplication
      });

      final retailerDocs =
          await FirebaseFirestore.instance.collection('retailers').get();
      final fetchedRetailers = retailerDocs.docs.map((doc) {
        final data = doc.data();
        print('Retailer data: ${data}');
        return customUser.Retailer.fromMap({
          'id': doc.id,
          'profileImageUrl': data['profileImageUrl'] ?? '',
          'username': data['username'] ?? '',
          'role': 'Retailer',
          'description': data['description'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'location': data['location'] ?? '',
          'email': data['email'] ?? '',
          'companyName': data['companyName'] ?? 'Unknown Company',
          'cropReqd': data['cropReqd'] ?? 'N/A',
        });
      }).toList();

      setState(() {
        allRetailers.addAll(fetchedRetailers); // Add fetched retailers
      });
    } catch (e) {
      print("Error fetching retailers: $e");
    }
  }

  // Fetch farmer's crops from Firestore

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1acd36), // Green background
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // SliverAppBar for the header
            SliverAppBar(
              floating: true,
              pinned: false,
              backgroundColor: const Color(0xff1acd36),
              expandedHeight: 90.0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: IconButton(
                            padding: EdgeInsets.only(top: 0),
                            icon:
                                Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
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
                      ),
                      Expanded(
                        flex: 1,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      FollowRequestsPageFarmerRetailer(
                                          currentUserId: userId ?? ''),
                                ),
                              );
                              _getFollowRequestCount(); // Refresh the badge count
                            },
                            icon: badges.Badge(
                              position: badges.BadgePosition.custom(
                                  bottom: 10, start: 17),
                              showBadge:
                                  _hasFollowRequests, // Show badge only if there are follow requests
                              badgeContent: Text(
                                _followRequestCount
                                    .toString(), // Display count of follow requests
                                style: TextStyle(color: Colors.white),
                              ),
                              badgeStyle: BadgeStyle(
                                badgeColor: Colors.red, // Badge color
                                padding: EdgeInsets.all(4),
                                // Padding around the badge content
                              ),
                              child: Icon(
                                Icons.notifications_none_outlined,
                                size: 30,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // SliverPersistentHeader for the fixed "Manage Crop Yield" button
            SliverPersistentHeader(
              pinned: true,
              delegate: _ManageCropYieldHeader(onTap: () {
                // Navigate to Manage Crop Yield Page with farmer crops
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ManageCropYieldPage(
                        userId: userId, // Pass the correct userId here
                        crops: farmerCrops,
                      ),
                    ));
              }),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  cursorColor: MainGreen,
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintStyle: NormalTextGrey,
                    hintText: context
                            .watch<LocalizationService>()
                            .translate('search_users') ??
                        'Search by name or location',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                    contentPadding: EdgeInsets.symmetric(vertical: 0),
                  ),
                ),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  final usersToDisplay = _searchController.text.isEmpty
                      ? allRetailers
                      : filteredUsers;
                  if (index >= usersToDisplay.length) return null;

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RetailerDetailsScreen(
                                user: allRetailers[index].toMap(),
                                currentUserId:
                                    userId ?? '', // Pass the current user's ID
                                currentUserCollection:
                                    'farmers', // Pass the user data
                              ),
                            ),
                          );
                        }, // Navigate to user details on tap
                        child: FarmerRetailerContainer(
                            user: allRetailers[
                                index]), // Pass user data to ContentContainer
                      ),
                      const SizedBox(
                          height: 10), // Add space after each container
                    ],
                  );
                },
                childCount: _searchController.text.isEmpty
                    ? allRetailers.length
                    : filteredUsers.length,
              ),
            )
            // Retailers List
          ],
        ),
      ),
    );
  }
}

// Delegate for the SliverPersistentHeader to show "Manage Crop Yield" button
class _ManageCropYieldHeader extends SliverPersistentHeaderDelegate {
  final VoidCallback onTap;

  _ManageCropYieldHeader({required this.onTap});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        Container(
          color: MainGreen,
          padding: const EdgeInsets.only(top: 10, bottom: 10),
          constraints: BoxConstraints(maxWidth: double.infinity),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 10, right: 10),
            child: Row(
              children: [
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    elevation: 5,
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        vertical: 15, horizontal: 70),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                  child: Text(
                    context
                        .watch<LocalizationService>()
                        .translate('manage_crop_yield'),
                    style: SmallTextGrey,
                    textAlign: TextAlign.center,
                  ),
                ),
                // Use callback
              ],
            ),
          ),
        ),
        Line,
      ],
    );
  }

  @override
  double get maxExtent => 100.0; // Height of the header when expanded
  @override
  double get minExtent => 90.0; // Height of the header when collapsed
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
