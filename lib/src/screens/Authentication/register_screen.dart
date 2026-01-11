import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Language/app_localization.dart';
import '../Customs/image_container.dart';
import '../Customs/image_upload_service.dart';
import 'aadhaar_verification_screen.dart';
import 'login_screen.dart';
import 'package:http/http.dart' as http;

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _companyNameController = TextEditingController();
  final TextEditingController _cropReqdcontroller = TextEditingController();
  final TextEditingController _liveStocksController = TextEditingController();
  final TextEditingController _waterFacilityController =
      TextEditingController();
  final TextEditingController _requirementController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  bool _obscurePassword = true; // Add this to your State class

  String? _selectedRole;
  bool _donationChecked = false;
  bool _investmentChecked = false;
  List<String> roles = ['Farmer', 'Donor', 'Investor', 'Retailer'];
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  File? _landMapImage; // Store the selected image file
  String? _landMapImageUrl; // Store the uploaded image URL

  final ImageUploadService _imageUploadService =
      ImageUploadService(); // Instantiate the ImageUploadService

static const String _twilioAccountSid = String.fromEnvironment('AC40d7164c488209b91e51e14a501eff8b');
static const String _twilioAuthToken = String.fromEnvironment('d250d69c5aaf52c90677353b318eef0a');
static const String _twilioServiceSid = String.fromEnvironment('VAba4d49ac05aac9cf1cbf536a7cdebf02');
static const String _twilioNumber = String.fromEnvironment('+16057608663');


  // Verification state variables
  bool _otpSent = false;
  bool _isVerified = false;
  int _resendTimeout = 0;
  Timer? _resendTimer;

// // Add these methods to your _RegisterScreenState class
//   Future<bool> _sendTwilioOTP(String phoneNumber) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//             'https://verify.twilio.com/v2/Services/$_twilioServiceSid/Verifications'),
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//           'Authorization': 'Basic ' +
//               base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken')),
//         },
//         body: {
//           'To': '+91$phoneNumber',
//           'Channel': 'sms',
//         },
//       );
//
//       if (response.statusCode == 201) {
//         return true;
//       } else {
//         print('Twilio error: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('Error sending OTP: $e');
//       return false;
//     }
//   }
//
//   Future<bool> _verifyTwilioOTP(String phoneNumber, String code) async {
//     try {
//       final response = await http.post(
//         Uri.parse(
//             'https://verify.twilio.com/v2/Services/$_twilioServiceSid/VerificationCheck'),
//         headers: {
//           'Content-Type': 'application/x-www-form-urlencoded',
//           'Authorization': 'Basic ' +
//               base64Encode(utf8.encode('$_twilioAccountSid:$_twilioAuthToken')),
//         },
//         body: {
//           'To': '+91$phoneNumber',
//           'Code': code,
//         },
//       );
//
//       final responseData = jsonDecode(response.body);
//       if (response.statusCode == 200 && responseData['status'] == 'approved') {
//         return true;
//       } else {
//         print('Twilio verification error: ${response.body}');
//         return false;
//       }
//     } catch (e) {
//       print('Error verifying OTP: $e');
//       return false;
//     }
//   }

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
          'Body': 'Your Agrinova Phone number verification code is $otp.',
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
    if (_phoneNumberController.text.isEmpty ||
        !RegExp(r'^[0-9]{10}$').hasMatch(_phoneNumberController.text)) {
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

    bool otpSent = await _sendTwilioOTP(_phoneNumberController.text);

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
      _phoneNumberController.text,
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
          content: Text('Phone number verified!'),
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

  // Method to handle image picking and uploading to Firebase
  Future<void> _pickAndUploadImage() async {
    File? image = await _imageUploadService.pickAndCropImage(
        source: ImageSource.gallery); // Pick image from gallery
    if (image != null) {
      setState(() {
        _landMapImage = image; // Store the image file
      });

      // Upload the image to Firebase and get the URL
      String? imageUrl =
          await _imageUploadService.uploadImage(image, 'land_maps');
      if (imageUrl != null) {
        setState(() {
          _landMapImageUrl = imageUrl; // Store the image URL
        });
      }
    }
  }

  // Function to register user
  Future registerUser() async {
    if (!_isVerified) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Phone verification required')),
      );
      return;
    }
    if (_formKey.currentState?.validate() ?? false) {
      // Show the loading dialog
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? selectedLanguage = prefs.getString('language') ?? 'en';
      // Get data from text controllers
      String username = _usernameController.text;
      String email = _emailController.text;
      String password = _passwordController.text;
      String location = _locationController.text;
      String phoneNumber = _phoneNumberController.text;
      String description = _descriptionController.text;
      String selectedRole = _selectedRole ?? 'Farmer'; // Default role
      // Prepare user data based on role
      Map<String, dynamic> userData = {
        'username': username,
        'email': email,
        'location': location,
        'phoneNumber': phoneNumber,
        'description': description,
        'role': selectedRole,
        'createdAt': FieldValue.serverTimestamp(),
        'language': selectedLanguage, // 🔹 Store language preference
        'phoneVerified': true, // Mark phone as verified
      };

      try {
        // Create user in Firebase Auth
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
                email: _emailController.text.trim(),
                password: _passwordController.text.trim());

        // Add additional data based on role
        if (selectedRole == 'Farmer') {
          userData.addAll({
            'landMapImageUrl':
                _landMapImageUrl, // Handle file upload and store URL here
            'liveStock': _liveStocksController.text,
            'waterFacility': _waterFacilityController.text,
            'request': _donationChecked ? 'Donation' : 'Investment',
            'requirement': _requirementController.text,
          });
          await FirebaseFirestore.instance
              .collection('farmers')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else if (selectedRole == 'Donor') {
          await FirebaseFirestore.instance
              .collection('donors')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else if (selectedRole == 'Investor') {
          await FirebaseFirestore.instance
              .collection('investors')
              .doc(userCredential.user!.uid)
              .set(userData);
        } else if (selectedRole == 'Retailer') {
          userData.addAll({
            'companyName': _companyNameController.text,
            'cropReqd': _cropReqdcontroller.text,
          });
          await FirebaseFirestore.instance
              .collection('retailers')
              .doc(userCredential.user!.uid)
              .set(userData);
        }

        if (_formKey.currentState?.validate() ?? false) {
          // Show the snackbar with success message
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
                            fontWeight:
                                FontWeight.bold), // Your custom text style
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
              backgroundColor: Colors
                  .transparent, // Transparent background for floating effect
              elevation: 0, // Remove shadow
              duration:
                  Duration(seconds: 3), // How long the snackbar is visible
              margin: EdgeInsets.only(bottom: 70, left: 20, right: 20),
              // Adjust position on screen
            ),
          );

          // After 2 seconds (when snackbar disappears), navigate to registration page
          Timer(Duration(seconds: 2), () {
            // Redirect to the registration page
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
            );
          });
        }
      } catch (e) {
        // Handle errors, e.g., email already in use, weak password
        print('Error registering user: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error registering user: ${e.toString()}')),
        );
      } finally {
        setState(() {
          _isLoading = false; // Stop loading
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, String> rolesMap = {
      'Farmer': context.watch<LocalizationService>().translate('farmer'),
      'Donor': context.watch<LocalizationService>().translate('donor'),
      'Investor': context.watch<LocalizationService>().translate('investor'),
      'Retailer': context.watch<LocalizationService>().translate('retailer'),
    };

    String? selectedRole;
    return Scaffold(
      backgroundColor: const Color(0xff1acd36),
      body: Center(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  color: MainGreen,
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
                      const SizedBox(
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
                                  .translate('register'),
                              style: NormalTextBlack,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('username')),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('email')),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                } else if (!RegExp(
                                        r'^[^\s@]+@[^\s@]+\.[^\s@]+$')
                                    .hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
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
                            const SizedBox(
                              height: 10,
                            ),
                            DropdownButtonFormField<String>(
                              value: _selectedRole,
                              items: rolesMap.entries.map((entry) {
                                return DropdownMenuItem<String>(
                                  value: entry.key, // Store English key
                                  child: Text(
                                      entry.value), // Display translated value
                                );
                              }).toList(),
                              decoration: InputFieldBox(context
                                  .watch<LocalizationService>()
                                  .translate('select_role')),
                              onChanged: (String? value) {
                                setState(() {
                                  _selectedRole = value;
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            if (_selectedRole == 'Farmer') ...[
                              TextFormField(
                                controller: _locationController,
                                decoration: InputFieldBox(context
                                    .watch<LocalizationService>()
                                    .translate('location')),
                              ),

                              const SizedBox(height: 10),
                              landMapImageContainer(
                                context: context,
                                landMapImageUrl:
                                    _landMapImageUrl, // Pass the uploaded image URL
                                onPressed:
                                    _pickAndUploadImage, // Pass the image picker callback to allow changing the image
                              ),
                              const SizedBox(height: 10),
                              // Display selected image
                              if (_landMapImage != null) ...[
                                Text(
                                  '${context.watch<LocalizationService>().translate('selected')}: ${_landMapImage!.path.split('/').last}',
                                  style: SmallTextGrey,
                                ),
                              ],
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _liveStocksController,
                                decoration: InputFieldBox(context
                                    .watch<LocalizationService>()
                                    .translate('live_stock')),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _waterFacilityController,
                                decoration: InputFieldBox(context
                                    .watch<LocalizationService>()
                                    .translate('water_facility')),
                              ),
                              const SizedBox(height: 10),
// Phone verification section for Indian numbers
                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    // Phone number input with fixed +91 prefix
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                            ),
                                          ),
                                          child: Text('+91', style: TextGrey),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _phoneNumberController,
                                            keyboardType: TextInputType.phone,
                                            readOnly: _isVerified,
                                            decoration: InputFieldBox(context
                                                .watch<LocalizationService>()
                                                .translate('phone_number')),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter phone number';
                                              } else if (!RegExp(r'^[0-9]{10}$')
                                                  .hasMatch(value)) {
                                                return 'Enter 10 digit mobile number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    // OTP field (visible only after OTP is sent and not yet verified)
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
                                        children: [
                                          Icon(Icons.verified,
                                              color: Colors.green),
                                          SizedBox(width: 8),
                                          Text(
                                            context
                                                .watch<LocalizationService>()
                                                .translate('phone_verified'),
                                            style:
                                                TextStyle(color: Colors.green),
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
                                                      .watch<
                                                          LocalizationService>()
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
                                                        .translate(
                                                            'verify_otp'),
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
                                                    .watch<
                                                        LocalizationService>()
                                                    .translate('resend_otp'),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate('request'),
                                      style: const TextStyle(
                                        fontFamily: 'Alatsi',
                                        fontSize: 16,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Radio<bool>(
                                                value: true,
                                                groupValue: _donationChecked
                                                    ? true
                                                    : null,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    _donationChecked = true;
                                                    _investmentChecked = false;
                                                  });
                                                },
                                              ),
                                              Text(
                                                context
                                                    .watch<
                                                        LocalizationService>()
                                                    .translate('donation'),
                                                style: TextStyle(
                                                  fontFamily: 'Alatsi',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Expanded(
                                          flex: 2,
                                          child: Row(
                                            children: [
                                              Radio<bool>(
                                                value: true,
                                                groupValue: _investmentChecked
                                                    ? true
                                                    : null,
                                                onChanged: (bool? value) {
                                                  setState(() {
                                                    _donationChecked = false;
                                                    _investmentChecked = true;
                                                  });
                                                },
                                              ),
                                              Text(
                                                context
                                                    .watch<
                                                        LocalizationService>()
                                                    .translate('investment'),
                                                style: TextStyle(
                                                  fontFamily: 'Alatsi',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _requirementController,
                                maxLines: 4,
                                decoration: InputFieldBox(context
                                    .watch<LocalizationService>()
                                    .translate('requirement')),
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _descriptionController,
                                maxLines: 4,
                                decoration: InputFieldBox(context
                                    .watch<LocalizationService>()
                                    .translate('description')),
                              ),
                              SizedBox(height: 10),
                            ] else if (_selectedRole == 'Retailer') ...[
                              // Retailer-specific fields
                              TextFormField(
                                  controller: _companyNameController,
                                  decoration: InputFieldBox(context
                                      .watch<LocalizationService>()
                                      .translate('company_name'))),
                              SizedBox(height: 10),
                              TextFormField(
                                  controller: _cropReqdcontroller,
                                  decoration: InputFieldBox(context
                                      .watch<LocalizationService>()
                                      .translate('crop_required'))),
                              SizedBox(height: 10),
                              TextFormField(
                                  controller: _locationController,
                                  decoration: InputFieldBox(context
                                      .watch<LocalizationService>()
                                      .translate('location'))),
                              SizedBox(height: 10),

                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    // Phone number input with fixed +91 prefix
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                            ),
                                          ),
                                          child: Text('+91', style: TextGrey),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _phoneNumberController,
                                            keyboardType: TextInputType.phone,
                                            readOnly: _isVerified,
                                            decoration: InputFieldBox(context
                                                .watch<LocalizationService>()
                                                .translate('phone_number')),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter phone number';
                                              } else if (!RegExp(r'^[0-9]{10}$')
                                                  .hasMatch(value)) {
                                                return 'Enter 10 digit mobile number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    // OTP field (visible only after OTP is sent and not yet verified)
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
                                        children: [
                                          Icon(Icons.verified,
                                              color: Colors.green),
                                          SizedBox(width: 8),
                                          Text(
                                            context
                                                .watch<LocalizationService>()
                                                .translate('phone_verified'),
                                            style:
                                                TextStyle(color: Colors.green),
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
                                                      .watch<
                                                          LocalizationService>()
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
                                                        .translate(
                                                            'verify_otp'),
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
                                                    .watch<
                                                        LocalizationService>()
                                                    .translate('resend_otp'),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  decoration: InputFieldBox(context
                                      .watch<LocalizationService>()
                                      .translate('description'))),
                            ] else if (_selectedRole == 'Donor' ||
                                _selectedRole == 'Investor') ...[
                              // Reset to initial state fields for Donor and Investor
                              TextFormField(
                                  controller: _locationController,
                                  decoration: InputFieldBox(context
                                      .watch<LocalizationService>()
                                      .translate('location'))),
                              SizedBox(height: 10),

                              Container(
                                padding: EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Column(
                                  children: [
                                    // Phone number input with fixed +91 prefix
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 12, vertical: 16),
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            border: Border.all(
                                                color: Colors.grey.shade300),
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(6),
                                              bottomLeft: Radius.circular(6),
                                            ),
                                          ),
                                          child: Text('+91', style: TextGrey),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        Expanded(
                                          child: TextFormField(
                                            controller: _phoneNumberController,
                                            keyboardType: TextInputType.phone,
                                            readOnly: _isVerified,
                                            decoration: InputFieldBox(context
                                                .watch<LocalizationService>()
                                                .translate('phone_number')),
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter phone number';
                                              } else if (!RegExp(r'^[0-9]{10}$')
                                                  .hasMatch(value)) {
                                                return 'Enter 10 digit mobile number';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    // OTP field (visible only after OTP is sent and not yet verified)
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
                                        children: [
                                          Icon(Icons.verified,
                                              color: Colors.green),
                                          SizedBox(width: 8),
                                          Text(
                                            context
                                                .watch<LocalizationService>()
                                                .translate('phone_verified'),
                                            style:
                                                TextStyle(color: Colors.green),
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
                                                      .watch<
                                                          LocalizationService>()
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
                                                        .translate(
                                                            'verify_otp'),
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
                                                    .watch<
                                                        LocalizationService>()
                                                    .translate('resend_otp'),
                                              ),
                                            ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),

                              TextFormField(
                                  controller: _descriptionController,
                                  maxLines: 4,
                                  decoration: InputFieldBox(context
                                      .watch<LocalizationService>()
                                      .translate('description'))),
                            ],
                            SizedBox(height: 20),

// In your RegisterScreen's build method, replace the register button with:
                            Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton(
                                onPressed: _isVerified
                                    ? () {
                                        // Collect all user data
                                        final userData = {
                                          'username': _usernameController.text,
                                          'email': _emailController.text,
                                          'password': _passwordController.text,
                                          'location': _locationController.text,
                                          'phoneNumber':
                                              _phoneNumberController.text,
                                          'description':
                                              _descriptionController.text,
                                          'role': _selectedRole ?? 'Farmer',
                                          'phoneVerified': true,
                                          // Add role-specific fields
                                          if (_selectedRole == 'Farmer') ...{
                                            'landMapImageUrl': _landMapImageUrl,
                                            'liveStock':
                                                _liveStocksController.text,
                                            'waterFacility':
                                                _waterFacilityController.text,
                                            'request': _donationChecked
                                                ? 'Donation'
                                                : 'Investment',
                                            'requirement':
                                                _requirementController.text,
                                          },
                                          if (_selectedRole == 'Retailer') ...{
                                            'companyName':
                                                _companyNameController.text,
                                            'cropReqd':
                                                _cropReqdcontroller.text,
                                          }
                                        };

                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AadhaarVerificationScreen(
                                                    userData: userData),
                                          ),
                                        );
                                      }
                                    : null,
                                child: Text(
                                  context
                                      .watch<LocalizationService>()
                                      .translate('next'),
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
                            ),
                            SizedBox(height: 20),

// Login redirection
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('already_have_account'),
                                    style: SmallTextGrey),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                      context
                                          .watch<LocalizationService>()
                                          .translate('login'),
                                      style: SmallTextBlue),
                                ),
                              ],
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
      ),
    );
  }
}
