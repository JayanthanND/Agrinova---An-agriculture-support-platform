import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../Language/app_localization.dart';
import '../../Customs/constants.dart';
import '../../Customs/profilemenu_widget.dart';
import 'language_screen.dart';

class SettingsScreen extends StatelessWidget {
  final String collectionName; // ✅ Accept collection name as a parameter

  SettingsScreen({required this.collectionName}); // ✅ Require collection name

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Column(
        children: [
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
                    context.watch<LocalizationService>().translate('settings'),
                    style: NormalTextWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              children: [
                SizedBox(height: 10),

                // ✅ ProfileWidget with Background Color
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // ✅ Background color added
                    borderRadius:
                        BorderRadius.circular(10), // ✅ Rounded corners
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ProfileWidget(
                    title: context
                        .watch<LocalizationService>()
                        .translate('language'),
                    icon: Icons.language,
                    onPress: () {
                      // ✅ Pass collection name to LanguageScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              LanguageScreen(collectionName: collectionName),
                        ),
                      );
                    },
                    textStyle: SmallTextGrey,
                  ),
                ),

                Divider(color: Colors.grey.withOpacity(0.1)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
