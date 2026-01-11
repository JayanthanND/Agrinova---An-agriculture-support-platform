import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Customs/constants.dart';
import 'package:provider/provider.dart';

import '../../../Language/app_localization.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // ✅ Background color for page
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
                    context.watch<LocalizationService>().translate('about'),
                    style: NormalTextWhite,
                  ),
                ),
              ],
            ),
          ),
          Divider(), // ✅ About Section
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Column(
                      children: [
                        Image.asset('assets/images/logo.jpeg', height: 80),
                        SizedBox(height: 10),
                        Text(
                            context
                                .watch<LocalizationService>()
                                .translate('app_name'),
                            style: NormalTextBlack),
                        Text(
                            context
                                .watch<LocalizationService>()
                                .translate('version'),
                            style: SmallTextGrey),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  _sectionTitle(context, 'about_agrinova'),
                  _sectionText(context, 'agrinova_description'),
                  _sectionTitle(context, 'key_features'),
                  _bulletPoint(context, 'farmer_support'),
                  _bulletPoint(context, 'donor_investor'),
                  _bulletPoint(context, 'machine_learning'),
                  _bulletPoint(context, 'marketplace'),
                  _bulletPoint(context, 'gov_schemes'),
                  _sectionTitle(context, 'our_mission'),
                  _sectionText(context, 'mission_description'),
                  _sectionTitle(context, 'developed_by'),
                  _sectionText(context, 'developer_info'),
                  _sectionTitle(context, 'technologies_used'),
                  _bulletPoint(context, 'flutter'),
                  _bulletPoint(context, 'firebase'),
                  _bulletPoint(context, 'ml'),
                  SizedBox(height: 20),
                  Center(
                    child: Text(
                      context.watch<LocalizationService>().translate('contact'),
                      style: TextBlack,
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String key) {
    return Padding(
      padding: EdgeInsets.only(top: 15, bottom: 5),
      child: Text(context.watch<LocalizationService>().translate(key),
          style: TextBlack),
    );
  }

  Widget _sectionText(BuildContext context, String key) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10),
      child: Text(
        context.watch<LocalizationService>().translate(key),
        style: SmallTextGrey,
        textAlign: TextAlign.justify,
      ),
    );
  }

  Widget _bulletPoint(BuildContext context, String key) {
    return Padding(
      padding: EdgeInsets.only(left: 10, bottom: 5),
      child: Row(
        children: [
          Text(
            "• ",
            style: SmallTextGrey,
          ),
          Expanded(
              child: Text(context.watch<LocalizationService>().translate(key),
                  style: SmallTextGrey)),
        ],
      ),
    );
  }
}
