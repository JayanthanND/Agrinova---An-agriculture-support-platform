import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Crop_Management/Crop_Maintanence/crop_maintanence.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Crop_Management/Crop_Price_Estimation/crop_minimum_selling_price_estimation.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Crop_Management/Crop_Suggestion/crop_suggestion.dart';
import 'package:provider/provider.dart';

import '../../../Language/app_localization.dart';
import '../../Customs/constants.dart';
import '../../Customs/custom_page_container.dart';
import 'Crops/types_of_crops_homepage.dart';
import 'Example_page.dart';

class CropManagementHomepage extends StatefulWidget {
  @override
  CropManagementHomepageState createState() => CropManagementHomepageState();
}

class CropManagementHomepageState extends State<CropManagementHomepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff1ACD36),
      body: Stack(
        children: [
          SingleChildScrollView(
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
                          IconButton(
                            padding: const EdgeInsets.only(
                                top: 0, left: 30, bottom: 14),
                            icon: const Icon(Icons.arrow_back_ios,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.pop(context);
                            },
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
                      MainContainer1(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const SizedBox(width: 10),
                                Text(
                                    context
                                        .watch<LocalizationService>()
                                        .translate('cropmanagement'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            CustomPageContainer(
                              header: context
                                  .watch<LocalizationService>()
                                  .translate('types_of_crops'),
                              imagePath:
                                  'assets/images/Crop_Management/croptype.webp',
                              overlayColor: Colors.greenAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        TypesOfCropsHomepage(),
                                  ),
                                );
                              },
                            ),
                            CustomPageContainer(
                              header: context
                                  .watch<LocalizationService>()
                                  .translate('crop_suggestion'),
                              imagePath:
                                  'assets/images/Crop_Management/cropsuggestion.webp',
                              overlayColor: Colors.orangeAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CropSuggestionApp(),
                                  ),
                                );
                              },
                            ),
                            CustomPageContainer(
                              header: context
                                  .watch<LocalizationService>()
                                  .translate('crop_maintenance'),
                              imagePath:
                                  'assets/images/Crop_Management/cropmaintanence.webp',
                              overlayColor: Colors.blueAccent,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CropMaintenanceApp(),
                                  ),
                                );
                              },
                            ),
                            CustomPageContainer(
                              header: context
                                  .watch<LocalizationService>()
                                  .translate('crop_price_estimation'),
                              imagePath:
                                  'assets/images/Crop_Management/cropprice.webp',
                              overlayColor: Colors.blueAccent.shade100,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CropMinimumSellingPriceEstimation(),
                                  ),
                                );
                              },
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
        ],
      ),
    );
  }
}
