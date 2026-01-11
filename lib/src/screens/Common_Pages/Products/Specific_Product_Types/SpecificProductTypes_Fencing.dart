import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import '../Specific_Product_types_description/Fencing/BarbedWireFences_description.dart';
import '../Specific_Product_types_description/Fencing/ElectricFences_description.dart';
import '../Specific_Product_types_description/Fencing/MeshFencing_description.dart';
import '../Specific_Product_types_description/Fencing/VinylFences_description.dart';
import '../Specific_Product_types_description/Fencing/WoodenFences_description.dart';

class SpecificproducttypesFencing extends StatefulWidget {
  @override
  _SpecificproducttypesFencingState createState() =>
      _SpecificproducttypesFencingState();
}

class _SpecificproducttypesFencingState
    extends State<SpecificproducttypesFencing> {
  // Variable to store the farmer's selected need

  @override
  void initState() {
    super.initState();
  }

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
                          Align(
                            alignment: Alignment.topLeft,
                            child: IconButton(
                              padding: const EdgeInsets.only(
                                  top: 0, left: 30, bottom: 14),
                              icon: const Icon(Icons.arrow_back_ios,
                                  color: Colors.white),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                          ),
                          const SizedBox(width: 30),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(height: 15),
                              Text(context.watch<LocalizationService>().translate('app_name'), style: TitleStyle),
                              const SizedBox(height: 5),
                              Text(context.watch<LocalizationService>().translate('tagline'),  style: SmallTextWhite),

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
                                Text(context.watch<LocalizationService>().translate('agri_products'),  style: NormalTextGrey),

                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            Text(
                              context.watch<LocalizationService>().translate('F'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),
                            CustomPageContainerWithimage(
                              Header:context.watch<LocalizationService>().translate('TFB'),
                              imagePath: 'assets/images/Agri_Products/barbed wire fencing.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          BarbedwirefencesDescription()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header:context.watch<LocalizationService>().translate('TFM'),
                              imagePath: 'assets/images/Agri_Products/mesh fencing.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          MeshfencingDescription()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header:context.watch<LocalizationService>().translate('TFE'),
                              imagePath: 'assets/images/Agri_Products/electric fencing.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ElectricfencesDescription()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TFW'),
                              imagePath: 'assets/images/Agri_Products/wooden fencing.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WoodenfencesDescription()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TFV'),
                              imagePath: 'assets/images/Agri_Products/vinyl fencing.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          VinylfencesDescription()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
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
