import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import 'indian runner/indian_runner.dart';
import 'khaki campbell/khaki_campbell.dart';
import 'muscovy/muscovy.dart';

class DuckSpecificTypes extends StatefulWidget {
  @override
  _DuckSpecificTypesState createState() => _DuckSpecificTypesState();
}

class _DuckSpecificTypesState extends State<DuckSpecificTypes> {
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
                                  .translate('duc'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('ind'),
                              imagePath: 'assets/images/lvci/indian_runner.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => IndianRunner()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('kha'),
                              imagePath:
                                  'assets/images/lvci/khaki_campbell.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => KhakiCampbell()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('tmusc'),
                              imagePath: 'assets/images/lvci/moscovy.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => Muscovy()),
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
