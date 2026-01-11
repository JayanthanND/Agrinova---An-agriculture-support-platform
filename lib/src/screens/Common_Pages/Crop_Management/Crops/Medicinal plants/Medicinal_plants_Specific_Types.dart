import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../../../../Language/app_localization.dart';
import '../../../../Customs/constants.dart';
import '../../../../Customs/custom_page_container_withimage.dart';
import 'Aloevera/Aloevera.dart';
import 'Ashwagandha/Ashwagandha.dart';
import 'Giloy/Giloy.dart';
import 'Neem/Neem.dart';
import 'Shatavari/Shatavari.dart';
import 'Tulsi/Tulsi.dart';
import 'bringaraj/bringaraj.dart';

class MedicinalPlantsSpecificTypes extends StatefulWidget {
  const MedicinalPlantsSpecificTypes({super.key});

  @override
  State<MedicinalPlantsSpecificTypes> createState() =>
      _MedicinalPlantsSpecificTypesState();
}

class _MedicinalPlantsSpecificTypesState
    extends State<MedicinalPlantsSpecificTypes> {
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
                                        .translate('types_of_crops'),
                                    style: NormalTextGrey),
                              ],
                            ),

                            const SizedBox(height: 20),
                            LineGrey,
                            Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('mp'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),

                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('alo'),
                              imagePath:
                                  'assets/images/types_of_crops/aloevera.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Aloevera()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('ash'),
                              imagePath:
                                  'assets/images/types_of_crops/ashwa.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Ashwagandha()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('fbri'),
                              imagePath:
                                  'assets/images/types_of_crops/bringaraj.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Bringaraj()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('gil'),
                              imagePath:
                                  'assets/images/types_of_crops/giloy.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Giloy()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('ne'),
                              imagePath:
                                  'assets/images/types_of_crops/neem.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Neem()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('sh'),
                              imagePath:
                                  'assets/images/types_of_crops/shatavari.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Shatavari()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tu'),
                              imagePath:
                                  'assets/images/types_of_crops/tulsi.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Tulsi()),
                                );
                              },
                            ),

                            // Display follow requests dynamically based on farmer's need
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
