import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../Language/app_localization.dart';

class LanguageScreen extends StatefulWidget {
  final String collectionName; // ✅ Accept collection name

  LanguageScreen({required this.collectionName}); // ✅ Require collection name

  @override
  _LanguageScreenState createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String selectedLanguage = "en"; // Default to English

  @override
  void initState() {
    super.initState();
    _loadSelectedLanguage();
  }

  Future<void> _loadSelectedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedLanguage = prefs.getString('language') ?? "en";
    });
  }

  Future<void> _setLanguage(String languageCode) async {
    // ✅ Set language using LocalizationService
    context.read<LocalizationService>().setLanguage(languageCode);

    // ✅ Update Firestore for the current user in the correct collection
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      await FirebaseFirestore.instance
          .collection(widget.collectionName) // ✅ Use dynamic collection name
          .doc(currentUser.uid)
          .update({'language': languageCode});
    }

    // ✅ Close language screen
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
          // ✅ Custom App Bar Style Header
          Container(
            color: MainGreen,
            padding: EdgeInsets.only(top: 40, bottom: 10, left: 10),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                Expanded(
                  child: Text(
                    context
                        .watch<LocalizationService>()
                        .translate('change_language'),
                    style: NormalTextWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(),

          // ✅ Language Selection Section
          Expanded(
            child: Column(
              children: [
                SizedBox(height: 20),

                // ✅ Radio Buttons inside a container with background
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    children: [
                      RadioListTile(
                        title: Text("English", style: SmallTextGrey),
                        value: "en",
                        activeColor: MainGreen,
                        groupValue: selectedLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedLanguage = value;
                            });
                          }
                        },
                      ),
                      Divider(),
                      RadioListTile(
                        title: Text("தமிழ்", style: SmallTextGrey),
                        value: "ta",
                        activeColor: MainGreen,
                        groupValue: selectedLanguage,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedLanguage = value;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),

                Spacer(),

                // ✅ Styled Select Button
                Container(
                  width: double.infinity,
                  margin: EdgeInsets.symmetric(horizontal: 20),
                  child: ElevatedButton(
                    onPressed: () {
                      _setLanguage(selectedLanguage);
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
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
