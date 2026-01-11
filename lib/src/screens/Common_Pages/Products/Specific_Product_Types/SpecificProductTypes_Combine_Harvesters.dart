import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import '../Specific_Product_types_description/Combine_Harvesters/HybridHarvesters_description.dart';
import '../Specific_Product_types_description/Combine_Harvesters/SelfPropelledHarvesters_description.dart';
import '../Specific_Product_types_description/Combine_Harvesters/TractorMountedHarvesters_description.dart';
import '../Specific_Product_types_description/Combine_Harvesters/WalkBehindHarvesters_description.dart';

class SpecificproducttypesCombineHarvesters extends StatefulWidget {
  @override
  _SpecificproducttypesCombineHarvestersState createState() =>
      _SpecificproducttypesCombineHarvestersState();
}

class _SpecificproducttypesCombineHarvestersState
    extends State<SpecificproducttypesCombineHarvesters> {
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
                                        .translate('agri_products'),
                                    style: NormalTextGrey),
                              ],
                            ),
                            const SizedBox(height: 20),
                            LineGrey,
                            Text(
                              context
                                  .watch<LocalizationService>()
                                  .translate('CH'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),

                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('TCHS'),
                              imagePath:
                                  'assets/images/Agri_Products/self propelled harvesters.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SelfpropelledharvestersDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('TCHT'),
                              imagePath:
                                  'assets/images/Agri_Products/tractor mounted harvesters.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TractormountedharvestersDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('TCHH'),
                              imagePath:
                                  'assets/images/Agri_Products/Hybrid harvesters.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HybridharvestersDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context
                                  .watch<LocalizationService>()
                                  .translate('TCHW'),
                              imagePath:
                                  'assets/images/Agri_Products/walk behind harvesters.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          WalkbehindharvestersDescription()),
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
          ),
        ],
      ),
    );
  }
}
