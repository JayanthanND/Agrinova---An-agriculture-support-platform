import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Livestocks/Rabbits/soviet/soviet.dart';
import 'package:project_agrinova/src/screens/Common_Pages/Livestocks/Rabbits/white/white.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import 'angora/angora.dart';

class RabbitSpecificTypes extends StatefulWidget {
  @override
  _RabbitSpecificTypesState createState() => _RabbitSpecificTypesState();
}

class _RabbitSpecificTypesState extends State<RabbitSpecificTypes> {
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
                                  .translate('rab'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('ang'),
                              imagePath: 'assets/images/lvci/angora.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Angora()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tsov'),
                              imagePath: 'assets/images/lvci/angora.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Soviet()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('fwhi'),
                              imagePath: 'assets/images/lvci/white.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => White()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
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
