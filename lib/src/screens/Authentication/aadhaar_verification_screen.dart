// aadhaar_verification_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:provider/provider.dart';
import '../../Language/app_localization.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class AadhaarVerificationScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const AadhaarVerificationScreen({super.key, required this.userData});

  @override
  State<AadhaarVerificationScreen> createState() =>
      _AadhaarVerificationScreenState();
}

class _AadhaarVerificationScreenState extends State<AadhaarVerificationScreen> {
  final TextEditingController _aadhaarController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
static const String _twilioAccountSid = String.fromEnvironment('AC40d7164c488209b91e51e14a501eff8b');
static const String _twilioAuthToken = String.fromEnvironment('d250d69c5aaf52c90677353b318eef0a');
static const String _twilioServiceSid = String.fromEnvironment('VAba4d49ac05aac9cf1cbf536a7cdebf02');
static const String _twilioNumber = String.fromEnvironment('+16057608663');

  // Verification state variables
  bool _otpSent = false;
  bool _isVerified = false;
  int _resendTimeout = 0;
  Timer? _resendTimer;
  bool _isLoading = false;
  Future<bool> _sendTwilioOTP(String phoneNumber) async {
    try {
      // 1. Generate your own OTP (6 digits)
      final String otp = (100000 + Random().nextInt(900000)).toString();

      // 2. Send via Twilio Messaging API (not Verify API)
      final response = await http.post(
        Uri.parse(
            'https://api.twilio.com/2010-04-01/Accounts/$_twilioAccountSid/Messages.json'),
        headers: {
          'Authorization': 'Basic ' +
              base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken')),
        },
        body: {
          'To': '+91$phoneNumber',
          'From': _twilioNumber, // Must be your trial Twilio number
          'Body': 'Your Agrinova Aadhaar verification code is $otp.',
        },
      );

      if (response.statusCode == 201) {
        // Store OTP for verification (use Firebase/Firestore)
        await FirebaseFirestore.instance
            .collection('otpVerifications')
            .doc(phoneNumber)
            .set({
          'otp': otp,
          'createdAt': FieldValue.serverTimestamp(),
          'expiresAt': DateTime.now().add(Duration(minutes: 5)),
        });
        return true;
      } else {
        print('Twilio error: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending OTP: $e');
      return false;
    }
  }

  Future<bool> _verifyTwilioOTP(String phoneNumber, String code) async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('otpVerifications')
          .doc(phoneNumber)
          .get();

      if (!doc.exists) return false;

      final data = doc.data()!;
      if (data['otp'] == code &&
          DateTime.now().isBefore((data['expiresAt'] as Timestamp).toDate())) {
        await doc.reference.delete(); // OTP can only be used once
        return true;
      }
      return false;
    } catch (e) {
      print('Error verifying OTP: $e');
      return false;
    }
  }

// Replace your existing _sendOTP method with this:
  Future<void> _sendOTP() async {
    if (_aadhaarController.text.isEmpty ||
        !RegExp(r'^[0-9]{10}$').hasMatch(_aadhaarController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a valid 10-digit number'),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool otpSent = await _sendTwilioOTP(widget.userData['phoneNumber']);

    setState(() {
      _isLoading = false;
      if (otpSent) {
        _otpSent = true;
        _resendTimeout = 60; // 60 seconds timeout
        _startResendTimer();
      }
    });

    if (!otpSent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send OTP. Please try again.'),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
    }
  }

// Replace your existing _verifyOTP method with this:
  Future<void> _verifyOTP() async {
    if (_otpController.text.isEmpty || _otpController.text.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter 6-digit OTP'),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    bool isVerified = await _verifyTwilioOTP(
      widget.userData['phoneNumber'],
      _otpController.text,
    );

    setState(() {
      _isLoading = false;
      _isVerified = isVerified;
      if (isVerified) {
        _otpSent = false;
      }
    });

    if (!isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invalid OTP. Please try again.'),
          backgroundColor: Colors.red.withOpacity(0.9),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Aadhaar number verified!'),
          backgroundColor: Colors.green.withOpacity(0.9),
        ),
      );
    }
  }

// Add these timer methods
  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimeout > 0) {
        setState(() {
          _resendTimeout--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    super.dispose();
  }

  Future<void> _registerUser() async {
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Aadhaar verification required')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Add Aadhaar to user data
      final userData = {
        ...widget.userData,
        'aadhaarNumber': _aadhaarController.text,
        'aadhaarVerified': true,
      };

      // Create user in Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: userData['email'], password: userData['password']);

      // Save additional data based on role
      final collectionName = _getCollectionName(userData['role']);
      await FirebaseFirestore.instance
          .collection(collectionName)
          .doc(userCredential.user!.uid)
          .set(userData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Container(
            padding: EdgeInsets.all(16),
            height: 90,
            // Increased height for better spacing
            decoration: BoxDecoration(
              color: Colors.green, // Your custom button color
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center content
              crossAxisAlignment:
                  CrossAxisAlignment.start, // Align text to start
              children: [
                Center(
                  child: Text(
                    'Successfully Registered!',
                    style: TextStyle(
                        fontSize: 17,
                        color: WhiteText,
                        fontWeight: FontWeight.bold), // Your custom text style
                  ),
                ),
                SizedBox(height: 2), // Small space between the texts
                Center(
                  child: Text(
                    'Thank you for registering',
                    style: SmallTextWhite,
                  ),
                ),
              ],
            ),
          ),

          behavior: SnackBarBehavior.floating,
          backgroundColor:
              Colors.transparent, // Transparent background for floating effect
          elevation: 0, // Remove shadow
          duration: Duration(seconds: 3), // How long the snackbar is visible
          margin: EdgeInsets.only(bottom: 70, left: 20, right: 20),
          // Adjust position on screen
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error registering user: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getCollectionName(String role) {
    switch (role) {
      case 'Farmer':
        return 'farmers';
      case 'Donor':
        return 'donors';
      case 'Investor':
        return 'investors';
      case 'Retailer':
        return 'retailers';
      default:
        return 'users';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1acd36),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                color: MainGreen,
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  children: [
                    // Header with back button
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
                                .translate('aadhaar_verification'),
                            style: NormalTextBlack,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                // Aadhaar number input
                                TextFormField(
                                  controller: _aadhaarController,
                                  keyboardType: TextInputType.number,
                                  readOnly: _isVerified,
                                  maxLength: 12,
                                  cursorColor: MainGreen,
                                  decoration: InputDecoration(
                                    labelText: context
                                        .watch<LocalizationService>()
                                        .translate('aadhaar_number'),
                                    labelStyle: TextStyle(
                                        fontFamily: 'Alatsi',
                                        color: Colors.grey),
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
                                    counterText: '',
                                    prefixIcon: Padding(
                                      padding: EdgeInsets.all(15),
                                      child: Text('XXXX XXXX ',
                                          style: TextStyle(color: Colors.grey)),
                                    ),
                                  ),
                                ),
                                SizedBox(height: 10),

                                // OTP field (visible only after OTP is sent)
                                if (_otpSent && !_isVerified) ...[
                                  TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputFieldBox(context
                                        .watch<LocalizationService>()
                                        .translate('enter_otp')),
                                  ),
                                  SizedBox(height: 10),
                                ],

                                // Verification status or buttons
                                if (_isVerified)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Icon(Icons.verified, color: Colors.green),
                                      SizedBox(width: 8),
                                      Text(
                                        context
                                            .watch<LocalizationService>()
                                            .translate('aadhaar_verified'),
                                        style: TextStyle(color: Colors.green),
                                      ),
                                    ],
                                  )
                                else if (!_otpSent)
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: ElevatedButton(
                                      onPressed: _sendOTP,
                                      child: _isLoading
                                          ? CircularProgressIndicator(
                                              color: Colors.white)
                                          : Text(
                                              context
                                                  .watch<LocalizationService>()
                                                  .translate('send_otp'),
                                              style: TextStyle(
                                                  color: Colors.white),
                                            ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                    ),
                                  )
                                else
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      ElevatedButton(
                                        onPressed: _verifyOTP,
                                        child: _isLoading
                                            ? CircularProgressIndicator(
                                                color: Colors.white)
                                            : Text(
                                                context
                                                    .watch<
                                                        LocalizationService>()
                                                    .translate('verify_otp'),
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                        ),
                                      ),
                                      if (_resendTimeout > 0)
                                        Text('Resend in $_resendTimeout')
                                      else
                                        TextButton(
                                          onPressed: _sendOTP,
                                          child: Text(
                                            context
                                                .watch<LocalizationService>()
                                                .translate('resend_otp'),
                                          ),
                                        ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                          SizedBox(height: 20),

                          // Register button
                          ElevatedButton(
                            onPressed: _isVerified ? _registerUser : null,
                            child: _isLoading
                                ? CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('register'),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Alatsi',
                                    ),
                                  ),
                            style: ElevatedButton.styleFrom(
                              elevation: 10,
                              padding: EdgeInsets.symmetric(
                                horizontal: 35,
                                vertical: 10,
                              ),
                              backgroundColor: _isVerified
                                  ? Colors.grey[700]
                                  : Colors.grey[400],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
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
        ),
      ),
    );
  }
}
