import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Retailer_HomePage/retailer_homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Customs/constants.dart';
import '../Donor_HomePage/donor_homepage.dart';
import '../Farmer_HomePage/farmer_homepage.dart';
import '../Investor_HomePage/investor_homepage.dart';
import 'language_selection_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), _checkUserRole);
  }

  Future<void> _checkUserRole() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        await _navigateToHomePage(user);
        return;
      }
    }

    // If user is not logged in or no role is found, navigate to LoginScreen
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LanguageSelectionScreen()),
    );
  }

  Future<void> _navigateToHomePage(User user) async {
    // Define a map with role-based collection names and their homepage destinations
    final Map<String, Widget Function(Map<String, dynamic>)> roleHomePages = {
      'farmers': (userData) => FarmerHomepage(userData: userData),
      'donors': (userData) => DonorHomepage(userData: userData),
      'investors': (userData) => InvestorHomepage(userData: userData),
      'retailers': (userData) => RetailerHomepage(userData: userData),
    };

    for (var entry in roleHomePages.entries) {
      String collection = entry.key;
      Widget Function(Map<String, dynamic>) homepageBuilder = entry.value;

      DocumentSnapshot<Map<String, dynamic>>? userDoc = await FirebaseFirestore
          .instance
          .collection(collection)
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get()
          .then((value) => value.docs.isNotEmpty ? value.docs.first : null)
          .catchError((_) => null);

      if (userDoc != null && userDoc.exists) {
        Map<String, dynamic> userData = _buildUserDataMap(userDoc, collection);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => homepageBuilder(userData)),
        );
        return;
      }
    }
  }

  // Helper method to build user data map with role-specific fields
  Map<String, dynamic> _buildUserDataMap(
      DocumentSnapshot<Map<String, dynamic>> userDoc, String collection) {
    Map<String, dynamic> userData = {
      'profileImageUrl': userDoc.data()?['profileImageUrl'] ?? '',
      'username': userDoc.data()?['username'] ?? '',
      'email': userDoc.data()?['email'] ?? '',
      'location': userDoc.data()?['location'] ?? '',
      'phoneNumber': userDoc.data()?['phoneNumber'] ?? '',
      'description': userDoc.data()?['description'] ?? '',
      'role': userDoc.data()?['role'] ?? '',
      'createdAt': userDoc.data()?['createdAt'] ?? '',
    };

    // Add additional role-specific fields
    if (collection == 'farmers') {
      userData.addAll({
        'landMapImageUrl': userDoc.data()?['landMapImageUrl'] ?? '',
        'liveStock': userDoc.data()?['liveStock'] ?? '',
        'waterFacility': userDoc.data()?['waterFacility'] ?? '',
        'request': userDoc.data()?['request'] ?? '',
        'requirement': userDoc.data()?['requirement'] ?? '',
      });
    } else if (collection == 'retailers') {
      userData['companyName'] = userDoc.data()?['companyName'] ?? '';
    }

    return userData;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: MainGreen,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'AgriNova',
                style: TitleStyle,
              ),
              SizedBox(
                height: 10,
              ),
              Text('an agriculture support platform', style: SmallTextWhite),
            ],
          ),
        ),
      ),
    );
  }
}
