import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Crop_Management/Crops/types_of_crops_homepage.dart';
import 'package:project_agrinova/src/screens/Retailer_HomePage/profit_management.dart';
import 'package:project_agrinova/src/screens/Retailer_HomePage/retailer_profile_screen.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Common_Pages/Chat_Bot/chat_bot.dart';
import '../Customs/constants.dart';
import '../Customs/farmer_in_retailer_page_container.dart';
import '../Customs/slide_right_animation.dart';
import '../User Class/user.dart' as customUser;
import 'farmer_in_retailer_details_screen.dart';
import 'follow_request_page_retailer.dart';
import 'package:badges/badges.dart' as badges;
import 'package:badges/badges.dart';

class RetailerHomepage extends StatefulWidget {
  final Map<String, dynamic> userData; // Accept user data as parameter

  const RetailerHomepage({super.key, required this.userData});

  @override
  State<RetailerHomepage> createState() => _RetailerHomepageState();
}

class _RetailerHomepageState extends State<RetailerHomepage> {
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
    _scrollController = ScrollController(); // Initialize the scroll controller
    _searchController.addListener(_onSearchChanged); // 👈 Listen to search
    fetchFarmerDetails().then((users) {
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
          .collection('retailers')
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

  Future<List<customUser.User>> fetchFarmerDetails() async {
    List<customUser.User> allUsers = [];
    try {
      // Fetch Farmers
      var farmerDocs =
          await FirebaseFirestore.instance.collection('farmers').get();
      var farmers = farmerDocs.docs
          .map((doc) {
            final data = doc.data(); // Get document data
            if ((data['crops'] ?? []).isEmpty) {
              // Skip farmers with no crops
              return null;
            }
            print("Farmer Data: $data"); // Debug log
            return customUser.Farmer.fromMap({
              'id': doc.id,
              'profileImageUrl': data['profileImageUrl'] ?? '',
              'username': data['username'] ?? '',
              'role': data['role'] ?? 'Farmer',
              'phoneNumber': data['phoneNumber'] ?? '',
              'location': data['location'] ?? '',
              'email': data['email'] ?? '',
              'landMapImageUrl': data['landMapImageUrl'] ?? '',
              'request': data['request'] ?? '',
              'requirement': data['requirement'] ?? '',
              'crops': data['crops'] ?? [],
              'description': data['description'] ?? '',
              // Add crops data
            });
          })
          .whereType<customUser.User>()
          .toList();

      allUsers.addAll(farmers);
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
                                page:
                                    RetailerProfileScreen(userData: userData!),
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
                                builder: (context) =>
                                    FollowRequestsPageRetailer(
                                        currentUserId:
                                            userData?['userId'] ?? ''),
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
                  final farmer = allUsers[index];
                  final crops = (farmer as customUser.Farmer).crops;
// Access crops

                  return Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  FarmerInRetailerDetailsScreen(
                                user: farmer.toMap(),
                                crops: crops,
                                currentUserId: userData?['userId'] ??
                                    '', // Pass the current user's ID
                                currentUserCollection:
                                    'retailers', // Pass crops to details screen
                              ),
                            ),
                          );
                        },
                        child: FarmerInRetailerPageContentContainer(
                          context: context,
                          user: farmer,
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
}

class ButtonsHeaderDelegate extends SliverPersistentHeaderDelegate {
  final VoidCallback onHomeTap; // Callback for the home button tap

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
                  SizedBox(width: 55),
                  circularImageButtonWithText(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TypesOfCropsHomepage(),
                      ),
                    );
                  }, 'assets/images/croptypesicon.png',
                      '${context.watch<LocalizationService>().translate('crop_types')}\n'),
                  SizedBox(width: 40),
                  circularImageButtonWithText(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfitManagement(),
                      ),
                    );
                  }, 'assets/images/profiticon.png',
                      '${context.watch<LocalizationService>().translate('profit_management')}\n'),
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
