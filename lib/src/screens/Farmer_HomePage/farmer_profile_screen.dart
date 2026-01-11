import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Language/app_localization.dart';
import '../Authentication/login_screen.dart';
import '../Common_Pages/About/about_screen.dart';
import '../Common_Pages/Settings/settings_screen.dart';
import '../Customs/constants.dart';
import '../Customs/profile_photo_container.dart';
import '../Customs/profilemenu_widget.dart';
import '../Customs/slide_left_animation.dart';
import 'farmer_editProfile_screen.dart';
import 'farmer_message_screen.dart';
import 'following_and_followers_page.dart';

class FarmerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const FarmerProfileScreen({super.key, required this.userData});

  @override
  _FarmerProfileScreenState createState() => _FarmerProfileScreenState();
}

class _FarmerProfileScreenState extends State<FarmerProfileScreen> {
  late String? profileImageUrl;
  late Map<String, dynamic> currentUserData;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Initialize with the passed data immediately
    currentUserData = widget.userData;
    profileImageUrl = widget.userData['profileImageUrl'];

    // Only set loading if we're going to fetch fresh data
    if (currentUser != null) {
      setState(() {
        isLoading = true; // Show loading while we fetch updates
      });

      FirebaseFirestore.instance
          .collection('farmers')
          .doc(currentUser!.uid)
          .snapshots()
          .listen((documentSnapshot) {
        if (documentSnapshot.exists) {
          if (mounted) {
            setState(() {
              currentUserData = documentSnapshot.data()!;
              profileImageUrl = currentUserData!['profileImageUrl'];
              isLoading = false;
            });
          }
        }
      }, onError: (error) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
        }
      });
    }
  }

  Future<void> _deleteAccount() async {
    // Get localization service before showing dialog
    final localization =
        Provider.of<LocalizationService>(context, listen: false);

    final confirmed = await showDialog(
      barrierColor: Colors.transparent.withOpacity(.6),
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey.shade100,
        title: Text(
          localization.translate('confirm_delete'),
          style: TextBlack,
        ),
        content: Text(
          localization.translate('delete_account_warning'),
          style: SmallTextGrey,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              localization.translate('cancel'),
              style: SmallTextGrey,
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(localization.translate('delete'), style: SmallTextRed),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        setState(() {
          isLoading = true;
        });

        await FirebaseFirestore.instance
            .collection('farmers')
            .doc(currentUser!.uid)
            .delete();

        await currentUser!.delete();

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.clear();

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false,
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text(localization.translate('account_deleted_successfully')),
            backgroundColor: Colors.green.withOpacity(0.9),
          ),
        );
      } catch (e) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.green.withOpacity(0.9),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading && currentUserData == null) {
      return Scaffold(
        backgroundColor: Colors.grey[200],
        body: Center(
          child: CircularProgressIndicator(color: MainGreen),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 20),
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    padding: EdgeInsets.only(top: 45),
                    icon: Icon(Icons.arrow_back_ios, color: Colors.grey),
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
                    context.watch<LocalizationService>().translate('profile'),
                    style: NormalTextBlack,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.topRight,
                  padding: EdgeInsets.only(top: 45),
                  child: PopupMenuButton<String>(
                    color: Colors.grey.shade100,
                    icon: Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteAccount();
                      }
                    },
                    itemBuilder: (BuildContext context) {
                      // Get the localization service once
                      final localization = Provider.of<LocalizationService>(
                          context,
                          listen: false);

                      return [
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            localization.translate('delete_account'),
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ];
                    },
                  ),
                ),
              )
            ],
          ),
          // User Info Section
          SizedBox(height: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ProfilePhotoWidget(
                profileImageUrl: profileImageUrl,
                onPressed: null, // Remove the onPressed functionality
                showIcon:
                    false, // Ensure the edit icon is hidden in your widget
              ),
              SizedBox(height: 10),
              Text(
                  '${currentUserData['username'] ?? context.watch<LocalizationService>().translate('loading')}',
                  style: NormalTextBlack),
              Text(
                  '${currentUserData['email'] ?? context.watch<LocalizationService>().translate('loading')}',
                  style: SmallTextGrey),
              SizedBox(height: 20),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () async {
                  // Navigate to edit profile screen and wait for result
                  final updatedData = await Navigator.of(context).push(
                    SlideLeftRoute(
                      page: FarmerEditprofileScreen(userData: currentUserData),
                    ),
                  );

                  // If there's updated data, update the state
                  if (updatedData != null &&
                      updatedData is Map<String, dynamic>) {
                    setState(() {
                      currentUserData = updatedData; // Update user data
                      profileImageUrl = updatedData['profileImageUrl'];
                    });
                  }
                },
                child: Text(
                    context
                        .watch<LocalizationService>()
                        .translate('edit_profile_btn'),
                    style: SmallTextWhite),
                style: ElevatedButton.styleFrom(
                  elevation: 7,
                  shadowColor: Colors.blue,
                  fixedSize: Size(310, 50),
                  backgroundColor: Color(0xff1ACD36),
                ),
              ),
            ],
          ),
          SizedBox(height: 5),
          Divider(color: Colors.grey.withOpacity(0.1)),
          SizedBox(height: 5),
          ProfileWidget(
            title: context.watch<LocalizationService>().translate('messages'),
            icon: Icons.message,
            onPress: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FarmerMessageScreen(),
                  ));
            },
            textStyle: SmallTextGrey,
          ),
          SizedBox(height: 5),
          Divider(color: Colors.grey.withOpacity(0.1)), SizedBox(height: 5),
          ProfileWidget(
            title: context.watch<LocalizationService>().translate('settings'),
            icon: Icons.settings,
            onPress: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        SettingsScreen(collectionName: "farmers"),
                  ));
            },
            textStyle: SmallTextGrey,
          ),
          SizedBox(height: 5),
          Divider(color: Colors.grey.withOpacity(0.1)),
          SizedBox(height: 5),
          ProfileWidget(
            title: context.watch<LocalizationService>().translate('about'),
            icon: Icons.info,
            onPress: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AboutPage(),
                  ));
            },
            textStyle: SmallTextGrey,
          ),
          SizedBox(height: 5),
          Divider(color: Colors.grey.withOpacity(0.1)),
          SizedBox(height: 5),
          ProfileWidget(
            title: context
                .watch<LocalizationService>()
                .translate('followers_following'),
            icon: Icons.people,
            onPress: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FollowersFollowingScreen(
                      currentUserId: currentUser!.uid,
                    ),
                  ));
            },
            textStyle: SmallTextGrey,
          ),
          SizedBox(height: 5), Divider(color: Colors.grey.withOpacity(0.1)),

          SizedBox(height: 5),
          ProfileWidget(
            title: context.watch<LocalizationService>().translate('logout'),
            icon: Icons.logout,
            onPress: () async {
              await FirebaseAuth.instance.signOut();
              SharedPreferences prefs = await SharedPreferences.getInstance();
              await prefs.setBool('isLoggedIn', false);

              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            textStyle: SmallTextRed,
          ),
          SizedBox(height: 10),
        ],
      ),
    );
  }
}
