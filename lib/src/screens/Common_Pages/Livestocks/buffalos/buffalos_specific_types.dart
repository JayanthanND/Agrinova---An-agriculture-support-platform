import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Livestocks/buffalos/surti/surti.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import 'jaffrabadi/jaffrabadi.dart';
import 'mehsana/mehsana.dart';
import 'murrah/murrah.dart';

class BuffalosSpecificTypes extends StatefulWidget {
  @override
  _BuffalosSpecificTypesState createState() => _BuffalosSpecificTypesState();
}

class _BuffalosSpecificTypesState extends State<BuffalosSpecificTypes> {
// Variable to store the farmer's selected need
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color(0xff1ACD36),
        body: Stack(children: [
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
                                        .translate('lv'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('buff'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('fjaff'),
                              imagePath: 'assets/images/lvci/jaffrabadi.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Jaffrabadi()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('meh'),
                              imagePath: 'assets/images/lvci/mehsana.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Mehsana()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('mur'),
                              imagePath: 'assets/images/lvci/murrah.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Murrah()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tsur'),
                              imagePath: 'surti.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Surti()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
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
          )
        ]));
  }
}
