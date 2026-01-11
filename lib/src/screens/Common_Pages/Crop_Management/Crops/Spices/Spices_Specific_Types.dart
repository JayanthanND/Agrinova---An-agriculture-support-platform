import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../Language/app_localization.dart';
import '../../../../Customs/constants.dart';
import '../../../../Customs/custom_page_container_withimage.dart';
import 'Black pepper/Black_pepper.dart';
import 'Coriander/Coriander.dart';
import 'Cumin/Cumin.dart';
import 'Fennel/Fennel.dart';
import 'Fenugreek/Fenugreek.dart';
import 'Mustard seeds/Mustard_seeds.dart';
import 'Turmeric/Turmeric.dart';
import 'chilli/chilli.dart';

class SpicesSpecificTypes extends StatefulWidget {
  const SpicesSpecificTypes({super.key});

  @override
  State<SpicesSpecificTypes> createState() => _SpicesSpecificTypesState();
}

class _SpicesSpecificTypesState extends State<SpicesSpecificTypes> {
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
                              Text('AgriNova', style: TitleStyle),
                              const SizedBox(height: 5),
                              Text('an agriculture support platform',
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
                                  .translate('types_of_crops'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),

                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('bla'),
                              imagePath:
                                  'assets/images/types_of_crops/blackpepper.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => BlackPepper()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('fchi'),
                              imagePath:
                                  'assets/images/types_of_crops/chilli.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Chilli()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('cor'),
                              imagePath:
                                  'assets/images/types_of_crops/coriander.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Coriander()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('cum'),
                              imagePath:
                                  'assets/images/types_of_crops/cumin .jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Cumin()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('fen'),
                              imagePath:
                                  'assets/images/types_of_crops/fennel.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Fennel()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tfenu'),
                              imagePath:
                                  'assets/images/types_of_crops/fenugreek.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Fenugreek()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tmust'),
                              imagePath:
                                  'assets/images/types_of_crops/mustard2.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MustardSeeds()),
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tur'),
                              imagePath:
                                  'assets/images/types_of_crops/turmeric.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Turmeric()),
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
