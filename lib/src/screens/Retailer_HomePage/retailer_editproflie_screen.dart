import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../Language/app_localization.dart';
import '../Customs/constants.dart';
import '../Customs/formFieldWidget.dart';
import '../Customs/image_upload_service.dart';
import '../Customs/profile_photo_container.dart';

class RetailerEditproflieScreen extends StatefulWidget {
  final Map<String, dynamic> userData;
  const RetailerEditproflieScreen({Key? key, required this.userData})
      : super(key: key);
  @override
  State<RetailerEditproflieScreen> createState() =>
      _RetailerEditproflieScreenState();
}

class _RetailerEditproflieScreenState extends State<RetailerEditproflieScreen> {
  @override
  final _formKey = GlobalKey<FormState>();
  final ImageUploadService _imageUploadService = ImageUploadService();

  late String username;
  late String email;
  late String companyName;
  late String location;
  late String phoneNumber;
  late String description;
  String? profileImageUrl; // To store profile image URL

  @override
  void initState() {
    super.initState();
    // Initialize the fields with user data
    profileImageUrl = widget.userData['profileImageUrl'];
    username = widget.userData['username'] ?? '';
    email = widget.userData['email'] ?? '';
    companyName = widget.userData['companyName'];
    location = widget.userData['location'] ?? '';
    phoneNumber = widget.userData['phoneNumber'] ?? '';
    description = widget.userData['description'] ?? '';
  }

  // Set initial checkbox state based on existing request
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

  Future<void> _updateUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      // Reference to the user's document
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('retailers')
          .doc(currentUser.uid);
      print(userDocRef);

      // Check if the document exists
      DocumentSnapshot userDoc = await userDocRef.get();
      if (!userDoc.exists) {
        // Document not found, handle appropriately
        print("Document does not exist!");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User profile not found')),
        );
        return;
      }

      // Update user data in Firestore
      try {
        await userDocRef.update({
          'profileImageUrl': profileImageUrl,
          'username': username,
          'email': email,
          'companyName': companyName,
          'location': location,
          'phoneNumber': phoneNumber,
          'description': description,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Profile updated successfully'),
              ],
            ),
            padding: EdgeInsets.symmetric(vertical: 20),
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
      // Handle case where user is not logged in
      print("No current user found!");
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
                    SizedBox(height: 20),
                    TextInputField(
                      label: context
                          .watch<LocalizationService>()
                          .translate('company_name'),
                      initialValue: companyName,
                      onChanged: (value) {
                        setState(() {
                          companyName = value;
                        });
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
