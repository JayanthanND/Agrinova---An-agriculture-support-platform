import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import 'Agricultural_tools/Cultivators_types.dart';
import 'Agricultural_tools/Hoes_types.dart';
import 'Agricultural_tools/Plow_types.dart';
import 'Agricultural_tools/Pruning_tool_types.dart';
import 'Agricultural_tools/Rakes_types.dart';
import 'Agricultural_tools/Shovels_and_spades_types.dart';

class SpecificproducttypesAgricultureTools extends StatefulWidget {
  @override
  _SpecificproducttypesAgricultureToolsState createState() =>
      _SpecificproducttypesAgricultureToolsState();
}
class _SpecificproducttypesAgricultureToolsState
    extends State<SpecificproducttypesAgricultureTools> {
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
                                Text(context.watch<LocalizationService>().translate('agri_products'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            Text(
                              context.watch<LocalizationService>().translate('AT'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('shovels and spade'),
                              imagePath:'assets/images/Agri_Products/Showels and spades.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShovelsAndSpadesTypes()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('hoes'),
                              imagePath:'assets/images/Agri_Products/Hoes.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HoesTypes()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('pruning tool'),
                                imagePath:'assets/images/Agri_Products/Pruning tool.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PruningToolTypes()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('cultivator'),
                              imagePath:'assets/images/Agri_Products/Cultivators.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CultivatorsTypes()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('rakes'),
                              imagePath:'assets/images/Agri_Products/Rakes.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RakesTypes()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('plow'),
                              imagePath:'assets/images/Agri_Products/Plow.jpg',

                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PlowTypes()),
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
