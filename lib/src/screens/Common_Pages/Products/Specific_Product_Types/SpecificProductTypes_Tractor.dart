import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../Language/app_localization.dart';
import '../../../Customs/constants.dart';
import '../../../Customs/custom_page_container_withimage.dart';
import '../Specific_Product_types_description/Tractor/CompactTractors_description.dart';
import '../Specific_Product_types_description/Tractor/RowCropTractors_description.dart';
import '../Specific_Product_types_description/Tractor/SpecialtyTractors_description.dart';
import '../Specific_Product_types_description/Tractor/UtilityTractors_description.dart';
import '../Specific_Product_types_description/Tractor/WD4Tractors_description.dart';

class SpecificproducttypesTractor extends StatefulWidget {
  @override
  _SpecificproducttypesTractorState createState() =>
      _SpecificproducttypesTractorState();
}

class _SpecificproducttypesTractorState
    extends State<SpecificproducttypesTractor> {
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
                              context.watch<LocalizationService>().translate('T'),
                              style: TextBlack,
                            ),
                            const SizedBox(height: 20),

                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TTcom'),
                              imagePath:'assets/images/Agri_Products/compact tractor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          CompacttractorsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TTuti'),
                              imagePath:'assets/images/Agri_Products/utility tractor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          UtilitytractorsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TTrow'),
                              imagePath:'assets/images/Agri_Products/Row crop tractor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          RowcroptractorsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TTwd'),
                              imagePath:'assets/images/Agri_Products/wd4 tractor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          Wd4tractorsDescription()),
                                );
                              },
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            CustomPageContainerWithimage(
                              Header: context.watch<LocalizationService>().translate('TTspe'),
                              imagePath:'assets/images/Agri_Products/speciality tractor.jpg',
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          SpecialtytractorsDescription()),
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
