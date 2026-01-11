import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import '../Specific_Product_types_description/Greenhouses/GlassGreenhouses_description.dart';
import '../Specific_Product_types_description/Greenhouses/HydroponicGreenhouses_description.dart';
import '../Specific_Product_types_description/Greenhouses/PolycarbonateGreenhouses_description.dart';
import '../Specific_Product_types_description/Greenhouses/ShadeHouses_description.dart';
import '../Specific_Product_types_description/Greenhouses/TunnelGreenhouses_description.dart';

class SpecificproducttypesGreenhouses extends StatefulWidget {
  @override
  _SpecificproducttypesGreenhousesState createState() =>
      _SpecificproducttypesGreenhousesState();
}

class _SpecificproducttypesGreenhousesState
    extends State<SpecificproducttypesGreenhouses> {
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
                              context.watch<LocalizationService>().translate('GH'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),

                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TGHT'),
                              imagePath:'assets/images/Agri_Products/tunnel green house.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          TunnelgreenhousesDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:context.watch<LocalizationService>().translate('TGHG'),
                              imagePath:'assets/images/Agri_Products/glass green house.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          GlassgreenhousesDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:context.watch<LocalizationService>().translate('TGHP'),
                              imagePath:'assets/images/Agri_Products/polycarbonate green house.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          PolycarbonategreenhousesDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header:context.watch<LocalizationService>().translate('TGHS'),
                              imagePath:'assets/images/Agri_Products/shade house.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          ShadehousesDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TGHH'),
                              imagePath:'assets/images/Agri_Products/Hydrophonic green house.jpeg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          HydroponicgreenhousesDescription()),
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
