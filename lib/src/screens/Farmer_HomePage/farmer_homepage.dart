import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Livestocks/types_of_livestock_homepage.dart';
import 'package:project_agrinova/src/screens/Farmer_HomePage/follow_request_page_farmer.dart';
import 'package:project_agrinova/src/screens/Farmer_HomePage/retailers_page.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Common_Pages/Chat_Bot/chat_bot.dart';
import '../Common_Pages/Crop_Management/Crop_Management_HomePage.dart';
import '../Common_Pages/Products/agricultural_products_homepage.dart';
import '../Common_Pages/Schemes/government_schemes_homepage.dart';
import '../Customs/constants.dart'; // Update this import to match your project structure
import '../Customs/farmer_page_container.dart';
import '../Customs/slide_right_animation.dart'; // Update this import to match your project structure
import '../User Class/user.dart'
    as customUser; // Use an alias for your custom User class
import 'farmer_profile_screen.dart'; // Update this import to match your project structure
import 'investor_donor_details_screen.dart'; // Update this import to match your project structure
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';

class FarmerHomepage extends StatefulWidget {
  final Map<String, dynamic> userData;

  const FarmerHomepage({super.key, required this.userData});

  @override
  State<FarmerHomepage> createState() => _FarmerHomepageState();
}

class _FarmerHomepageState extends State<FarmerHomepage> {
  Map<String, dynamic>? userData;
  List<customUser.User> allUsers = []; // Use your custom User class here
  late ScrollController _scrollController; // Add ScrollController
  int _followRequestCount = 0; // Track the count of follow requests
  bool _hasFollowRequests = false;
  String currentUserID = '';
  late LocalizationService localization;
  TextEditingController _searchController = TextEditingController();
  List<customUser.User> filteredUsers = [];

  @override
  void initState() {
    super.initState();
    userData = widget.userData;

    // Fetch the language first
    _fetchUserLanguage().then((_) {
      setState(() {}); // Rebuild UI after language is loaded
    });

    _scrollController = ScrollController();
    _searchController.addListener(_onSearchChanged); // 👈 Listen to search

    fetchDonorsAndInvestors().then((users) {
      setState(() {
        allUsers = users;
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

  Future<void> _fetchUserLanguage() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('farmers')
            .doc(user.uid)
            .get();

        if (userDoc.exists && userDoc.data() != null) {
          String languageCode =
              (userDoc.data() as Map<String, dynamic>)['language'] ?? 'en';
          print("Language:$languageCode");
          if (mounted) {
            await Provider.of<LocalizationService>(context, listen: false)
                .setLanguage(languageCode); // Set language correctly
          }
        }
      }
    } catch (e) {
      print("Error fetching language: $e");
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

  Future<List<customUser.User>> fetchDonorsAndInvestors() async {
    List<customUser.User> allUsers = [];
    try {
      // Fetch Donors
      var donorDocs =
          await FirebaseFirestore.instance.collection('donors').get();
      var donors = donorDocs.docs.map((doc) {
        final data = doc.data(); // Get document data
        print("Donor Data: $data"); // Debug log
        return customUser.Donor.fromMap({
          'id': doc.id,
          'profileImageUrl': data['profileImageUrl'] ?? '',
          'username': data['username'] ?? '',
          'role': data['role'] ?? '',
          'description': data['description'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'location': data['location'] ?? '',
          'email': data['email'] ?? '',
        });
      }).toList();

      allUsers.addAll(donors);

      // Fetch Investors
      var investorDocs =
          await FirebaseFirestore.instance.collection('investors').get();
      var investors = investorDocs.docs.map((doc) {
        final data = doc.data(); // Get document data
        print("Investor Data: $data"); // Debug log
        return customUser.Investor.fromMap({
          'id': doc.id,
          'profileImageUrl': data['profileImageUrl'] ?? '',
          'username': data['username'] ?? '',
          'role': data['role'] ?? '',
          'description': data['description'] ?? '',
          'phoneNumber': data['phoneNumber'] ?? '',
          'location': data['location'] ?? '',
          'email': data['email'] ?? '',
        });
      }).toList();

      allUsers.addAll(investors);
    } catch (e) {
      print("Error fetching users: $e"); // Log any errors
    }

    return allUsers;
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
              pinned: false,
              // Hides when scrolling down
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
                                page: FarmerProfileScreen(userData: userData!),
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
                                builder: (context) => FollowRequestsPageFarmer(
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
                onRetailersTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          FarmerRetailerPage(userId: userData?['userId'] ?? ''),
                    ),
                  );
                },
              ),
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

            // Scrollable content below the buttons
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
                              builder: (context) => InvestorDonorDetailsScreen(
                                user: usersToDisplay[index].toMap(),
                                currentUserId: userData?['userId'] ?? '',
                                currentUserCollection: 'farmers',
                              ),
                            ),
                          );
                        },
                        child: FarmerPageContentContainer(
                          context: context,
                          user: usersToDisplay[index],
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  );
                },
                childCount: _searchController.text.isEmpty
                    ? allUsers.length
                    : filteredUsers.length,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to scroll to the top
  void _scrollToTop() {
    _scrollController.animateTo(
      0, // Scroll to top
      duration:
          const Duration(milliseconds: 200), // Set a duration for the scroll
      curve: Curves.linear, // Set a smooth curve
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

// This delegate controls the behavior of the six buttons
class ButtonsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onHomeTap; // Callback for the home button tap
  final Function() onRetailersTap; // Callback for Retailers button

  ButtonsHeaderDelegate({
    required this.onHomeTap,
    required this.onRetailersTap, // Pass the new callback
  });

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
                  SizedBox(width: 10),
                  circularImageButtonWithText(
                      onRetailersTap,
                      'assets/images/retailersicon.png',
                      context
                          .watch<LocalizationService>()
                          .translate('retailers')), // Use callback
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
