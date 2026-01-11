import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Schemes/government_schemes_homepage.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Common_Pages/Chat_Bot/chat_bot.dart';
import '../Common_Pages/Crop_Management/Crop_Management_HomePage.dart';
import '../Common_Pages/Livestocks/types_of_livestock_homepage.dart';
import '../Common_Pages/Products/agricultural_products_homepage.dart';
import '../Customs/constants.dart';
import '../Customs/farmer_page_container.dart';
import '../Customs/investor_donor_page_container.dart';
import '../Customs/slide_right_animation.dart';
import '../Farmer_HomePage/investor_donor_details_screen.dart';
import '../User Class/user.dart' as customUser;
import 'donor_profile_screen.dart';
import 'farmer_details_screen.dart';
import 'follow_request_page_donor.dart';
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';

class DonorHomepage extends StatefulWidget {
  final Map<String, dynamic> userData; // Accept user data as parameter

  const DonorHomepage({
    super.key,
    required this.userData,
  });
  @override
  State<DonorHomepage> createState() => _DonorHomepageState();
}

class _DonorHomepageState extends State<DonorHomepage> {
  @override
  Map<String, dynamic>? userData;
  List<customUser.User> allUsers = []; // Use your custom User class here
  late ScrollController _scrollController; // Add ScrollController
  int _followRequestCount = 0; // Track the count of follow requests
  bool _hasFollowRequests = false;
  String currentUserID = '';
  TextEditingController _searchController = TextEditingController();
  List<customUser.User> filteredUsers = [];
  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    _scrollController = ScrollController();
    // Initialize the scroll controller
    _searchController.addListener(_onSearchChanged); // 👈 Listen to search

    fetchFarmerswithDonation().then((users) {
      setState(() {
        allUsers = users; // Store the fetched users in your state
      });
    });
    _getFollowRequestCount();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredUsers = allUsers.where((user) {
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

  Future<void> _getFollowRequestCount() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('donors')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> requests = userDoc['followRequests'] ?? [];

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

  Future<List<customUser.User>> fetchFarmerswithDonation() async {
    List<customUser.User> allUsers = [];
    try {
      // Fetch Donors
      var farmerDocs =
          await FirebaseFirestore.instance.collection('farmers').get();
      var farmers = farmerDocs.docs.map((doc) {
        final data = doc.data(); // Get document data
        print("Farmer Data: $data"); // Debug log
        return customUser.Farmer.fromMap({
          'id': doc.id,
          'profileImageUrl': data['profileImageUrl'] ?? '',
          'username': data['username'] ?? '',
          'role': data['role'] ?? '',
          'description': data['description'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'location': data['location'] ?? '',
          'landMapImageUrl': data['landMapImageUrl'] ?? '',
          'liveStock': data['liveStock'] ?? '',
          'waterFacility': data['waterFacility'] ?? '',
          'request': data['request'] ?? '',
          'requirement': data['requirement'] ?? '',
          'email': data['email'] ?? '',
        });
      }).toList();

      allUsers.addAll(farmers.where((farmer) {
        return (farmer as customUser.Farmer).request == 'Donation';
      }).toList());

      // Fetch Investors
    } catch (e) {
      print("Error fetching users: $e"); // Log any errors
    }

    return allUsers;
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0, // Scroll to top
      duration:
          const Duration(milliseconds: 200), // Set a duration for the scroll
      curve: Curves.linear, // Set a smooth curve
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 15, right: 15),
        child: FloatingActionButton(
          backgroundColor: MainGreen,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatBot(),
              ),
            );
          },
          shape: CircleBorder(),
          child: Image(
            image: AssetImage('assets/images/bot.png'),
            height: 50, // Reduced height of the image
            width: 45, // Reduced width of the image
          ),
        ),
      ),
      backgroundColor: const Color(0xff1acd36),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController, // Attach the scroll controller
          slivers: [
            // AppBar that hides on scroll
            SliverAppBar(
              backgroundColor: MainGreen,
              floating: true,
              pinned: false, // Hides when scrolling down
              expandedHeight: 70.0,
              automaticallyImplyLeading: false,
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(top: 0, bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            if (userData != null) {
                              Navigator.of(context).push(SlideRightRoute(
                                page: DonorProfileScreen(userData: userData!),
                              ));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    Provider.of<LocalizationService>(context,
                                            listen: false)
                                        .translate('email_error_empty'),
                                  ),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(left: 10),
                            height: 35,
                            child: Image.asset('assets/images/menu bar.png'),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Text(
                          context
                              .watch<LocalizationService>()
                              .translate('app_name'),
                          style: TitleStyle,
                          textAlign: TextAlign.center,
                          // Use your custom style here
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FollowRequestsPageDonor(
                                    currentUserId: userData?['userId'] ?? ''),
                              ),
                            );
                            _getFollowRequestCount(); // Refresh the badge count
                          },
                          icon: badges.Badge(
                            position: badges.BadgePosition.custom(
                                bottom: 10, start: 17),
                            showBadge: _hasFollowRequests,
                            // Show badge only if there are follow requests
                            badgeContent: Text(
                              _followRequestCount.toString(),
                              // Display count of follow requests
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
                    ],
                  ),
                ),
              ),
            ),
            // Pinned area for the six buttons
            SliverPersistentHeader(
              pinned: true, // Keeps the buttons fixed
              delegate: ButtonsHeaderDelegate(
                onHomeTap: () {
                  _scrollToTop(); // Scroll to top when Home is tapped
                },
              ),
            ),
            // Scrollable content below the buttons
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
                  final usersToDisplay =
                      _searchController.text.isEmpty ? allUsers : filteredUsers;
                  if (index >= usersToDisplay.length) return null;
                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FarmerDetailsScreen(
                                user: allUsers[index].toMap(),
                                currentUserId: userData?['userId'] ??
                                    '', // Pass the current user's ID
                                currentUserCollection:
                                    'donors', // Pass the user data
                              ),
                            ),
                          );
                        }, // Navigate to user details on tap
                        child: InvestorDonorPageContentContainer(
                            context: context,
                            user: allUsers[
                                index]), // Pass user data to ContentContainer
                      ),
                      const SizedBox(
                          height: 10), // Add space after each container
                    ],
                  );
                },
                childCount: _searchController.text.isEmpty
                    ? allUsers.length
                    : filteredUsers.length,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ButtonsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onHomeTap;
  ButtonsHeaderDelegate({required this.onHomeTap});

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Column(
      children: [
        Container(
          color: MainGreen,
          padding: const EdgeInsets.only(top: 10, bottom: 0),
          child: Consumer<LocalizationService>(
              builder: (context, localizationService, child) {
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.only(left: 17, right: 10),
              child: Row(
                children: [
                  circularImageButtonWithText(
                    onHomeTap, // Trigger scroll to top when Home is tapped
                    'assets/images/homebar.png',
                    context.watch<LocalizationService>().translate('home'),
                  ),
                  SizedBox(width: 10),
                  circularImageButtonWithText(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CropManagementHomepage(),
                      ),
                    );
                  },
                      'assets/images/cropmanageicon.png',
                      context
                          .watch<LocalizationService>()
                          .translate('crop_management')),
                  SizedBox(width: 10),
                  circularImageButtonWithText(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AgriculturalProductsHomepage(),
                      ),
                    );
                  },
                      'assets/images/producticon.png',
                      context
                          .watch<LocalizationService>()
                          .translate('products')),
                  SizedBox(width: 10),
                  circularImageButtonWithText(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TypesOfLivestockHomepage(),
                      ),
                    );
                  },
                      'assets/images/liveStocksicon.png',
                      context
                          .watch<LocalizationService>()
                          .translate('live_stocks')),
                  SizedBox(width: 10),
                  circularImageButtonWithText(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GovernmentSchemesHomepage(),
                      ),
                    );
                  },
                      'assets/images/schemesicon.png',
                      context
                          .watch<LocalizationService>()
                          .translate('schemes')),
                ],
              ),
            );
          }),
        ),
        Line,
      ],
    );
  }

  @override
  double get maxExtent => 115.0; // Height of the header when expanded
  @override
  double get minExtent => 110.0; // Height of the header when collapsed
  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) => false;
}
