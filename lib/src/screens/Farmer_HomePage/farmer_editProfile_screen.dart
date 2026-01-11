import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/formFieldWidget.dart';
import '../Customs/image_container.dart';
import '../Customs/image_upload_service.dart';
import '../Customs/profile_photo_container.dart';

class FarmerEditprofileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  const FarmerEditprofileScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<FarmerEditprofileScreen> createState() =>
      _FarmerEditprofileScreenState();
}

class _FarmerEditprofileScreenState extends State<FarmerEditprofileScreen> {
  final _formKey = GlobalKey<FormState>();
  final ImageUploadService _imageUploadService = ImageUploadService();

  late String username;
  late String email;
  late String location;
  late String phoneNumber;
  late String description;
  late String liveStock;
  late String waterFacility;
  late String request;
  late String requirement;

  String? landMapImageUrl; // To store land map image URL
  String? profileImageUrl; // To store profile image URL

  bool _donationChecked = false;
  bool _investmentChecked = false;

  @override
  void initState() {
    super.initState();

    // Initialize the fields with user data
    profileImageUrl = widget.userData['profileImageUrl'];
    username = widget.userData['username'] ?? '';
    email = widget.userData['email'] ?? '';
    location = widget.userData['location'] ?? '';
    phoneNumber = widget.userData['phoneNumber'] ?? '';
    description = widget.userData['description'] ?? '';
    liveStock = widget.userData['liveStock'] ?? '';
    waterFacility = widget.userData['waterFacility'] ?? '';
    request = widget.userData['request'] ?? '';
    requirement = widget.userData['requirement'] ?? '';
    landMapImageUrl = widget.userData['landMapImageUrl'];

    // Set initial checkbox state based on existing request
    if (request == 'Donation') {
      _donationChecked = true;
    } else if (request == 'Investment') {
      _investmentChecked = true;
    }
  }

  Future<void> _pickProfileImage() async {
    File? imageFile =
        await _imageUploadService.pickAndCropImage(source: ImageSource.gallery);
    if (imageFile != null) {
      String? uploadedUrl =
          await _imageUploadService.uploadImage(imageFile, 'profile_images');
      if (uploadedUrl != null) {
        setState(() {
          profileImageUrl = uploadedUrl; // Update profile image URL
        });
      }
    }
  }

  Future<void> _pickLandMapImage() async {
    File? imageFile =
        await _imageUploadService.pickAndCropImage(source: ImageSource.gallery);
    if (imageFile != null) {
      String? uploadedUrl =
          await _imageUploadService.uploadImage(imageFile, 'land_map_images');
      if (uploadedUrl != null) {
        setState(() {
          landMapImageUrl = uploadedUrl; // Update land map image URL
        });
      }
    }
  }

  Future<void> _updateUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('farmers').doc(currentUser.uid);

      try {
        await userDocRef.update({
          'profileImageUrl': profileImageUrl,
          'username': username,
          'email': email,
          'location': location,
          'phoneNumber': phoneNumber,
          'description': description,
          'liveStock': liveStock,
          'waterFacility': waterFacility,
          'request': _donationChecked ? 'Donation' : 'Investment',
          'requirement': requirement,
          'landMapImageUrl': landMapImageUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Profile updated successfully')),
            backgroundColor: Colors.green.withOpacity(0.9),
          ),
        );
      } catch (error) {
        print('Failed to update user: $error');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User not logged in')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20),
          color: Colors.grey[200],
          child: Column(
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
                    flex: 3,
                    child: Container(
                      alignment: Alignment
                          .topCenter, // Ensures text is centered in available space
                      padding: EdgeInsets.only(top: 45),
                      child: Text(
                        context
                            .watch<LocalizationService>()
                            .translate('edit_profile'),
                        style: NormalTextBlack,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Container(),
                  ),
                ],
              ),
              SizedBox(height: 20),
              ProfilePhotoWidget(
                profileImageUrl:
                    profileImageUrl, // Pass the current profile image URL
                onPressed: _pickProfileImage,
                showIcon: true, // Pass the callback for changing the image
              ),
              SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('username'),
                      initialValue: username,
                      onChanged: (value) {
                        setState(() {
                          username = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your username';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('email'),
                      initialValue: email,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 10),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('location'),
                      initialValue: location,
                      onChanged: (value) {
                        setState(() {
                          location = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    landMapImageContainer(
                      context: context,
                      landMapImageUrl:
                          landMapImageUrl, // Pass the current image URL
                      onPressed:
                          _pickLandMapImage, // Pass the callback for changing the image
                    ),
                    SizedBox(height: 10),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('live_stock'),
                      initialValue: liveStock,
                      onChanged: (value) {
                        setState(() {
                          liveStock = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('water_facility'),
                      initialValue: waterFacility,
                      onChanged: (value) {
                        setState(() {
                          waterFacility = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('phone_number'),
                      initialValue: phoneNumber,
                      onChanged: (value) {
                        setState(() {
                          phoneNumber = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                                      groupValue:
                                          _donationChecked ? true : null,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _donationChecked = true;
                                          _investmentChecked = false;
                                          request =
                                              'Donation'; // Set request type
                                        });
                                      },
                                    ),
                                    Text(
                                      context
                                          .watch<LocalizationService>()
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
                                      groupValue:
                                          _investmentChecked ? true : null,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          _donationChecked = false;
                                          _investmentChecked = true;
                                          request =
                                              'Investment'; // Set request type
                                        });
                                      },
                                    ),
                                    Text(
                                      context
                                          .watch<LocalizationService>()
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
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('requirement'),
                      initialValue: requirement,
                      onChanged: (value) {
                        setState(() {
                          requirement = value;
                        });
                      },
                    ),
                    SizedBox(height: 10),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('description'),
                      initialValue: description,
                      onChanged: (value) {
                        setState(() {
                          description = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _updateUserData(); // Call the update function
                        }
                      },
                      child: Text(
                        context
                            .watch<LocalizationService>()
                            .translate('save_changes'),
                        style: SmallTextWhite,
                        textAlign: TextAlign.center,
                      ),
                      style: ElevatedButton.styleFrom(
                        elevation: 10,
                        shadowColor: Colors.blue,
                        fixedSize: Size(330, 50),
                        backgroundColor: Color(0xff1ACD36),
                      ),
                    ),
                    SizedBox(height: 20),
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
