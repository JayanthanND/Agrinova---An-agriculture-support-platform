import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lottie/lottie.dart';
import 'package:project_agrinova/src/screens/Authentication/register_screen.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:project_agrinova/src/screens/Farmer_HomePage/farmer_homepage.dart';
import 'package:project_agrinova/src/screens/Retailer_HomePage/retailer_homepage.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Language/app_localization.dart';
import '../Donor_HomePage/donor_homepage.dart';
import '../Investor_HomePage/investor_homepage.dart';
import 'forgotpassword_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance; // Firebase Auth instance
  bool _obscurePassword = true; // Add this to your State class

  Future<void> _login() async {
    try {
      // Show the loading dialog
      showDialog(
          context: context,
          builder: (context) {
            return SpinKitCircle(
              color: MainGreen,
            );
          });

      // Check for empty email/password
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.trim().isEmpty) {
        Navigator.of(context).pop(); // Dismiss the loading dialog
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Email and Password cannot be empty!')),
        );
        return; // Exit if fields are empty
      }

      // Authenticate user using Firebase Auth
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      if (user != null) {
        // Save login state in Shared Preferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true); // Save login state

        String? selectedLanguage = prefs.getString('language') ?? 'en';

        // Function to update Firestore with language preference
        Future<void> updateUserLanguage(String collection) async {
          await FirebaseFirestore.instance
              .collection(collection)
              .where('email', isEqualTo: user.email)
              .get()
              .then((querySnapshot) {
            if (querySnapshot.docs.isNotEmpty) {
              querySnapshot.docs.first.reference
                  .update({'language': selectedLanguage});
            }
          });
        }

        DocumentSnapshot? userDoc;

        // Check Farmers collection
        userDoc = await FirebaseFirestore.instance
            .collection('farmers')
            .where('email', isEqualTo: user.email)
            .get()
            .then((value) {
          return value.docs.isNotEmpty ? value.docs.first : null;
        });

        if (userDoc != null) {
          await updateUserLanguage('farmers'); // Store language for farmer
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            Navigator.of(context)
                .pop(); // Dismiss the loading dialog before navigating
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FarmerHomepage(userData: userData),
              ),
            );
          }
          return; // Exit the method
        }

        // Check Donors collection
        userDoc = await FirebaseFirestore.instance
            .collection('donors')
            .where('email', isEqualTo: user.email)
            .get()
            .then((value) {
          return value.docs.isNotEmpty ? value.docs.first : null;
        });

        if (userDoc != null) {
          await updateUserLanguage('donors'); // Store language for donor
          // The user is a donor
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            Navigator.of(context)
                .pop(); // Dismiss the loading dialog before navigating
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => DonorHomepage(userData: userData),
              ),
            );
          }
          return; // Exit the method
        }

        // Check Investors collection
        userDoc = await FirebaseFirestore.instance
            .collection('investors')
            .where('email', isEqualTo: user.email)
            .get()
            .then((value) {
          return value.docs.isNotEmpty ? value.docs.first : null;
        });

        if (userDoc != null) {
          await updateUserLanguage('investors'); // Store language for investor
          // The user is an investor
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            Navigator.of(context)
                .pop(); // Dismiss the loading dialog before navigating
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => InvestorHomepage(userData: userData),
              ),
            );
          }
          return; // Exit the method
        }

        // Check Retailers collection
        userDoc = await FirebaseFirestore.instance
            .collection('retailers')
            .where('email', isEqualTo: user.email)
            .get()
            .then((value) {
          return value.docs.isNotEmpty ? value.docs.first : null;
        });

        if (userDoc != null) {
          await updateUserLanguage('retailers'); // Store language for retailer
          // The user is a retailer
          Map<String, dynamic>? userData =
              userDoc.data() as Map<String, dynamic>?;

          if (userData != null) {
            Navigator.of(context)
                .pop(); // Dismiss the loading dialog before navigating
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => RetailerHomepage(userData: userData),
              ),
            );
          }
          return; // Exit the method
        }

        // If no user document is found in any of the collections
        Navigator.of(context)
            .pop(); // Dismiss the loading dialog if no role is found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User role not found!')),
        );
      }
    } catch (e) {
      Navigator.of(context).pop(); // Dismiss the loading dialog on error
      print("Login failed: $e");
      // Provide user feedback on login failure
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Center(child: Text('Login Failed: User ')),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Color(0xff1ACD36),
        body: Center(
            child: SingleChildScrollView(
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
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Line,
                    MainContainer(
                      child: Column(
                        children: [
                          Positioned.fill(
                            child: Lottie.asset(
                              'assets/farmer.json',
                              fit: BoxFit.cover,
                              repeat: true,
                              width: 180,
                            ),
                          ),
                          Text(
                            context
                                .watch<LocalizationService>()
                                .translate('login'),
                            style: NormalTextBlack,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputFieldBox(
                              context
                                  .watch<LocalizationService>()
                                  .translate('email'),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your email';
                              } else if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                  .hasMatch(value)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: context
                                  .watch<LocalizationService>()
                                  .translate('password'),
                              labelStyle: TextStyle(
                                  fontFamily: 'Alatsi', color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[200],
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide(
                                  color: Color(0xff1ACD36),
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter your password';
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ForgotPassword()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('forgot_password'),
                                  style: SmallTextBlue,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: () {
                                  // Call _login function when the button is pressed
                                  _login();
                                },
                                child: Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('login_button'),
                                  style: SmallTextWhite,
                                ),
                                style: customButtonStyle1,
                              )),
                          SizedBox(height: 10),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => RegisterScreen()),
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('login_text'),
                                  style: SmallTextGrey,
                                ),
                                SizedBox(
                                  width: 3,
                                ),
                                Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('register_text'),
                                  style: SmallTextBlue,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]))));
  }
}
